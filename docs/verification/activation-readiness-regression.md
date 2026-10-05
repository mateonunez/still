# Activation and embedded authentication regression

2026-10-05. Status: two native lifecycle defects corrected; original physical authentication/gesture acceptance pending the new candidate.

## Reproduction

The guided owner trial on executable SHA-256 `622c4433dad26cf93e3d9a9ca70c7772d1e2d18156422eac1744c0a232bd870f` reports:

| Trial | Touch ID visible | Underlying windows exposed |
| --- | --- | --- |
| First activation, no swipe during setup | No | No during later gesture trials |
| Second activation, no swipe during setup | Yes | No during later gesture trials |
| Swipe coinciding with activation | Not separately captured | Yes |

Replay `node scripts/verify-native-interaction.mjs --report out/verification/interaction-trial/owner-trial.json` exits 1. This is physical owner observation, not automated gesture synthesis.

The state trace shows five window/context preparations within approximately 100 ms at first cover. A readiness callback starts evaluation while the current biometric child has no window. Second cover evaluates with the child attached. During the failed swipe trial, active Space changes and Still loses active/key status while presentationOptions remains 38. Flags being present therefore do not establish privacy coverage.

## Corrections

1. Compare display ID, full frame and backing scale before handling screen-parameter notifications. Dock/menu visible-area changes do not replace the curtain or authentication context. Guard reentrant construction; reconcile an actual topology change after construction. Keep presentation-policy ownership across panel rebuilds and clear saved ownership before restoring AppKit options.
2. Validate attachment of the actual LAAuthenticationView, not just its container. Mark readiness only after a valid notification; allow a later attached update to retry readiness. The coordinator additionally requires its current view, active app and owned key window before starting a new attempt. Activation/key notifications can finish a previously waiting setup; no focus-stealing loop or automatic failed-authentication retry is introduced.

## Red/green evidence

- `swift test --package-path apps/macos --filter detachedBiometricChildMustNotStartAuthentication` initially failed with starts=1 for a detached child. After correction, it passes with starts=0 while detached and exactly 1 after reattachment, despite repeated checks.
- A second native-module test verifies unchanged-topology/reentrant notifications are skipped while move, scale, unplug and new-session changes are accepted. Both tests pass and are in CI.
- `node scripts/verify-native-runtime.mjs --app Still --output out/verification/activation-before` reproduces five panel generations and exits 1 on the unchanged-topology check, with biometrics deliberately disabled in the owned probe.
- The exact same probe using `--app Still-preview --output out/verification/activation-after` passes all 12 checks with one panel generation. Six separate AppKit presentation/restoration checks also pass. Controlled workload and owned awake-assertion checks pass.
- Native build/ad-hoc signature verification and Biome pass. Existing unrelated website/plugin behavior is not reclassified as authentication proof.

New frozen candidate `out/Still-preview.app/Contents/MacOS/Still` SHA-256: `7257c18eef82883dfd1a25234e3c5058fa85ef48a69572c27af50353cde793b6`. The older user-owned `out/Still.app` process was not terminated or replaced. Raw state traces and probes remain ignored/local.

## Remaining acceptance

Run `node scripts/verify-native-interaction.mjs --app Still-preview`. It asks the owner to quit older instances, launches this candidate and preserves separate receipts under `out/verification/interaction-trial/Still-preview`. Check the original first/repeated/swipe-during-activation cases plus real Touch ID and system-password cancel/retry.

These corrections establish lifecycle/readiness behavior, not successful physical Touch ID or a blanket Spaces swipe veto. Public AppKit presentation options remain active-app scoped. No persistent Trackpad preference change, private API, input interception or recovery suppression was added. If a Space transition still exposes a window, that trial remains failed rather than inferred safe from flags or tests. Signing/notarization remains deferred.
