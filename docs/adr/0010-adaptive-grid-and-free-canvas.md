# ADR 0010 — Adaptive Grid and Free canvas

2026-10-05. Status: implemented; interactive acceptance pending.

Independent coordinates plus collision search do not establish a coherent composition. Still therefore exposes two explicit native layout modes. Grid uses equal-width tracks, aligned content-sized rows, consistent gaps and centered wrapping. The clock has a separate centered region above the modules. Free retains continuous positions/widths and measured collision fitting.

The host uses SwiftUI's [Layout protocol](https://developer.apple.com/documentation/swiftui/layout), with pure display-local geometry in StillNativePlugins. Grid computes columns from viewport width, selected count and an optional continuous preferred track width. It measures actual card heights before planning rows. It has no plugin count cap and performs no nearest-vacancy search. Overflow and overlap are separate conditions: dense content may exceed a small viewport, which the editor reports while masking protected header/return areas.

New scenes/reset use Grid. Existing records without a layout key decode as Free. Changing mode preserves free placements, per-module widths and source/visibility configuration. Grid's track-width preference is separate from Free's per-module width. The native order determines grid insertion and wrapping. Dragging onto a highlighted module inserts at its destination; dropping elsewhere leaves order unchanged. Vertical keyboard movement inserts one row away. Grid clock placement is host-owned. Free presets remain available in Free mode.

Gestures use a named canvas coordinate space, so moving a view does not change its drag reference. Grid centers freeze during a drag and reflow on release. Settling respects Reduce Motion; native controls offer keyboard alternatives. Small computed SwiftUI subviews keep the editor's generated view types manageable.

Imported metadata still uses the supported protocol-v1 templates. This native composition decision does not change their wire contract or enable sources. Interactive native gestures, material rendering, accessibility and dense-display acceptance remain separate from geometry tests and view exports.

## Interaction refinement — 2026-10-07

Grid now highlights a destination and commits insertion on a successful drop. Hovering does not mutate persistent order. Free alignment guides indicate proximity without quantizing movement. Resizing from the trailing handle keeps the leading/top edges fixed, uses one-to-one horizontal pointer translation and commits the resulting measured center. Automatic collision fitting still resumes at release; dense-layout settling and physical interaction acceptance remain open.
