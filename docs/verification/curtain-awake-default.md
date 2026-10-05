# Automatic curtain awake — verification

Date: 2026-10-05. Scope: local development candidate, not a release or production website delivery.

Historical system-only candidate. Its display-sleep behavior is superseded by the [display-on refinement](curtain-display-awake.md); the results and hash below remain evidence for the original candidate only.

## Result

Still automatically owns one system-idle-sleep assertion while covered. Return, suspend and teardown release the request; display changes preserve it. Resume restores it only for a requested curtain. No duration or user-facing toggle is needed. Display sleep remains normal. Independent finite controls remain hidden.

Candidate: out/Still-preview.app. Executable SHA-256: 926b3e8400aacf965afd8dc093555a95a025c2555af278f74f87388f850e5006. Ad-hoc signature verified by the builder.

## Passing evidence

- 34 Swift domain tests, including acquisition failure/retry, cleanup failure/retry, repeated coverage without stacked IDs, OS-ended requests and independence from timed sessions.
- 16 native energy checks: real IOKit acquisition with timeout 0, same ID across repeated requests, release/reacquisition and retained timed/display behavior with pmset cross-checks.
- 11 native runtime checks: one panel per reported display, geometry/visibility/level/font, synthetic work progress, active curtain assertion, exactly one matching PID-owned system request in pmset, and removal after the owned probe process terminates.
- Website TypeScript and Biome checks pass for updated product copy.

Local receipts: out/verification/curtain-awake/energy/energy.json and out/verification/curtain-awake/native/smoke.json. They reference the exact candidate hash above. Probes launch and stop only their own processes and do not authenticate, force sleep or change power preferences.

## Corrections during verification

SwiftPM's existing app build plan initially omitted the new dependency source; cleaning that generated app build and repeating the exact builder passed. The first runtime pmset check failed because matching the Unicode assertion title differed from pmset output. Matching the process PID and stable ASCII name words corrected the verifier; the exact runtime command then passed on the final candidate.

## Open native acceptance

Confirm Touch ID and system-password return remove the curtain request in the actual app. Cancel authentication and confirm it remains. Observe actual unattended idle system/display behavior on AC and battery, manual Sleep/wake, user-session switch, and a display change. The native probe exercises the assertion lifecycle, not these complete human workflows. Gesture/Spaces coverage remains an independent known issue; these checks do not establish a trackpad fix.

## Reproduce

```sh
swift test --package-path packages/SessionKit
./scripts/build-macos.sh debug Still-preview
node scripts/verify-native-energy.mjs --output out/verification/curtain-awake/energy
node scripts/verify-native-runtime.mjs --app Still-preview --output out/verification/curtain-awake/native
pnpm check
pnpm typecheck
```

Quit the previously running Still before opening the rebuilt preview. See [the guide](../guides/idle-and-energy.md) and [ADR 0006](../adr/0006-curtain-owned-awake-default.md).
