#!/usr/bin/env node
import { execFile } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';
import { parseArgs, promisify } from 'node:util';

const exec = promisify(execFile);
export function cpuSeconds(value) {
  const match = /^(?:(\d+)-)?(?:(\d+):)?(\d+):(\d+(?:\.\d+)?)$/.exec(value.trim());
  if (!match || Number(match[4]) >= 60 || (match[2] !== undefined && Number(match[3]) >= 60))
    throw new Error('Unsupported process CPU time');
  return Number(match[1] ?? 0) * 86400 + Number(match[2] ?? 0) * 3600 + Number(match[3]) * 60 + Number(match[4]);
}
export function utilization(startCPU, endCPU, elapsedSeconds) {
  if (elapsedSeconds <= 0 || endCPU < startCPU) throw new Error('Invalid CPU measurement interval');
  return (100 * (endCPU - startCPU)) / elapsedSeconds;
}
async function observation(pid) {
  const { stdout } = await exec('/bin/ps', ['-p', String(pid), '-o', 'time=', '-o', 'lstart=']);
  const match = /^\s*(\S+)\s+(.+)$/.exec(stdout.trim());
  if (!match) throw new Error('Process unavailable');
  return { cpu: cpuSeconds(match[1]), started: match[2], at: performance.now() };
}
export async function measure(pid, { seconds = 10, maxPercent = 25 } = {}) {
  if (
    !Number.isSafeInteger(pid) ||
    pid <= 0 ||
    !Number.isSafeInteger(seconds) ||
    seconds < 2 ||
    seconds > 60 ||
    !Number.isFinite(maxPercent) ||
    maxPercent <= 0 ||
    maxPercent > 800
  )
    throw new Error('Invalid CPU probe arguments');
  const { stdout } = await exec('/bin/ps', ['-p', String(pid), '-o', 'comm=']);
  const executable = stdout.trim();
  if (!executable.endsWith('.app/Contents/MacOS/Still')) throw new Error('PID is not a Still app');
  const hash = createHash('sha256')
    .update(await readFile(executable))
    .digest('hex');
  const start = await observation(pid),
    intervals = [];
  let previous = start;
  for (let index = 0; index < seconds; index++) {
    await delay(1000);
    const next = await observation(pid);
    if (next.started !== start.started) throw new Error('Process changed during observation');
    intervals.push(utilization(previous.cpu, next.cpu, (next.at - previous.at) / 1000));
    previous = next;
  }
  const elapsed = (previous.at - start.at) / 1000;
  const average = utilization(start.cpu, previous.cpu, elapsed);
  return {
    kind: 'native-cpu-observation',
    pid,
    executableSHA256: hash,
    observedAt: new Date().toISOString(),
    elapsedSeconds: elapsed,
    averageCorePercent: average,
    peakIntervalCorePercent: Math.max(...intervals),
    intervalsCorePercent: intervals,
    thresholdCorePercent: maxPercent,
    passed: average <= maxPercent,
    boundary:
      'Read-only CPU-time delta; requires a deliberately idle scene. Not GPU, energy, layout attribution or long-run acceptance.',
  };
}
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const { values } = parseArgs({
      options: {
        pid: { type: 'string' },
        seconds: { type: 'string' },
        'max-percent': { type: 'string' },
        output: { type: 'string' },
      },
    });
    const report = await measure(Number(values.pid), {
      seconds: Number(values.seconds ?? 10),
      maxPercent: Number(values['max-percent'] ?? 25),
    });
    if (values.output) await writeFile(values.output, `${JSON.stringify(report, null, 2)}\n`, { mode: 0o600 });
    console.log(JSON.stringify(report, null, 2));
    if (!report.passed) process.exitCode = 1;
  } catch (error) {
    console.error(error.message);
    process.exitCode = 2;
  }
}
