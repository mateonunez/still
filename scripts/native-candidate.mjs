#!/usr/bin/env node
/** Read-only candidate resolution; recording is used only by the local builder. */
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const nativeCandidates = [
  'Still',
  'Still-preview',
  'Still-canvas',
  'Still-glass',
  'Still-design',
  'Still-review',
  'Still-polish',
];
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const manifest = join(root, 'out/native-candidate.json');

export async function currentCandidate() {
  const result = JSON.parse(await readFile(manifest, 'utf8'));
  if (!nativeCandidates.includes(result.app) || result.release !== false)
    throw new Error('Invalid local candidate manifest');
  const executable = join(root, `out/${result.app}.app/Contents/MacOS/Still`);
  const hash = createHash('sha256')
    .update(await readFile(executable))
    .digest('hex');
  if (hash !== result.executableSHA256)
    throw new Error('Candidate changed since build; rebuild before accepting evidence');
  return { ...result, path: join(root, `out/${result.app}.app`) };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [action, app] = process.argv.slice(2);
  if (action === '--record') {
    if (!nativeCandidates.includes(app)) throw new Error('Unsupported candidate');
    const executable = join(root, `out/${app}.app/Contents/MacOS/Still`);
    const revision = spawnSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' });
    if (revision.status !== 0) throw new Error('Cannot record source revision');
    const status = spawnSync('git', ['status', '--porcelain'], { cwd: root, encoding: 'utf8' });
    const result = {
      app,
      builtAt: new Date().toISOString(),
      sourceRevision: revision.stdout.trim(),
      sourceModified: status.status === 0 ? status.stdout.trim().length > 0 : null,
      executableSHA256: createHash('sha256')
        .update(await readFile(executable))
        .digest('hex'),
      release: false,
      boundary: 'Ad-hoc development candidate; not signed/notarized for distribution.',
    };
    await writeFile(manifest, `${JSON.stringify(result, null, 2)}\n`);
  } else if (action === '--path') {
    console.log((await currentCandidate()).path);
  } else if (!action) {
    console.log(JSON.stringify(await currentCandidate(), null, 2));
  } else {
    throw new Error('Usage: node scripts/native-candidate.mjs [--path]');
  }
}
