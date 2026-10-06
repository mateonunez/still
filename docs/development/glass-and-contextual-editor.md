# Glass and contextual editor implementation

The scene now separates theme/scenery, measured composition and editing controls. `StillTheme.swift` owns the theme environment, opaque scene background, shared clock and content-material bridge. Canonical Glass roles live beside Porcelain in `design/tokens.json`; the existing native token generator produces both palettes without changing website roles.

`CanvasGridDrag` supplies system drag previews with an application-specific process-local type. Drop entry performs live insertion through the existing validated plugin-order boundary. Canceling a drag retains already-persisted live reorders. Free mode keeps a continuous local gesture and stable measured centers, then fits the released placement.

The editor uses a gallery sheet plus contextual popovers. Consent stays in Settings; the gallery cannot enable disconnected sources. Clock options are scene preferences, while `CanvasPlacement.showsDetails` is a per-module composition preference, defaulting to false for older records. Fitted/snapped placements retain this field.

Use the [guide](../guides/screen-personalization.md), [verification report](../verification/glass-and-contextual-editor.md) and [Apple research](../research/liquid-glass.md). The declarative plugin SDK remains unchanged; selecting a native theme does not add executable extensions or extend the public template schema.
