# Phase 2 — Inactivity and energy evidence

Date: 2026-10-04. Status: **implemented, domain-tested and native assertion lifecycle verified; human UI/hardware acceptance pending.** Phase 1 authentication, visual polish and large-screen findings remain open.

Subsequent product update: awake/display controls are now hidden, with code/tests retained. This report and its hash describe the earlier visible-control candidate. [Current candidate and Spaces findings](phase-02-deferred-awake-and-spaces.md).

## Delivered behavior

| Control | Initial default | Behavior |
| --- | --- | --- |
| After inactivity | Never | Choose 1/3/5/10/15/30 minutes; one-second elapsed-input polling while enabled |
| Keep Mac awake | Off | Explicit 15/30/60/120-minute session, countdown and Stop |
| Keep displays on | Off | Saved preference, applies only during an awake session; toggles only the display request |

Menu controls and a Porcelain preferences window are implemented. No foreground-app/agent activity reader, accounts or network telemetry are added. No Mac energy setting or lock policy is modified. Active awake sessions are not persisted. Idle/display preferences are local and remain restored after explicit user configuration.

Showing/returning from Still does not start/stop an awake session. Expiry does not dismiss the curtain. After successful authentication the idle interval starts fresh, including when Touch ID does not reset the global input-age scalar. Sleep/session resignation ends awake requests; resume does not restart them and grants a fresh idle interval.

The app holds named IOKit requests, not a guarantee of CPU progress or prevention of every kind of sleep. Display requests inherently affect idle system sleep. The OS can override requests for explicit sleep, lid behavior or safety. [Apple assertion scopes](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes).

## Exact build and reproduction

- Host: Mac16,7, arm64, macOS 26.5.2 (25F84), one reported display, logical 1728 × 1117.
- Swift 6.3.3; ad-hoc signed personal development identity `co.mateonunez.still.development`.
- Candidate: `out/Still-preview.app`; executable SHA-256 `bc8d5128b06e4af9ac119811face0a0ed1ee05553147702546340c055b193486` (after native-material refinement).
- No Developer ID/notarization/public installer or verified macOS 14/Intel support claim.

```sh
./scripts/build-macos.sh debug Still-preview
swift test --package-path packages/SessionKit
python3 scripts/verify-native-energy.py
python3 scripts/verify-native-runtime.py --app Still-preview \
  --output out/verification/phase02/presentation
```

Each native probe launches/stops its own subprocesses. The energy probe holds short finite requests for a few seconds without a curtain, credential request, preference write, input synthesis or forced sleep. It normalizes pmset facts only for its own PID and discards other process names. The presentation probe temporarily presents its own curtain and disables biometric evaluation. Never treat either probe as manual interaction acceptance.

## Verified

**29 Swift Testing tests passed.** Added coverage for disabled/startup inactivity, fresh interval after biometric return, duplicate activation, invalid samples, unavailable sessions, exact deadline, independent display toggling, partial-acquisition rollback, retained/retried cleanup failures, replacement without leaked IDs, and invalid-duration rejection without ending an existing valid session.

**11 native energy checks passed:**

| Native check | Observed |
| --- | --- |
| Initial EnergySession owns no requests | Pass |
| System-only request acquired, active | Pass |
| Display request acquired without replacing system ID | Pass |
| Stopping display releases that ID; system remains active | Pass |
| Manual Stop releases system ID | Pass |
| Application expiry releases both IDs | Pass |
| OS timeout releases a request without app polling | Pass |
| Releasing an already-expired ID is safely handled | Pass |
| Combined-session idle scalar finite/nonnegative on this host | Pass |
| pmset reports this process's PreventUserIdleSystemSleep | Pass |
| pmset reports this process's PreventUserIdleDisplaySleep | Pass |

The main native probe session was six seconds; its system assertion had an eight-second OS timeout. The later display request's timeout used the remaining deadline plus two seconds. The separate timeout-only probe requested one second and observed disappearance after 2.2 seconds without EnergySession polling. These measurements prove request lifecycle, not a Mac remaining awake for a full 120-minute production session.

**8 structural presentation checks passed** for this exact binary: app stays alive, one panel per display, frame equality, isVisible flags, actual level 1000, font registration, external synthetic progress and owned-process termination. The hashing subprocess advanced 1 → 2,575,544 → 3,273,747 across its probe interval. This does not prove every app's continuation.

Ignored local receipts: `out/verification/phase02/energy.json` and `presentation/runtime.json` / `presentation/smoke.json`. App renders are not desktop screenshots. The preferences export contains unsupported native-control placeholders from ImageRenderer and is **rejected as UI evidence**; do not use it for the landing or a release screenshot. The real app uses system Picker/Toggle controls and needs live inspection.

## Native materials refinement

`StillMaterials` uses SDK-native `.glass` / `.glassProminent` button styles on macOS 26, burgundy tint, and standard bordered controls on older systems or with Reduce Transparency. Welcome/preferences use a restrained regular-material surface with a Porcelain overlay, transparent service-window backgrounds and unified titlebar appearance. Service surfaces become solid for Reduce Transparency or Increase Contrast. The status capsule pairs a symbol with text, and the display preference uses a native switch.

Only service windows are non-opaque. The curtain panel and its full-size Porcelain surface stay opaque. No forced focus or custom focus outlines are added; no new animated transitions are introduced. The embedded system biometric control remains system-owned. Availability guards preserve the provisional macOS 14 compile floor; this does not establish runtime support on that OS.

The API choice follows [Apple's native custom-control guidance](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views) and [material guidance](https://developer.apple.com/design/human-interface-guidelines/materials), with availability checked in the installed SDK. `node scripts/check-contrast.mjs` passes canonical token pairs in both appearances. Token contrast does not measure dynamic glass/backdrop rendering; live light/dark, Increase Contrast, Reduce Transparency, keyboard and VoiceOver review remain pending. ImageRenderer output is not accepted as proof of live glass appearance.

## Failures corrected during development

- Swift 6.3.3 crashed in IR generation for the initial large preference view. Splitting it into section/duration helpers and explicit Binding setter closures made the exact app-build command pass. No compiler bug report was published.
- IOPMAssertionCopyProperties returns an Unmanaged CFDictionary. Consume the retained value before bridging; do not cast the wrapper to a Swift dictionary or leak the copied reference. Unwrap the assertion-level number explicitly. Rebuilt successfully.
- pmset contained non-UTF-8 bytes. The first observer failed decoding and terminated only its probe process. The observer now decodes tolerantly, selects only its own PID/name and records normalized ASCII assertion types. The exact failed `python3 scripts/verify-native-energy.py` command subsequently passed.

## Human acceptance still needed

Follow [the energy guide](../guides/idle-and-energy.md).

| Case | Status |
| --- | --- |
| Real menu/preferences labels, bindings and countdown updates | Pending |
| Native glass, light/dark, keyboard/VoiceOver, Reduce Transparency and Increase Contrast | Pending live UI acceptance |
| First-use defaults and restored user preferences | Pending live fresh-profile check |
| Actual one-minute idle activation and input reset | Pending |
| No immediate re-cover after real Touch ID/password dismissal | Pending |
| Fresh install with no Accessibility/Input Monitoring permission | Pending; current-host scalar is not TCC proof |
| Display sleep allowed with system-only request | Pending actual timing |
| Display held on only during the chosen awake session | Pending actual timing |
| Long-duration countdown, expiry and wall-clock change | Pending native endurance; monotonic model verified |
| AC/battery transition, low battery, manual Sleep and lid closure | Pending hardware run |
| Real session switch/system lock interaction | Pending |
| Quit/crash and no remaining owned assertions in the interactive session | Pending live recovery check |
| Large screens, multiple monitors, Spaces/fullscreen and smooth transitions | Still open from Phase 1 |

No app-specific assertion remains after the completed probes. Unrelated applications can legitimately continue preventing sleep. The development candidate is ready for manual review; Phase 2 is not yet marked human-accepted.

Tooling update: Python invocations above are historical receipts. Current equivalents use Node; see the [preview/tooling guide](../guides/design-preview.md).
