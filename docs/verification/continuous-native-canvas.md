# Continuous native canvas

2026-10-05. Development candidate: `out/Still-canvas.app`.
Executable SHA-256: `8a6f7b6caf1296a5f11d9d2403430cca95e457a81230ecc161b59100eaaadd24`.

## Behavior

The canvas editor replaces Compact/Regular/Wide controls with continuous module width and an Automatic mode. Selected modules expose a horizontal resize handle; a native slider offers the keyboard alternative. Height follows measured content. Clock typography responds to width. Readability and viewport limits remain; this is not unconstrained free stretching.

Presets/reset create automatic widths. Legacy saved categories decode as their previous requested widths, retaining saved centers, while the legacy clock stays automatic. Explicit null persists Automatic without reverting to a legacy width after reload. Unknown, nonfinite or out-of-range values are rejected.

Free dragging no longer snaps to a twelve-column/eight-row grid. Directional buttons move one percent of the display. A resize gesture retains module centers and skips collision searching until release; temporary overlap is possible while editing. The original protected content mask remains. Saved layout changes use a short SwiftUI settling animation; pointer drag/resize/slider tracking is unanimated. [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) disables settling; [SwiftUI smooth animation](https://developer.apple.com/documentation/swiftui/animation/smooth) is used for layout changes.

The permanent grid is removed. The editor uses a two-row native control toolbar, native macOS 26 glass and opaque Reduce Transparency/increased-contrast fallbacks. Ready canvas cards omit diagnostic footers; unavailable/setup messages remain visible, and detail remains in the source preview and tooltip. No transparency is introduced into desktop coverage.

## Evidence

- 16 StillNativePlugins and 14 macOS host tests passed. New tests cover fractional widths/positions, Automatic round-trip, legacy migration and invalid-width rejection. Existing collision, viewport, capacity and authentication-readiness regressions passed. These are not performance measurements or proof of smooth physical interactions.
- `pnpm check`, whitespace checks, native build and ad-hoc signature verification passed.
- The exact candidate passed 17/17 native collection checks. Nine sources returned real payloads; Calendar stayed at the explicit permission/selection boundary. No permission grant is inferred.
- Ignored evidence: `out/verification/native-collection/2026-10-05T17-34-42.073Z/`. Final full-screen editor and narrow Focus images were inspected. Module geometry is separated and the toolbar fits the exported viewport. ImageRenderer produces placeholders for some native controls and does not prove glass or button rendering; these exports are geometry evidence only.
- Both running owner apps were preserved. The candidate was built separately because `Still.app` and `Still-preview.app` were running. Probes use scratch source configuration and do not modify the saved owner composition.

## Interactive acceptance

After quitting other Still instances, run:

```sh
open out/Still-canvas.app --args --editor
```

Select Clock and a plugin; resize slowly and quickly, move between Automatic and manual width, use the slider with keyboard arrows, change presets, reopen and check persistence. Check narrow/large main displays, light/dark, Reduce Motion and Reduce Transparency. Verify that the handle resizes rather than moves the module, that release fitting remains predictable and that no card/control is obscured. Keyboard-only and VoiceOver trials remain open. No frame-rate or perceived-smoothness claim is made before this trial. Previous physical gesture/password/idle acceptance also remains open. No beta is signed or notarized.
