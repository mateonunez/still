# Full-screen canvas and Spotify authorization lifecycle

2026-10-05 · Native development preview; no beta distribution.

## Findings and changes

The previous requestSpotify path called AEDeterminePermissionToAutomateTarget on a detached thread. A read-only stack sample of the owner-observed waiting app confirmed that call was blocked in a semaphore wait. The main UI remained alive, but requestingSpotify could never clear. No OS grant was inferred. The private sample is ignored under out and contains no tracked evidence artifact.

Authorization now uses an owned helper performing a fixed Spotify property get with interactive delivery permitted only for the explicit authorize command. Apple Event reply timeout is 25 seconds; parent process lifetime is 30 seconds. Cancel kills only this owned helper through the existing bounded command lifecycle. Completion/cancellation clears the waiting state; connection requires a successful real playback-property response. Background reads retain never-interact and their shorter bounds. This corrects the unbounded lifecycle; successful owner consent/playback remains unverified.

The native screen editor is now a full-screen SwiftUI/AppKit window. Clock and native modules have normalized persisted positions, grid snapping, selection, drag positioning and toolbar keyboard alternatives. Optional module sizes are Compact/Regular/Wide. Add/remove respects enabled sources and the four-visible limit. The active curtain consumes the custom scene and remains noneditable. Geometry clamps modules into the header/return-safe region; inactivity activation is suppressed while editing.

## Evidence

- StillNativePlugins: eleven tests pass, including grid bounds/reserved zone and persisted-layout validation/round trip.
- Native host: six tests pass, including owned-process timeout and cancellation behavior.
- pnpm check/typecheck, native build/ad-hoc signing and diff whitespace checks pass.
- Native collection live probe: 17/17 passed on candidate SHA-256 `367c3ca0f04fe28aea8a9042b5b7e287fd491b074e459f157e49ed807db7197a`.
- Receipt: ignored `out/verification/native-collection/2026-10-05T14-33-43.644Z/native-plugins.json`. Full canvas/editor source renders were inspected; ImageRenderer cannot render every AppKit-backed control and displays placeholders in those exports.
- After the previous app was closed, out/Still-preview.app was opened with --editor. Native accessibility/screenshot inspection confirmed the full-screen editor, four modules, clock, selection/size controls, directional buttons, Add widget, Remove, Reset and Done.
- A real native right-button click persisted clock x=0.5833333333333334, y=0.375. A left-button click restored x=0.5. No raw source content or screenshots are tracked.

## Remaining acceptance

Real pointer dragging, size changes, add/remove, restart persistence and varied display geometries need further native trials. Arbitrary overlapping positions are still possible; collision resolution and per-display scene management are future work. Clock accessibility children are combined in the next candidate; real VoiceOver acceptance remains pending. Real VoiceOver/keyboard focus, authentication, desktop transitions and prolonged display-awake behavior are not established by these probes.

Spotify consent/denial/cancel/retry and actual playback must be tried in this exact candidate. The old unbounded API is absent from the authorization path, but a successful timeout/cancellation test is not successful provider access. No system privacy database reset, credential access or permission bypass was performed.

## Unified Settings candidate

Customize and Preferences are consolidated into **Still Settings**, with General, Appearance, Agents and Plugins sections and one **Settings…** menu command (Command-comma). General reuses the existing inactivity controller and preserves the hidden finite awake-session controls. Done in the editor returns to the same settings window. There is no separate preferences window.

The separate `out/Still.app` candidate built successfully with SHA-256 `52103df7c54cf9cc1248e824c2c6f046ccce55ece60ebed7886331577e3c2067`. Eleven native plugin tests and six host tests pass; check/typecheck and whitespace checks pass. Native collection receipt `out/verification/native-collection/2026-10-05T14-43-39.578Z/native-plugins.json` reports 17/17 passing checks. These checks do not establish interactive Settings navigation, drag acceptance or Spotify permission/playback. Spotify still reports permissionRequired in the probe. The earlier interactive editor trial applies to the preview candidate, not this Settings revision.
