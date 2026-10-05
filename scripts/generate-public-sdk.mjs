#!/usr/bin/env node
import { copyFile, mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { catalogRoot, ids, regularJSON } from '../packages/still-plugins/src/registry.mjs';
import { root } from './probe-support.mjs';

const manifests = await Promise.all(
  ids.map(async (slug) => {
    const manifest = await regularJSON(join(catalogRoot, slug, 'plugin.json'));
    if (
      manifest.id !== `co.mateonunez.still.${slug}` ||
      manifest.runtime !== 'native-builtin' ||
      manifest.publisher !== 'mateonunez'
    )
      throw new Error('Unsupported public catalog manifest');
    return { slug, ...manifest };
  }),
);
const feature = join(root, 'apps/website/src/features/plugins');
await mkdir(feature, { recursive: true });
await writeFile(join(feature, 'native-manifests.json'), `${JSON.stringify(manifests, null, 2)}\n`);
const publicRoot = join(root, 'apps/website/public/sdk');
for (const [source, destination] of [
  ['schemas/plugin-manifest-v1.schema.json', 'plugin-manifest-v1.schema.json'],
  ['schemas/plugin-snapshot-v1.schema.json', 'plugin-snapshot-v1.schema.json'],
  ['examples/plugins/local-signals.stillplugin/manifest.json', 'local-signals/manifest.json'],
  ['examples/plugins/porcelain-rail.stillplugin/manifest.json', 'porcelain-rail/manifest.json'],
  ['examples/plugins/publish-sample.mjs', 'publish-sample.mjs'],
]) {
  await mkdir(join(publicRoot, destination, '..'), { recursive: true });
  await copyFile(join(root, source), join(publicRoot, destination));
}
console.log('Generated ten-plugin public catalog and declarative SDK assets.');

const schemaRoot = join(root, 'apps/website/public/schemas');
await mkdir(schemaRoot, { recursive: true });
for (const name of ['plugin-manifest-v1.schema.json', 'plugin-snapshot-v1.schema.json']) {
  await copyFile(join(root, 'schemas', name), join(schemaRoot, name));
}
