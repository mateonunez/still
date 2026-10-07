# Continuous editor interaction

The Free canvas alignment seam reproduced a discontinuity: crossing a six-point guide threshold with a 0.5-point pointer increment produced a 6.5-point jump. Alignment guides now report proximity without changing the constrained pointer center.

The measured resize calculation also reproduced movement of the leading/top edges when width or wrapped height changed. `CanvasResizeGeometry` is shared by the frozen layout and final placement; it preserves the leading/top origin. The trailing handle applies horizontal translation once, bounds width by the remaining usable area and commits the measured center with the width.

Grid keeps the system drag session and preview. A dashed destination outline replaces persistent hover reordering. Only a valid drop invokes the host reorder callback. Cancelling or dropping outside a module does not invoke that callback. Free movement/resize explicitly suppresses implicit preview animation; release may still settle through the existing collision solver.

No source permissions, authentication, distribution contract or saved schema changed. Per-module width limits and automatic collision fitting remain in place. The refinement is not a complete replacement of the layout engine.

See [verification](../verification/editor-interaction.md), [personalization guide](../guides/screen-personalization.md) and [ADR 0010](../adr/0010-adaptive-grid-and-free-canvas.md).
