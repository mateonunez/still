# Personalize your Still screen

Resolve the current local candidate from its hash-verified manifest. Quit any other Still instance before opening it:

```sh
open "$(node scripts/native-candidate.mjs --path)" --args --editor
```

## Make the screen yours

- **Appearance:** select Porcelain or Glass, then System, Light or Dark. Glass offers Aurora, Dusk and Mist backdrops. These backgrounds belong to Still; they are not a blurred view of the desktop.
- **Add widget:** opens the gallery. Connected widgets can be added; existing widgets and disconnected sources are labeled. Connect and configure a source in Settings → Plugins first. Adding a widget does not grant permissions.
- **Select a module:** click it or use the selection picker at the bottom. **Adjust** opens its inspector. Clock controls offer Serif, Rounded and Minimal type, plus date and message visibility.
- **Widget details:** the inspector can show or hide source details for an individual module. Expanded Task Watch cards show up to four tasks; compact cards show one and a remaining-task count.
- **Grid:** drag widgets using the native macOS drag preview. A dashed outline marks the destination; order changes only when you drop onto a widget. The clock keeps its own region. Adjust a widget to change the shared automatic-column/continuous-width preference.
- **Free:** drag modules to position them. Resize the selected module with its handle or use Adjust → Module width. The handle follows horizontal pointer movement one to one, keeping the leading/top edges fixed while height follows content. The other centers stay stable during pointer movement; fitting resumes on release.
- **Keyboard:** the selection picker, movement menu and width slider provide alternatives to dragging. Grid up/down moves across a row; Free menu actions move by 2.5 percent of the viewport. Escape dismisses the active inspector or returns to Settings. Done returns to Settings.

Changes are saved locally. Grid hovering does not save a new order; insertion commits on a valid drop. Switching Grid/Free preserves saved free coordinates and widths. Reset arrangement and presets are available in Adjust; applying a preset replaces the scene positions.

## Materials and displays

Glass uses Liquid Glass for selected controls on macOS 26 and an AppKit content material for cards. Cards explicitly blend within Still's window. Older systems use standard controls/materials. Reduce Transparency and increased contrast use opaque surfaces; Reduce Motion disables custom settling animations. System keyboard focus remains available.

There is one main scene. Secondary displays remain opaque. Small screens can still run out of room; the editor reports crowding instead of limiting the total plugin count. Return controls keep a reserved region when Still is active.

## Try this candidate

Check dragging, release/cancel, repeated reordering, continuous resizing, restart persistence, both themes in Light/Dark, accessibility preferences and multiple displays. Also repeat Touch ID/password and activation-time trackpad trials. Successful build/tests do not establish interaction smoothness, privacy coverage or release readiness.

Free movement shows nearby edge/center alignment guides without magnetic snapping. Explicit widths remain continuous within the viewport and current 180–600-point limits. Grid clock scale adapts to module count.
