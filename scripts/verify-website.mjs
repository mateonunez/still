#!/usr/bin/env node
/** Check served routes and SEO metadata; never infer search rankings. */
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { parseArgs } from 'node:util';

const manifests = JSON.parse(
  await readFile(new URL('../apps/website/src/features/plugins/native-manifests.json', import.meta.url), 'utf8'),
);
const paths = [
  '/',
  '/how-it-works',
  '/download',
  '/start',
  '/privacy',
  '/support',
  '/changelog',
  '/plugins',
  '/developers',
  '/license',
  ...manifests.map((plugin) => `/plugins/${plugin.slug}`),
];
const origin = 'https://meet-still.app';
const { values, positionals } = parseArgs({
  options: { indexable: { type: 'boolean', default: false } },
  allowPositionals: true,
});
if (positionals.length !== 1) throw new Error('Usage: node scripts/verify-website.mjs <base-url> [--indexable]');
const base = new URL(positionals[0]);
if (!['http:', 'https:'].includes(base.protocol)) throw new Error('HTTP(S) URL required');
const indexable = values.indexable;
const canonical = (value) => value?.replace(/\/$/, '');
const decode = (text) =>
  text.replace(/&(#x[\da-f]+|#\d+|amp|quot|apos|lt|gt);/gi, (match, entity) => {
    if (entity.startsWith('#x')) return String.fromCodePoint(Number.parseInt(entity.slice(2), 16));
    if (entity.startsWith('#')) return String.fromCodePoint(Number.parseInt(entity.slice(1), 10));
    return { amp: '&', quot: '"', apos: "'", lt: '<', gt: '>' }[entity.toLowerCase()] ?? match;
  });

async function fetchRoute(path) {
  const response = await fetch(new URL(path, base), {
    headers: { 'User-Agent': 'StillWebsiteVerification/1.0' },
    signal: AbortSignal.timeout(30_000),
  });
  assert.equal(response.status, 200, `${path}: HTTP status`);
  return response;
}

function metadata(html) {
  const meta = {};
  let link;
  let h1 = 0;
  // Parse tags from server-rendered content, excluding inline program text.
  const document = html.replace(/<script\b[^>]*>[\s\S]*?<\/script\s*>/gi, '');
  for (const tag of document.matchAll(/<(h1|meta|link)\b([^>]*)>/gi)) {
    const kind = tag[1].toLowerCase();
    if (kind === 'h1') {
      h1++;
      continue;
    }
    const attributes = {};
    for (const attribute of tag[2].matchAll(/([\w:-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/g)) {
      attributes[attribute[1].toLowerCase()] = decode(attribute[2] ?? attribute[3] ?? attribute[4]);
    }
    if (kind === 'meta') meta[attributes.name ?? attributes.property] = attributes.content;
    if (kind === 'link' && attributes.rel === 'canonical') link = attributes.href;
  }
  return { meta, canonical: link, h1 };
}

const descriptions = [];
const routes = await Promise.all(
  paths.map(async (path) => {
    const response = await fetchRoute(path);
    const page = metadata(await response.text());
    assert.equal(page.h1, 1, `${path}: H1 count`);
    assert.equal(canonical(page.canonical), canonical(origin + path), `${path}: canonical`);
    assert.ok(page.meta.description, `${path}: description`);
    assert.ok(page.meta['og:title'] && page.meta['og:description'], `${path}: share metadata`);
    assert.equal(canonical(page.meta['og:url']), canonical(origin + path), `${path}: OG URL`);
    assert.equal(page.meta['twitter:card'], 'summary_large_image', `${path}: Twitter card`);
    const robots = page.meta.robots ?? '';
    const header = response.headers.get('x-robots-tag') ?? '';
    assert.equal(!robots.includes('noindex'), indexable, `${path}: robots metadata`);
    assert.equal(!header.includes('noindex'), indexable, `${path}: robots header`);
    descriptions.push(page.meta.description);
    return { path, canonical: page.canonical, h1: page.h1, robots };
  }),
);
assert.equal(new Set(descriptions).size, paths.length, 'Descriptions must be unique');
const sitemap = await (await fetchRoute('/sitemap.xml')).text();
const locations = new Set([...sitemap.matchAll(/<loc>([^<]*)<\/loc>/g)].map((match) => decode(match[1])));
assert.deepEqual(locations, new Set(paths.map((path) => origin + path)), 'Sitemap route mismatch');
const robots = await (await fetchRoute('/robots.txt')).text();
assert.equal(robots.includes(`Sitemap: ${origin}/sitemap.xml`), indexable, 'Robots sitemap directive');
const catalog = await (await fetchRoute('/plugins/catalog.json')).json();
assert.equal(catalog.catalogVersion, 1);
assert.equal(catalog.plugins.length, 10);
assert.deepEqual(
  catalog.plugins.map((plugin) => plugin.id),
  manifests.map((plugin) => plugin.id),
);
assert.equal(catalog.appAvailability, 'development-preview');
for (const [source, resource] of [
  ['schemas/plugin-manifest-v1.schema.json', '/sdk/plugin-manifest-v1.schema.json'],
  ['schemas/plugin-snapshot-v1.schema.json', '/sdk/plugin-snapshot-v1.schema.json'],
  ['examples/plugins/local-signals.stillplugin/manifest.json', '/sdk/local-signals/manifest.json'],
  ['examples/plugins/porcelain-rail.stillplugin/manifest.json', '/sdk/porcelain-rail/manifest.json'],
  ['examples/plugins/publish-sample.mjs', '/sdk/publish-sample.mjs'],
  ['LICENSE', '/license.txt'],
  ['LICENSE', '/sdk/LICENSE'],
]) {
  assert.equal(
    await (await fetchRoute(resource)).text(),
    await readFile(new URL(`../${source}`, import.meta.url), 'utf8'),
    `${resource}: SDK source drift`,
  );
}
for (const name of ['plugin-manifest-v1.schema.json', 'plugin-snapshot-v1.schema.json']) {
  const schema = await (await fetchRoute(`/schemas/${name}`)).json();
  assert.equal(schema.$id, `${origin}/schemas/${name}`, 'Schema identity must resolve');
}
for (const path of ['/llms.txt', '/llms-full.txt']) {
  const response = await fetchRoute(path);
  assert.ok(response.headers.get('content-type')?.startsWith('text/plain'));
  const text = await response.text();
  assert.ok(text.includes('experimental preview') && text.includes('not notarized'));
}
for (const resource of [
  '/media/still-showcase.mp4',
  '/media/still-showcase.vtt',
  '/media/showcase-transcript.txt',
  '/media/still-social.png',
]) {
  await fetchRoute(resource);
}
const downloadHTML = await (await fetchRoute('/download')).text();
assert.ok(downloadHTML.includes('Still-0.1.0-preview.2-universal.zip') && downloadHTML.includes('SHA256SUMS'));
const image = Buffer.from(await (await fetchRoute('/opengraph-image')).arrayBuffer());
assert.ok(image.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])), 'Share image must be PNG');
assert.equal(image.readUInt32BE(16), 1200, 'Share image width');
assert.equal(image.readUInt32BE(20), 630, 'Share image height');
console.log(
  JSON.stringify(
    {
      passed: true,
      base: base.href.replace(/\/$/, ''),
      indexable,
      routes,
      sitemapRoutes: locations.size,
      shareImage: '1200x630 PNG',
    },
    null,
    2,
  ),
);
