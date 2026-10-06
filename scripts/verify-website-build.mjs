#!/usr/bin/env node
/** Offline inspection of actual generated HTML; does not verify HTTP or browser interaction. */
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const output = new URL('../apps/website/.next/server/app/', import.meta.url);
const catalog = JSON.parse(await readFile(new URL('plugins/catalog.json.body', output), 'utf8'));
const manifests = JSON.parse(
  await readFile(new URL('../apps/website/src/features/plugins/native-manifests.json', import.meta.url), 'utf8'),
);
const paths = [
  '/',
  '/how-it-works',
  '/download',
  '/privacy',
  '/support',
  '/changelog',
  '/plugins',
  '/developers',
  '/license',
  ...manifests.map((p) => `/plugins/${p.slug}`),
];
const titles = new Set();
for (const path of paths) {
  const html = (await readFile(new URL(path === '/' ? 'index.html' : `${path.slice(1)}.html`, output), 'utf8')).replace(
    /<script\b[^>]*>[\s\S]*?<\/script>/gi,
    '',
  );
  assert.equal([...html.matchAll(/<h1\b/gi)].length, 1, `${path}: H1`);
  const canonical = html.match(/<link\b[^>]*rel="canonical"[^>]*href="([^"]*)"/)?.[1];
  assert.equal(
    canonical?.replace(/\/$/, ''),
    `https://meet-still.app${path === '/' ? '' : path}`,
    `${path}: canonical`,
  );
  assert.match(html, /<meta name="robots" content="noindex, nofollow"\/>/, `${path}: local preview noindex`);
  assert.match(html, /property="og:title"/, `${path}: Open Graph`);
  const title = html.match(/<title>(.*?)<\/title>/)?.[1];
  assert.ok(title && !titles.has(title), `${path}: unique title`);
  titles.add(title);
}
const home = await readFile(new URL('index.html', output), 'utf8');
assert.ok(home.includes('Preview theme') && home.includes('Glass') && home.includes('not a native screenshot'));
const sitemap = await readFile(new URL('sitemap.xml.body', output), 'utf8');
assert.equal([...sitemap.matchAll(/<loc>/g)].length, paths.length);
assert.ok(!sitemap.includes('/preview'));
const guide = await readFile(new URL('llms-full.txt.body', output), 'utf8');
assert.ok(guide.includes('Porcelain and Glass') && guide.includes('not publicly distributed'));
assert.equal(catalog.plugins.length, 10);
const license = await readFile(new URL('../LICENSE', import.meta.url), 'utf8');
assert.equal(await readFile(new URL('../apps/website/public/license.txt', import.meta.url), 'utf8'), license);
assert.equal(await readFile(new URL('../apps/website/public/sdk/LICENSE', import.meta.url), 'utf8'), license);
const licensePage = await readFile(new URL('license.html', output), 'utf8');
assert.ok(licensePage.includes('MIT License') && licensePage.includes('private during development'));
const image = await readFile(new URL('opengraph-image.body', output));
assert.equal(image.subarray(1, 4).toString(), 'PNG');
assert.equal(image.readUInt32BE(16), 1200);
assert.equal(image.readUInt32BE(20), 630);
console.log(
  JSON.stringify(
    {
      generatedPages: paths.length,
      uniqueTitles: titles.size,
      localNoindex: true,
      sitemap: true,
      themeIllustration: true,
      agentGuide: true,
      boundary: 'Built HTML only; HTTP headers, browser visuals and production delivery not verified.',
    },
    null,
    2,
  ),
);
