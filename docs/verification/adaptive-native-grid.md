# Adaptive native Grid and Free layouts

2026-10-05. Candidate: `out/Still-canvas.app`.
Executable SHA-256: `3de50a3f947a4a4c81b06393ac212908c7835c24cfc1a4f96aaa1d87714b747e`.

## Result

The canvas now exposes explicit Grid and Free modes. Grid uses SwiftUI Layout with equal-width columns, measured row heights, consistent twenty-point gaps and centered wrapping. Clock and return controls have separate regions. Automatic columns respond to display width and module count; a continuous preferred-column-width control is available. Grid does not perform the Free nearest-vacancy search. See [ADR 0010](../adr/0010-adaptive-grid-and-free-canvas.md).

Grid drag/drop changes order only over a real target; movement is measured in canvas coordinates, and centers stay fixed while dragging. Drops insert at the target's position in either direction. Keyboard buttons insert one item horizontally or one row vertically. Free retains continuous movement/resizing and presets. A mode switch preserves manual placements/widths and never enables a source or adds visible modules. Legacy scenes remain Free; new scenes/reset use Grid.

## Evidence

21 StillNativePlugins tests and 16 macOS host tests passed. Coverage includes aligned row starts/gaps, centered clock, wrapping from viewport width, empty/single/four/ten-module scenes, overflow without cell overlap, legacy-mode decoding, mode/width round-trip, drop hit-testing, whole-row insertion and preserved Free placements. Existing provider/capacity/presentation/viewport regressions passed. These tests do not establish perceived smoothness or a frame-rate target.

The exact candidate passed 19/19 native collection checks, including retention of all selected modules in Grid. Nine source payloads were real; Calendar remained at its consent/selection boundary. Probe configurations were scratch-owned and no source bridge was installed by diagnostic reads.

Ignored evidence lives under `out/verification/native-collection/2026-10-05T17-59-07.628Z/`. Grid exports cover four and ten cards at 1024×768, 1512×982, 1920×1080 and 2560×1440. Four-card and ten-card large-view geometry was visually inspected, including the final ten-card export and editor. Columns/row starts align; each card keeps its own content-driven height. ImageRenderer placeholders cannot establish native control/glass rendering.

On the narrow ten-module view, content exceeds available height. The editor reports crowding; the protective mask can clip excess rows. This phase does not implement pagination or a scrolling canvas, and does not claim universal fit. Reduce preferred column width or choose fewer visible modules on that display.

Build, ad-hoc signature verification, Biome/whitespace checks and the website production build passed. An initial Swift compiler crash in the expanded editor was resolved by splitting its toolbar into smaller computed views; compilation and tests then passed. Current guides/website copy describe both modes. The running `Still-preview.app` remained unchanged (SHA-256 `653cc43332e6fb56dd11729bc88930f31f7bd195b66b03c7c281f92c1961b9ea`).

## Interactive trial

Quit other Still instances, then:

```sh
open out/Still-canvas.app --args --editor
```

Choose Arrangement → Grid for existing saved scenes. Add desired enabled modules; test Automatic columns and manual preferred width at the actual main-display scale. Drag over a highlighted target in both directions and release; release over empty space and confirm unchanged order. Use directional buttons horizontally/vertically; switch to Free and check retained manual placements/widths. Reopen to check persistence. Test Reduce Motion, Reduce Transparency and keyboard/VoiceOver. Actual gesture smoothness, authentication/Spaces privacy and prolonged inactivity remain open. No signed/notarized beta was produced.
