# Glass and contextual editor verification

Date: 2026-10-06. Local development candidate, not a distributable beta.

## Delivered behavior

- Native macOS drag sessions and process-local typed payloads replace custom pointer dragging in Grid. Drop-entry reorders immediately; Free retains continuous pointer movement and freezes other centers during a drag.
- A widget gallery, selected-module inspector and appearance popover replace the two-row editor toolbar. Native selection/movement/width controls remain keyboard alternatives.
- Glass is a second official theme alongside Porcelain, with light/dark/system appearances and three Still-owned backdrops. Liquid Glass controls are separate from content cards. AppKit card materials explicitly use `.withinWindow`; the curtain panel remains opaque.
- Shared clock rendering supports three type styles, optional date/message and per-widget detail presentation. Theme, scenery and clock preferences use local defaults; details use validated composition records. Older records retain compact detail presentation.
- The builder supports a separate design candidate, optional writable Swift caches and fails closed when it cannot inspect processes before replacing an existing bundle.

## Evidence

| Check | Result | Boundary |
| --- | --- | --- |
| macOS host Swift tests | 16 passed | Includes existing authentication attachment, main viewport, read-process bounds and plugin arrangement tests; does not exercise system drag callbacks |
| StillNativePlugins Swift tests | 22 passed | Includes new detail migration/round-trip/malformed-value rejection and existing geometry/reorder tests |
| Swift build | Passed with macOS 26.5 SDK, arm64 | New code uses availability guards; older hardware/OS runtime remains untested |
| Local ad-hoc bundle verification | `codesign --verify --deep --strict` passed | No Developer ID/notarization/distribution acceptance |
| Canonical palette contrast | 46 declared pairs passed | Flat token pairs only; actual gradients, materials and focus require native inspection |
| Biome, zsh syntax, diff whitespace | Passed | Changed JS/JSON and builder/source hygiene |
| Noninteractive native view export | Unavailable: process exited 134, no images produced | Cause not established; no native visual acceptance claimed |

Candidate: `out/Still-design.app`.
Executable SHA-256: `2dc0c37c48bcec7bef4a6968a00ac52b56cac1ec0640d44e1b83d55c11b4d46b`.

Builds used workspace scratch/module caches and `/private/tmp/still-swift-cache`. Existing candidates were not overwritten or terminated. Provider consent/settings were not changed. Source collection and network behavior were not retested during this UI phase.

## Open acceptance

Use the [personalization guide](../guides/screen-personalization.md). Check native lift/cursor/drop behavior, reordered-card stability, canceled drags, Free release and resizing, inspector/gallery usability, saved preferences after restart, VoiceOver and keyboard focus, Reduce Motion/Transparency and increased contrast. Place distinctive desktop content behind the Glass curtain and inspect edges and appearance changes for bleed-through. Repeat large/small main-display and hot-plug cases.

Dense scenes can still overflow a short viewport; there is no universal fit or paging guarantee. Trackpad activation/password-dialog exposure and elapsed screensaver prevention remain separate open checks. Native perceived smoothness is not established by this report.

Apple guidance and API boundaries are recorded in [Liquid Glass research](../research/liquid-glass.md). No website deployment, release signing or notarization occurred in this phase.
