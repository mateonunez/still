# Curtain display-on refinement

Date: 2026-10-05. Status: local candidate; prolonged screen-saver acceptance pending.

## Finding and change

A screen saver was reported after approximately one hour of inactivity with Still active. The prior curtain acquired only PreventUserIdleSystemSleep. Apple's SDK explicitly permits display dimming/sleep with that assertion. It therefore did not meet a continuously visible curtain requirement. The report alone does not establish whether the OS screen saver or security lock appeared, or whether an assertion had been interrupted.

The curtain now owns one indefinite PreventUserIdleDisplaySleep request, which also prevents idle system sleep. Its existing ownership, retry and cleanup rules remain unchanged. No user activity is synthesized, no preferences are changed and no screen-saver process is terminated. Explicit sleep, lid closure, user-session resignation and OS overrides retain authority. This is a display-on candidate, not proof of universal screen-saver suppression.

## Evidence

Candidate: `out/Still.app`, ad-hoc signed development build. SHA-256: `8787720697ea16cc2d5c61722b7ab1f3ef2c24353764de9f496572e0ae149824`. The running owner preview was not overwritten or terminated.

- Regression: `swift test --package-path packages/SessionKit --filter curtainLifetimeDoesNotExpireOrStack` failed before the change: acquired `.system`, expected `.display`.
- All 34 SessionKit tests pass after the change, including no stacking, failure retry, cleanup, resume and independent timed-session ownership.
- 17 real native energy checks pass: correct display assertion type, no timeout, ID preservation, release/resume, independent finite requests, OS expiry and PID-scoped pmset checks.
- 12 native structural checks pass, including exactly one PID-owned display request while covered and removal after the probe exits. These are not physical gesture or prolonged idle tests.

Receipts remain local under `out/verification/curtain-display-awake/energy` and `out/verification/curtain-display-awake/native`, with exact hashes. The [Apple public header](https://github.com/apple-oss-distributions/IOKitUser/blob/main/pwr_mgt.subproj/IOPMLib.h) documents display-idle and implicit system-idle prevention; it does not promise all screen-saver/security-policy outcomes.

## Reproduce and accept

```sh
swift test --package-path packages/SessionKit
./scripts/build-macos.sh debug Still
node scripts/verify-native-energy.mjs --app Still --output out/verification/curtain-display-awake/energy
node scripts/verify-native-runtime.mjs --app Still --output out/verification/curtain-display-awake/native
```

Quit running Still instances yourself before opening `out/Still.app`. Activate the curtain and leave the Mac unattended beyond the existing screen-saver interval and for at least one hour. Do not change OS settings for the trial. Confirm the curtain is still visible, the display remains on and a background task continued. Record AC/battery, elapsed time and whether an actual saver, OS lock or display-off appeared. Verify Touch ID return and system-password return separately, including cancellation and Sleep/wake. Only then accept the prolonged behavior. Trackpad/authentication boundaries remain independent open findings.
