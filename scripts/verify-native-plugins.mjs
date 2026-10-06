#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { open, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parseArgs } from 'node:util';
import { nativeCandidates } from './native-candidate.mjs';
import { outputDirectory, ownedProcess, root, stop, waitForFile } from './probe-support.mjs';

const { values } = parseArgs({ options: { app: { type: 'string', default: 'Still-preview' } } });
if (!nativeCandidates.includes(values.app)) throw new Error('Unsupported app name');
const executable = join(root, `out/${values.app}.app/Contents/MacOS/Still`);
const output = await outputDirectory(
  `out/verification/native-collection/${new Date().toISOString().replaceAll(':', '-')}`,
);
const hash = createHash('sha256')
  .update(await readFile(executable))
  .digest('hex');
const log = await open(join(output, 'launch.log'), 'w');
const probe = ownedProcess(
  executable,
  ['--native-plugins-probe', output, '--task-producer', join(root, 'packages/still-plugins/src/task.mjs')],
  ['ignore', log.fd, log.fd],
);
try {
  await waitForFile(join(output, 'native-plugins.json'), 40_000);
  const result = JSON.parse(await readFile(join(output, 'native-plugins.json'), 'utf8'));
  result.executableSHA256 = hash;
  await writeFile(join(output, 'native-plugins.json'), `${JSON.stringify(result, null, 2)}\n`);
  console.log(JSON.stringify({ ...result, output }, null, 2));
  if (!result.allPassed) throw new Error('Native collection probe failed');
} finally {
  await stop(probe);
  await log.close();
}
