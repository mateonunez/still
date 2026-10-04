# Developer practices

## Native vertical slice

The native app lives in `apps/macos`; session rules live in the local `packages/SessionKit` Swift package. SwiftUI renders the curtain, AppKit owns all display panels and the menu bar, and LocalAuthentication owns the credential UI. Phase 1 uses SwiftPM to build an actual app bundle without adding a project-generator dependency. An Xcode package workspace can open both packages; a distribution target/signing configuration remains a later deliverable.

Use Swift 6 concurrency checks. Keep AppKit and observable presentation state on the main actor. Normalize authentication results before crossing back to the UI. One session and one authentication attempt serve all displays. Old callbacks must never clear a newer session; invalidate attempts when the screen topology or OS session changes.

Never collect a Mac password, introduce a hidden dismissal bypass, or intercept global system recovery shortcuts. Termination necessarily removes the app's windows. During system authentication the panels lower their window level to avoid obscuring the credential dialog; desktop coverage during that interval is best-effort and requires native validation.

## Build and verification

From the workspace root:

```sh
./scripts/build-macos.sh
swift test --package-path packages/SessionKit
node scripts/check-contrast.mjs
```

The build produces `out/Still.app` with an ad-hoc local signature. This is not Developer ID signing, notarization or an end-user installer. `out/` and SwiftPM `.build/` directories are ignored. macOS 14 is the provisional compile/deployment floor, not a verified support claim. The current host is arm64; Intel support is unverified.

`design/tokens.json` is canonical. Run `node scripts/generate-native-tokens.mjs` when tokens change; the app build also regenerates the native palette. Native controls use system type. Register the bundled Instrument Serif only for the current process and include its license; never install fonts globally.

Swift Testing macros can capture a method receiver by value. Evaluate mutating session operations first, then assert the result; this avoids immutable-receiver macro expansion errors while keeping assertions meaningful.

## Evidence discipline

Domain tests verify transition logic, not LocalAuthentication, Spaces or display coverage. Launch the built `.app` and observe its actual UI. Record the exact executable hash, macOS build and display setup. Use a controlled synthetic workload for progress observations; never inspect private agent conversations or claim all apps continue based on one workload.

Authentication success must be completed interactively through the macOS dialog. Automated inspection can verify prompt presentation, cancel/retry and visible state without obtaining the account password. Multi-monitor, Spaces, Mission Control, Stage Manager, system lock and sleep/wake remain separate acceptance cases.

Keep network calls, analytics, agent discovery, activity collection and power assertions out of Phase 1. No permissions are requested speculatively. The local identity is `co.mateonunez.still.development`. `co.mateonunez.still` is a proposed release identity. Developer ID credentials, the final bundle identity and update policy belong to explicit decisions; local development success does not establish distribution readiness.

## Inactivity and finite energy sessions

Phase 2 adds power assertions as an independent vertical slice. Keep idle decisions and assertion ownership in SessionKit; OS bridging lives in the native target. Inject a monotonic clock into domain rules. Use ContinuousClock for elapsed session deadlines across sleep; never use wall time to extend an awake session. Start disabled and persist only deliberate idle/display choices, never a running awake session. Reset the idle grace interval after return/resume so biometric input cannot immediately re-cover using an old global idle age.

Use the CoreGraphics elapsed-input scalar only while enabled. Do not record input contents, install an event tap or request speculative Accessibility/Input Monitoring permissions. Scalar availability on a configured development host does not establish fresh-install permission behavior.

Acquire finite named IOKit assertions with OS timeout-release safety. Release only owned IDs, retain/retry failures, roll back partial acquisition and avoid replacing a session while cleanup is unresolved. A failed request must not produce a false active label. Display intent only adds a request during an explicit awake session. End requests on Stop, expiry, sleep/session resignation and teardown; do not restart on wake. Always consume the retained CFDictionary before bridging IOPMAssertionCopyProperties.

`python3 scripts/verify-native-energy.py` runs a bounded own-process probe and cross-checks only its own pmset records. Discard unrelated process names and tolerate non-UTF-8 output. Native lifecycle proof is separate from real display/sleep timing, lid behavior, battery transitions and endurance. Update exact artifact hashes after UI rebuilds before attributing runtime evidence to a candidate.

## Native materials

Use availability-guarded native macOS 26 glass button styles for important controls; keep the curtain opaque. Vibrancy belongs in welcome/preferences service surfaces, with solid fallbacks for Reduce Transparency and Increase Contrast. Preserve standard native focus and semantic controls; do not add forced initial focus or hide focus rings. Keep styling in `StillMaterials`, not repeated availability branches throughout features.

ImageRenderer cannot faithfully export live native Pickers, Toggle switches, biometric NSViews or material backdrops. Reject unsupported-control images as UI/marketing evidence. Native compilation and token contrast are useful checks, but live material/accessibility acceptance remains a separate gate. Split complex SwiftUI sections when compiler type/IR generation becomes unstable, then rerun the exact failed build.

## Deferred product controls and compositor behavior

Keep retained functionality behind an explicit product-availability flag when its product concept is deferred. Gate every entry point and current product copy; preserve implementation, tests and saved choices. Do not invent a new combined energy/inactivity policy before its behavior is selected.

Record live collectionBehavior getters, not only assignments. Mission Control and trackpad animation exposure need a native red-capable reproduction; flags, isVisible and frame equality are not evidence of compositor coverage. Native app handles should use the full app path when development bundles share an identifier. App-window screenshots are not whole-desktop-transition evidence. Never use `.transient` as a coverage fix: it hides the window in Mission Control. Keep private desktop captures out of the repository.

## AppKit regression learned in Step 1A

Set `NSPanel.level` after configuring `isFloatingPanel`: the original order reset the level to `.normal`. Verify the getter in the live app, not only the assignment in source. The runtime probe checks panel count, frames, visibility flags, actual window level, font registration and synthetic subprocess progress; these remain structural evidence rather than a desktop coverage test.

Run `python3 scripts/verify-native-runtime.py` after the app build to regenerate local native view exports and receipts. It creates and terminates its own app/workload only, and makes no credential request. Exported PNGs are native SwiftUI view renders, not screenshots of the real desktop. The `--evidence-directory` argument is opt-in; normal launches write no diagnostic files.

## Embedded authentication and menu state

Create one `LAAuthenticationView` for a fresh biometric LAContext; attach it to the initiating display, then evaluate after `viewDidMoveToWindow`. Pass the exact view through the readiness callback and compare identities before evaluation; a readiness callback from a removed view must not start a newer context prematurely. Do not attach the same context to multiple display controls.

Password fallback uses a separate context without an embedded view. The SDK documents that embedded owner authentication still fails when no biometric/companion mechanism is available. Never build an app-owned Mac-password field. Invalidate the old session attempt before switching methods, and reject late results. A canceled or failed attempt stays covered and does not automatically loop.

Derive menu state from the session; keep one primary action, disable duplicate system-dialog attempts and preserve Quit. Development metadata belongs in About. Keep first-launch discovery visible without unsolicited notifications or permission requests. Native menus and authentication need human validation even when the domain-state tests pass.

Build a separate candidate with `./scripts/build-macos.sh debug Still-preview` without replacing an app under interactive testing. Binary replacement uses a new file plus rename rather than truncating a potentially mapped executable. Probes must terminate only their own subprocesses. `python3 scripts/verify-native-runtime.py --app Still-preview` stops only its own subprocesses and avoids biometric evaluation. `--render-only` produces source-view exports without presenting a curtain.

## Focus and embedded-view sizing

Do not force focus onto a secondary password action during biometric-first presentation, and do not stack a custom outline over the native focus effect. Preserve native Buttons, keyboard shortcuts and focus behavior; never change OS accessibility preferences for appearance. Bind both dimensions of an embedded AppKit control to its SwiftUI host, not just its center. Validate live controls separately: native view exports use an illustrative fingerprint and cannot reveal overflow of the system NSView.
