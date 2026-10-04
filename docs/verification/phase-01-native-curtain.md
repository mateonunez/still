# Phase 1 — Native curtain evidence

Date: 2026-10-04. **Step 1A: built and structurally verified. Step 1B: native interaction/hardware acceptance pending. Phase 1 is not accepted yet.**

## Delivered

A real local `out/Still.app`, compiled from SwiftUI/AppKit, with a pause icon in the menu bar, manual curtain presentation, Porcelain light/dark/system appearance, a shared per-display coordinator and system-owned LocalAuthentication dismissal. Appearance is the only persisted setting. No power assertion, inactivity timer, app-activity reader, network client or agent integration is included.

The pure `SessionKit` package rejects duplicate authentication attempts and stale callbacks. Sleep/session changes suspend presentation and require a fresh attempt when resumed. Screen-topology changes invalidate the in-flight attempt and rebuild the panels. These latter cases are domain/implementation evidence until exercised on actual hardware.

Local signing verification: `codesign -dvv out/Still.app` reports `Signature=adhoc` and `TeamIdentifier=not set`.

Local identity: `co.mateonunez.still.development`. Proposed release identity: `co.mateonunez.still`, not yet confirmed for distribution.

## Environment and artifact

- Host: Mac16,7, arm64, macOS 26.5.2 (25F84).
- Swift: 6.3.3; Xcode selected at `/Applications/Xcode.app/Contents/Developer`.
- One reported display, logical screen frame 1728 × 1117 at origin 0,0.
- Development executable SHA-256: `4c5a7d6aa4c530530f46ee93e802fcf0a4d5b114f9b1d75e37395469e468d47e`.
- Bundle: `out/Still.app`, version 0.1.0, build 1, ad-hoc signed. No Developer ID, notarization, hardened-runtime release configuration, public installer or universal binary claim.
- macOS 14 is a provisional deployment floor; this report verifies only the listed host.

Rebuilding can change the executable hash. The opt-in runtime probe regenerates ignored receipts and stops only its own app/workload subprocesses. It temporarily presents the curtain; avoid running it during a sensitive interaction.

## Reproduce

```sh
./scripts/build-macos.sh
swift test --package-path packages/SessionKit
python3 scripts/verify-native-runtime.py
node scripts/check-contrast.mjs
```

| Check | Observed result | What it establishes |
| --- | --- | --- |
| Native compilation and bundle assembly | Pass | Real Swift executable and `.app` structure |
| Ad-hoc code-sign verification / Info.plist | Pass | Local bundle integrity; not distribution trust |
| Swift Testing | 10 tests passed, including a two-case cancellation/failure test | Session transitions, single-attempt ownership, stale callbacks, suspension and termination |
| Native process launch | Pass | The built app stays running while panels report visible |
| Panel count and frame | 1 panel / 1 screen; exact frame match | Window geometry from AppKit; not visible coverage of all surfaces |
| Curtain window level | 1000, matching `NSWindow.Level.screenSaver` | Configured high-level presentation |
| Font registration | Pass | Bundled Instrument Serif registered for this process |
| External synthetic workload | Iterations 1 → 2,852,807 → 3,326,993 before/during/after | One hashing subprocess made progress across the structural probe interval |
| Owned-process termination | Pass | Probe app stops; no child app/workload left running |
| Native view exports | Light and Dark PNGs inspected, 1440 × 900 | Same SwiftUI source rendered with real font/palette; not desktop screenshots |
| Semantic palette contrast | 26 pairs pass | Color-role ratios; not a full native accessibility audit |

Local artifacts (ignored by Git): `out/verification/phase01/runtime.json`, `smoke.json`, `launch.log`, `porcelain-light.png`, `porcelain-dark.png`. Images are produced with SwiftUI ImageRenderer from Still's own view, without capturing another app or the desktop. [Apple ImageRenderer](https://developer.apple.com/documentation/swiftui/imagerenderer).

## Defects found and corrected

1. Swift Testing's macros attempted to call mutating methods on immutable captures. Evaluating the operation before asserting its result fixed compilation; the exact failed `swift test --package-path packages/SessionKit` command subsequently passed.
2. The first AppKit receipt reported window level 0: setting `NSPanel.isFloatingPanel` after assigning the level reset it. Set the curtain level after panel configuration and assert every panel's actual level. The rerun reported level 1000 with all eight structural checks passing.
3. Fresh exports now remove only the probe's old generated image/receipt files before running, preventing stale output from satisfying the readiness check.

## Native UI verification blocker

The computer-use tool did not recognize the app by path, bundle ID or display name, even after setting the development identity and registering the bundle with LaunchServices. Its app inventory did not include Still. The process and in-process structural receipts are verified; the agent has not observed the real rendered desktop through that tool. No system-authentication prompt, cancellation or success is claimed as tested.

The app does not contain a credential bypass. During authentication it intentionally lowers its panel levels so macOS can display the credential dialog. Coverage in that interval is best-effort and must be observed manually. Ordinary quit/Force Quit can always expose the desktop.

## Step 1B — Human acceptance still required

Follow [the native preview guide](../guides/native-preview.md). For each case record the actual result, host/build and any exposed desktop; leave untested cases explicitly pending.

| Native case | Status |
| --- | --- |
| Menu icon, Light/Dark/System selection and actual on-screen rendering | Pending manual observation |
| OS dialog visible above curtain | Pending |
| System-authentication success, cancel/retry and failure | Pending |
| Touch ID / password fallback / unavailable biometrics | Pending on relevant hardware |
| Return restores the previous app | Pending |
| Keyboard focus, Return, Tab, VoiceOver announcements, Command-Q | Pending |
| Multiple monitors, secondary-screen authentication | Pending; only one display observed |
| Spaces, full-screen apps, Mission Control, Stage Manager | Pending |
| Screen attach/detach during coverage and authentication | Pending |
| Actual macOS lock/unlock, session switch, sleep/wake | Pending |
| Representative build, transfer, media and agent workload | Pending; synthetic progress is insufficient |
| Force Quit/crash and restored appearance | Pending visual recovery check |

The app is stopped after the automated probe, leaving the user's desktop available. Open it manually to continue Step 1B. Step 1A is ready for review; the phase is not accepted and Phase 2 remains unstarted.
