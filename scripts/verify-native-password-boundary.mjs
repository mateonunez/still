import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createInterface } from 'node:readline/promises';
import { parseArgs } from 'node:util';
import { nativeCandidates } from './native-candidate.mjs';

// Observe while covered; answer only after returning, so Terminal focus cannot contaminate the trial.
const { values } = parseArgs({ options: { app: { type: 'string', default: 'Still-preview' } } });
if (!nativeCandidates.includes(values.app)) throw new Error('Unsupported candidate');
const app = resolve(`out/${values.app}.app`);
const hash = createHash('sha256')
  .update(await readFile(`${app}/Contents/MacOS/Still`))
  .digest('hex');
const root = resolve(`out/verification/password-boundary/${new Date().toISOString().replaceAll(':', '-')}`);
const terminal = createInterface({ input: process.stdin, output: process.stdout });
const pause = (text) =>
  terminal.question(`${text}\nPress Enter after completing these steps and returning to Terminal. `);
const yesNo = async (text) => {
  while (true) {
    const reply = (await terminal.question(`${text} [y/n] `)).trim().toLowerCase();
    if (reply === 'y' || reply === 'n') return reply === 'y';
  }
};
const launch = async (name) => {
  await pause('Quit every running Still yourself.');
  const directory = resolve(root, name);
  await mkdir(directory, { recursive: true, mode: 0o700 });
  assert.equal(spawnSync('open', [app, '--args', '--interaction-trace', directory]).status, 0);
  return directory;
};
const trace = async (directory) => JSON.parse(await readFile(`${directory}/interaction.json`, 'utf8')).events;
try {
  const a = await launch('touch-id-only');
  await pause(
    'A: Activate Still and immediately perform the horizontal swipe that exposed windows. Observe the transition, then return using ONLY Touch ID. Do not open the Mac-password dialog.',
  );
  const touchIDOnlyExposure = await yesNo('Did the activation-time swipe expose any underlying window or preview?');
  const eventsA = await trace(a);
  const aIsolated =
    !eventsA.some((event) => event.phase === 'systemAuthentication') &&
    eventsA.some((event) => event.phase === 'authenticated' && event.authentication === 'touchID');

  const b = await launch('password-cancel');
  await pause(
    'B: Activate Still normally and let it settle. Open Use Mac password. Try the same swipes WHILE the macOS dialog is open. Cancel the dialog. WITHOUT clicking another window or the curtain, test swipes immediately, then again after two seconds. Observe all three cases. Only afterwards use the curtain to return to your Mac and answer here. Never enter your password in Terminal.',
  );
  const dialogExposure = await yesNo('Were underlying windows exposed while the system dialog was open?');
  const immediateCancelExposure = await yesNo('Were underlying windows exposed immediately after canceling?');
  const settledCancelExposure = await yesNo(
    'Were underlying windows exposed after canceling and waiting two seconds without clicking another window?',
  );
  const eventsB = await trace(b);
  const bIsolated =
    eventsB.some((event) => event.phase === 'systemAuthentication') &&
    eventsB.some((event) => event.phase === 'authenticationCanceled' && event.authentication === 'system');
  const report = {
    kind: 'owner-password-boundary-comparison',
    executableSHA256: hash,
    touchIDOnlyExposure,
    touchIDOnlyTrialValid: aIsolated,
    dialogExposure,
    immediateCancelExposure,
    settledCancelExposure,
    passwordCancelTrialValid: bIsolated,
    boundary: 'Owner-observed physical behavior; no authentication change or security-lock guarantee.',
  };
  await writeFile(`${root}/comparison.json`, `${JSON.stringify(report, null, 2)}\n`, { mode: 0o600 });
  console.log(JSON.stringify({ ...report, directory: root }, null, 2));
  if (
    !aIsolated ||
    !bIsolated ||
    touchIDOnlyExposure ||
    dialogExposure ||
    immediateCancelExposure ||
    settledCancelExposure
  )
    process.exitCode = 1;
} finally {
  terminal.close();
}
