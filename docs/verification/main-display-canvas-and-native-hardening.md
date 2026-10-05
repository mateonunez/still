# Main-display canvas and native session hardening

Date: 2026-10-05. Candidate: `out/Still-preview.app` (ad-hoc development build).

## Result and boundary

The editor now follows the same macOS main display as the curtain. Each hosting view uses its own panel viewport. Canvas modules are measured, fitted into a protected content area and moved away from collisions; Balanced, Focus and Dashboard presets are available. Saved placements are not automatically rewritten.

The reported inheritance of the largest monitor's dimensions was **not reproduced** by the panel/hosting-view regression. The editor's focus-display selection differed from the curtain's main-display selection; that mismatch was corrected. The original screenshot still requires a physical comparison on the affected display arrangement.

Candidate executable SHA-256: `31ca07bb70e3231f4e8116317b35029a49e1602d070dbf009a7a8223e9417c62`.
The running owner candidate was preserved; its executable remained `a7eb5db53e078626f2e8f88d06d919daa6281d26f7a21153761b581c0f645d62`.

## Implementation

- Hosting views disable automatic sizing constraints and take the panel-local viewport. The editor and curtain use `CGMainDisplayID`, rather than the currently focused screen. Apple documents [hosting-view sizing options](https://developer.apple.com/documentation/swiftui/nshostingview/sizingoptions), [main display identity](https://developer.apple.com/documentation/coregraphics/cgmaindisplayid()) and [focused main screen behavior](https://developer.apple.com/documentation/AppKit/NSScreen/main).
- Canvas layout measures actual card heights, caches geometry, clamps placements and searches for nearby free space. If a requested scene cannot fit without overlap, it retries a balanced composition. Insufficient space remains possible; the editor reports crowding and suggests smaller/fewer modules. A mask protects the header and return controls, whose reserved height follows their measured content.
- Dragging starts from the rendered position. Directional controls remain available. Preset selection explicitly saves a new scene; automatic fitting does not modify saved normalized centers.
- Four-slot reservations include connected metadata before payload arrival. Disabled native sources do not consume capacity. Canvas task summaries report omitted task counts.
- Presentation options can be reasserted without losing the original restoration point. They remain owned through the system-password dialog; cancellation/retry restores panel focus and prepares fresh embedded authentication. This is not proof that the compositor or password dialog behaves correctly under physical gestures.
- An owned local user-activity declaration renews every fifteen seconds only while covered, alongside the existing system/display assertions. Stop, suspend and return release ownership. Apple exposes [IOPMAssertionDeclareUserActivity](https://developer.apple.com/documentation/iokit/1557127-iopmassertiondeclareuseractivity); no documented guarantee or automated check here establishes one-hour screensaver suppression.

## Verification

65 Swift tests passed: SessionKit 37, StillNativePlugins 14, macOS host 14. `pnpm check` and whitespace checks passed.

Three regressions failed before their corresponding fixes and passed afterward: disabled remembered-visible plugins occupying slots; changed presentation options not being reasserted; and overlapping cards in the 1024×768 Focus composition. The hosting viewport regression passed before the sizing change, so it does not establish the original reported cause.

The exact candidate passed **17/17 native collection checks**. Nine providers returned real payloads, including Build Watch, which recovered after earlier GitHub DNS timeouts. Next Up remained `permissionRequired`; its check verifies the explicit consent/selection boundary, not access to calendar events. The probe uses scratch configurations and read-only agent sources without installing bridges or changing owner settings.

Evidence is excluded from Git under `out/verification/native-collection/2026-10-05T17-21-22.411Z/`. The export set covers three presets at 1512×982, 2560×1440 and 1024×768, plus appearance previews. The final narrow Focus export was visually inspected: four separate cards, a centered clock and protected return area. Exported views do not prove native glass, interactive buttons or biometric rendering.

The exact candidate passed **17/17 isolated energy checks**, recorded under `out/verification/responsive-canvas-accepted-source-energy/`. These check assertion ownership, expiry, cleanup and kernel-visible requests. They do not invoke the new local-activity declaration or demonstrate elapsed inactivity behavior. The activity cadence/cleanup was tested with an injected clock/driver, including a simulated hour.

## Joint acceptance still required

Use the [beta-readiness guide](../guides/beta-readiness.md) for the next joint trial: actual display arrangement/scaling, preset selection and saved drag/keyboard placement; Touch ID and visible system-password cancel/retry; activation-time desktop swipes and Mission Control; one-hour AC/battery inactivity, system lock and sleep/wake; Calendar consent/selection; and fresh installation, permission revocation and accessibility. No signed/notarized beta is produced by this phase.
