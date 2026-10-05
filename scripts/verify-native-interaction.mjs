import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createInterface } from 'node:readline/promises';

// Physical gestures/biometrics cannot be synthesized: preserve an explicit human verdict.
const directory = resolve('out/verification/interaction-trial');
let report;
if (process.argv[2] === '--report') {
  report = JSON.parse(await readFile(process.argv[3], 'utf8'));
} else {
  const terminal = createInterface({ input: process.stdin, output: process.stdout });
  const yesNo = async (question) => {
    while (true) {
      const answer = (await terminal.question(`${question} [y/n] `)).trim().toLowerCase();
      if (answer === 'y' || answer === 'n') return answer === 'y';
    }
  };
  try {
    await mkdir(directory, { recursive: true, mode: 0o700 });
    const app = resolve('out/Still.app');
    const hash = createHash('sha256')
      .update(await readFile(`${app}/Contents/MacOS/Still`))
      .digest('hex');
    await terminal.question(
      'Quit every running Still yourself. Press Enter when ready to launch the diagnostic candidate. ',
    );
    const launch = spawnSync('open', [app, '--args', '--interaction-trace', directory], { encoding: 'utf8' });
    assert.equal(launch.status, 0, 'Launch failed');
    await terminal.question(
      'Activate Still from its menu once. Do not swipe during activation. Press Enter when covered. ',
    );
    const firstTouchIDVisible = await yesNo('Is the embedded Touch ID icon visible?');
    const firstGestureExposedWindows = await yesNo(
      'Do slow/fast/partial three-finger swipes or Mission Control expose any underlying window?',
    );
    await terminal.question(
      'Return using Touch ID or the system Mac-password dialog. Activate Still a second time without swiping during activation. Press Enter when covered. ',
    );
    const secondTouchIDVisible = await yesNo('Is the embedded Touch ID icon visible now?');
    const secondGestureExposedWindows = await yesNo('Do the same gestures expose any underlying window now?');
    await terminal.question(
      'Return again. Activate Still and immediately start a horizontal desktop swipe. Press Enter after checking the transition. ',
    );
    const swipeDuringActivationExposedWindows = await yesNo('Did any underlying window or preview become visible?');
    report = {
      kind: 'owner-native-interaction-trial',
      executableSHA256: hash,
      firstTouchIDVisible,
      firstGestureExposedWindows,
      secondTouchIDVisible,
      secondGestureExposedWindows,
      swipeDuringActivationExposedWindows,
    };
    await writeFile(`${directory}/owner-trial.json`, `${JSON.stringify(report, null, 2)}\n`, { mode: 0o600 });
  } finally {
    terminal.close();
  }
}
assert.equal(report.kind, 'owner-native-interaction-trial');
for (const field of ['firstTouchIDVisible', 'secondTouchIDVisible', 'swipeDuringActivationExposedWindows'])
  assert.equal(typeof report[field], 'boolean');
const checks = {
  firstTouchIDVisible: report.firstTouchIDVisible,
  secondTouchIDVisible: report.secondTouchIDVisible,
  noExposureDuringActivation: !report.swipeDuringActivationExposedWindows,
  firstGesturePrivate:
    typeof report.firstGestureExposedWindows === 'boolean' ? !report.firstGestureExposedWindows : null,
  secondGesturePrivate:
    typeof report.secondGestureExposedWindows === 'boolean' ? !report.secondGestureExposedWindows : null,
};
console.log(
  JSON.stringify(
    { kind: report.kind, checks, boundary: 'Owner-observed physical gestures; untested fields cannot pass.' },
    null,
    2,
  ),
);
if (!Object.values(checks).every((value) => value === true)) process.exitCode = 1;
