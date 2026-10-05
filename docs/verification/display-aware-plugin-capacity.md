# Display-aware plugin capacity

2026-10-05. Candidate: `out/Still-preview.app`.
Executable SHA-256: `653cc43332e6fb56dd11729bc88930f31f7bd195b66b03c7c281f92c1961b9ea`.

## Change

The initial global four-card visibility rule was a product constraint, not a macOS limit. It is removed. Enabled sources and visible modules remain independent choices. The native center returns all selected cards, re-enabling remembered visibility does not reject the fifth plugin, and the coordinator no longer truncates quota/imported cards according to native-card count. Settings no longer disable source connection based on four global slots. Source configuration and consent are unchanged.

Canvas presets include all selected native modules, using more columns/rows for larger collections. The ten built-in modules can be visible together. The measured layout continues protecting header/return controls and reports actual overlaps or insufficient bounds. No arbitrary replacement plugin count is introduced. Small displays can remain crowded: removing a count cap is not a guarantee that every selected module fits every screen. Automatic width, manual resizing and removing modules remain available.

Imported protocol-v1 metadata still uses the documented templates rather than the native canvas. Its per-snapshot limit of four declared facts is a separate wire-format bound, not a global plugin visibility limit. Task Watch's per-snapshot task bound is also unchanged.

## Verification

Two native regressions were run before the change: selecting all ten returned only four cards, and re-enabling a remembered fifth plugin failed. Both tests failed with the old four-slot message, then passed after removing gates and truncation.

14 macOS host tests and 17 StillNativePlugins tests passed. A new geometry fixture checks all ten modules plus clock for every preset at 1920×1080 and 2560×1440, without overlap or protected-region violations. These fixture sizes are not universal content-fitting proof.

The exact candidate passed 18/18 native collection checks, including acceptance of the fifth module and rendering all enabled selected plugins. Real-provider exports are excluded from Git under `out/verification/native-collection/2026-10-05T17-43-49.236Z/`. The final Balanced 2560×1440 export was visually inspected: all ten modules present, separate from one another and the central clock/return controls. Calendar still requires consent/selection. Exports do not prove physical interactions, native glass or live authentication.

Website copy and current guides now describe available space instead of a global four-card cap. Production website build passed; source whitespace and Biome checks passed. Historical verification reports retain their original counts as dated evidence.

The running `Still-canvas.app` was preserved. After quitting that instance, open the new candidate:

```sh
open out/Still-preview.app --args --editor
```

Add desired enabled modules, select a Layout preset and review on the actual main display. Saved owner visibility is not automatically expanded and provider connections are not silently enabled. Physical dense-layout, keyboard/VoiceOver, gesture/password and idle acceptance remain open. No signed/notarized beta was produced.
