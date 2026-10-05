#!/usr/bin/env node
/** Verify owned finite IOKit requests; never force sleep or change preferences. */
import { createHash } from 'node:crypto';
import { open, readFile, rm, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parseArgs } from 'node:util';
import { commandOutput, delay, outputDirectory, ownedProcess, root, stop } from './probe-support.mjs';

const { values } = parseArgs({
  options: {
    app: { type: 'string', default: 'Still-preview' },
    output: { type: 'string', default: 'out/verification/phase02' },
  },
});
if (!['Still', 'Still-preview'].includes(values.app)) throw new Error('Unsupported app name');
const executable = join(root, `out/${values.app}.app/Contents/MacOS/Still`);
const executableSHA256 = createHash('sha256')
  .update(await readFile(executable))
  .digest('hex');
const output = await outputDirectory(values.output);
for (const name of ['progress.json', 'energy.json']) await rm(join(output, name), { force: true });
const pmset = {};
const log = await open(join(output, 'energy-launch.log'), 'w');
const probe = ownedProcess(executable, ['--energy-probe', output], ['ignore', log.fd, log.fd]);
try {
  const deadline = performance.now() + 20_000;
  while (probe.running() && performance.now() < deadline) {
    let phase;
    try {
      phase = JSON.parse(await readFile(join(output, 'progress.json'), 'utf8')).phase;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
    if ((phase === 'system-only' || phase === 'system-and-display') && !pmset[phase]) {
      const listing = await commandOutput('pmset', ['-g', 'assertions']);
      const ownLines = listing
        .split('\n')
        .filter(
          (line) =>
            new RegExp(`\\bpid\\s+${probe.child.pid}\\(`).test(line) &&
            line.includes('Still ') &&
            line.includes('timed'),
        );
      pmset[phase] = ['PreventUserIdleSystemSleep', 'PreventUserIdleDisplaySleep']
        .filter((kind) => ownLines.some((line) => line.includes(kind)))
        .map((assertionType) => ({ ownerPid: probe.child.pid, assertionType }));
    }
    await delay(100);
  }
  if (probe.running()) throw new Error('Native energy probe exceeded 20 seconds');
  const exit = await probe.done;
  if (exit.error) throw exit.error;
  const result = JSON.parse(await readFile(join(output, 'energy.json'), 'utf8'));
  result.checks ??= {};
  result.checks.pmsetShowsSystemRequest =
    pmset['system-only']?.some((item) => item.assertionType === 'PreventUserIdleSystemSleep') ?? false;
  result.checks.pmsetShowsDisplayRequest =
    pmset['system-and-display']?.some((item) => item.assertionType === 'PreventUserIdleDisplaySleep') ?? false;
  result.pmsetOwnAssertions = pmset;
  result.executableSHA256 = executableSHA256;
  result.allPassed = result.allPassed && Object.values(result.checks).every(Boolean) && exit.code === 0;
  await writeFile(join(output, 'energy.json'), `${JSON.stringify(result, null, 2)}\n`);
  console.log(JSON.stringify({ allPassed: result.allPassed, checks: result.checks, executableSHA256 }, null, 2));
  if (!result.allPassed) throw new Error('Native energy probe failed');
} finally {
  await stop(probe);
  await log.close();
}
