#!/usr/bin/env node
/** Bounded native structural probe; no authentication or desktop coverage claim. */
import { createHash } from 'node:crypto';
import { open, readFile, rename, rm, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { commandOutput, delay, outputDirectory, ownedProcess, root, stop, waitForFile } from './probe-support.mjs';

async function worker(path) {
  let completed = 0;
  let published = 0;
  while (true) {
    createHash('sha256').update(`still-synthetic-work-${completed}`).digest();
    completed++;
    if (performance.now() - published >= 100) {
      await writeFile(`${path}.tmp`, JSON.stringify({ completed }));
      await rename(`${path}.tmp`, path);
      published = performance.now();
    }
  }
}

async function verify(appName, directory) {
  if (appName !== 'Still' && appName !== 'Still-preview') throw new Error('Unsupported app name');
  const output = await outputDirectory(
    directory ?? (appName === 'Still-preview' ? 'out/verification/phase01-refinement' : 'out/verification/phase01'),
  );
  const executable = join(root, `out/${appName}.app/Contents/MacOS/Still`);
  const executableSHA256 = createHash('sha256')
    .update(await readFile(executable))
    .digest('hex');
  const receiptPath = join(output, 'runtime.json');
  const progressPath = join(output, 'synthetic-progress.json');
  for (const name of [
    'runtime.json',
    'interaction.json',
    'synthetic-progress.json',
    'porcelain-light.png',
    'porcelain-dark.png',
  ])
    await rm(join(output, name), { force: true });
  let workload;
  let app;
  const log = await open(join(output, 'launch.log'), 'w');
  try {
    workload = ownedProcess(process.execPath, [fileURLToPath(import.meta.url), '--worker', progressPath]);
    await waitForFile(progressPath);
    const progress = async () => JSON.parse(await readFile(progressPath, 'utf8')).completed;
    const before = await progress();
    app = ownedProcess(
      executable,
      ['--cover', '--evidence-directory', output, '--interaction-trace', output],
      ['ignore', log.fd, log.fd],
    );
    await waitForFile(receiptPath);
    await waitForFile(join(output, 'porcelain-dark.png'));
    await delay(750);
    const during = await progress();
    const alive = app.running();
    const receipt = JSON.parse(await readFile(receiptPath, 'utf8'));
    const interaction = JSON.parse(await readFile(join(output, 'interaction.json'), 'utf8'));
    const panelGenerations = interaction.events.filter((event) => event.phase === 'touchIDPreparation').length;
    const ownCurtainAssertions = async () =>
      (await commandOutput('pmset', ['-g', 'assertions']))
        .split('\n')
        .filter(
          (line) =>
            new RegExp(`\\bpid\\s+${app.child.pid}\\(`).test(line) &&
            line.includes('Still ') &&
            line.includes('curtain awake session'),
        );
    const awakeBefore = await ownCurtainAssertions();
    await stop(app);
    await delay(250);
    const awakeAfter = await ownCurtainAssertions();
    const after = await progress();
    const checks = {
      appAliveWhilePanelsReportedVisible: alive,
      onePanelPerReportedDisplay: receipt.panelCount === receipt.displayCount && receipt.displayCount > 0,
      onePanelGenerationWithoutPhysicalDisplayChange: panelGenerations === 1,
      allPanelFramesMatchReportedScreens: receipt.windows.every((window) => window.matchesScreenFrame),
      allPanelsReportedVisible: receipt.windows.every((window) => window.visible),
      allPanelsAtExpectedCurtainLevel: receipt.windows.every((window) => window.level === receipt.expectedCurtainLevel),
      displayFontRegistered: receipt.displayFontRegistered,
      syntheticProcessMadeProgress: before < during && during < after,
      curtainReportsActiveAwakeRequest: receipt.curtainAwakeActive && receipt.curtainAwakeID > 0,
      oneOwnedDisplayAwakeRequestWhileCovered:
        awakeBefore.length === 1 && awakeBefore[0].includes('PreventUserIdleDisplaySleep'),
      curtainRequestRemovedAfterOwnedAppTerminates: awakeAfter.length === 0,
      ownedAppTerminated: !app.running(),
    };
    const result = {
      kind: 'native-structural-smoke',
      executableSHA256,
      checks,
      syntheticIterations: { before, during, after },
      panelGenerations,
      boundary: 'Not visual coverage, authentication, sleep prevention or universal workload proof.',
    };
    await writeFile(join(output, 'smoke.json'), `${JSON.stringify(result, null, 2)}\n`);
    console.log(JSON.stringify(result, null, 2));
    if (!Object.values(checks).every(Boolean)) throw new Error('Native structural checks failed');
  } finally {
    await stop(app);
    await stop(workload);
    await log.close();
  }
}

const { values } = parseArgs({
  options: { app: { type: 'string', default: 'Still' }, output: { type: 'string' }, worker: { type: 'string' } },
});
if (values.worker) await worker(values.worker);
else await verify(values.app, values.output);
