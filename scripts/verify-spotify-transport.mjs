#!/usr/bin/env node
import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parseArgs, promisify } from 'node:util';
import { outputDirectory, root } from './probe-support.mjs';

const { values } = parseArgs({ options: { app: { type: 'string', default: 'Still-preview' } } });
assert(['Still', 'Still-preview'].includes(values.app), 'Unsupported application');
const helper = join(root, `out/${values.app}.app/Contents/MacOS/StillSpotifyBridge`);
const output = await outputDirectory(
  `out/verification/spotify-transport/${new Date().toISOString().replaceAll(':', '-')}`,
);
const { stdout } = await promisify(execFile)(helper, ['--hide-titles'], { timeout: 7000, maxBuffer: 4096 });
const result = JSON.parse(stdout);
const receipt = {
  ready: result.state === 'ready',
  state: result.state,
  errorCode: result.errorCode ?? null,
  helperSHA256: createHash('sha256')
    .update(await readFile(helper))
    .digest('hex'),
  boundary: 'Read-only helper invoked by the verifier; not Still-owned Automation consent or native UI acceptance.',
};
await writeFile(join(output, 'receipt.json'), `${JSON.stringify(receipt, null, 2)}\n`);
console.log(JSON.stringify({ ...receipt, output }, null, 2));
assert(receipt.ready, 'Spotify transport did not return playback state');
