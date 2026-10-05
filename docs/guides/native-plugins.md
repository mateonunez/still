# Configure the native collection

The mateonunez collection is built into the native app. A fresh app launch prepares ten disabled configurations without Node. The optional local workspace installer also registers ten plugins; native adapters are Swift modules, not JavaScript executed by Still. All configuration stays in `~/Library/Application Support/Still/native-plugins`. The installer/Task Watch CLI uses Node 24, while the Mac app remains native. GitHub and Vercel additionally need their own installed, authenticated CLIs.

```sh
pnpm still:plugins list
pnpm still:plugins add mateonunez --all
```

This installs without enabling sources and preserves existing settings. The explicit `--configure-local` preset is for this repository's personal Still workspace; it selects mateonunez/still, the linked personal Vercel project, Milan weather, Milan/New York/Tokyo clocks and a ten-minute timer. It enables all ten and makes Agents/Mac Pulse/World Clock/Spotify visible. No OS permission is granted by this command. Re-running the explicit preset replaces those preset choices; normal installation preserves them.

After quitting earlier Still instances, open the local candidate:

```sh
open out/Still-preview.app --args --plugins --configure-native-plugins
```

The configure flag explicitly connects quota for discovered Codex/Claude clients. Claude's existing status-line command is preserved. Activity hooks are configured separately in **Agents**; review/trust Codex commands in the original client. Claude can retain older quota as **Last reported** with the original observation age, for at most 24 hours and only until its known reset. A refresh never advances the source timestamp. Still does not decide approvals. **Plugins** shows the ten native plugins and the separate declarative package library.

Each plugin has **Enabled**, **Show on curtain**, **Configure**, **Save settings** where applicable, **Refresh** and a source preview. Disabled plugins stop reads; configuration persists. Connection and visibility are independent, without a global four-card visibility cap; canvas fit depends on display size. A source needing access says so; it never shows sample data as live data.

| Plugin | Configuration |
| --- | --- |
| Agents | Discover Codex/Claude; enable quota and advisory activity separately; choose a Codex executable if discovery misses it |
| Build Watch | GitHub owner/repository; authenticate `gh` separately |
| Deploy Watch | Vercel project ID, team ID and personal scope; authenticate Vercel separately |
| Task Watch | Show completed tasks briefly; explicitly register labeled commands |
| Mac Pulse | Choose CPU, memory-pressure and battery/power fields |
| Next Up | Allow Calendar access, choose one calendar and optionally reveal titles |
| World Clock | One to three names and IANA time zones |
| Quiet Timer | One to 240 minutes; explicit Start/Stop; never unlocks Still |
| Weather | City and coordinates; coordinates are sent to Open-Meteo; attribution is visible |
| Spotify | Allow Automation, open local Spotify, optionally reveal track/artist; no playback or history access |

For Calendar and Spotify, use the permission buttons before covering the desktop. The OS controls grants and revocation. A blocked grant requires System Settings; Still does not bypass it. Calendar titles and Spotify details are hidden initially. Selecting a source while it is unavailable remains an explicit setup state.

## Register a real task

Start Still with Task Watch enabled first so it creates a fresh local connection:

```sh
pnpm still:task run --label Build -- pnpm build
```

The wrapper executes the command you supply without a shell, passes output directly to your terminal and shares only its chosen label/state/start time. Exit status is preserved. Four distinct task labels can be observed concurrently. Active receipts expire after two minutes without a heartbeat; terminal states expire after thirty seconds. Do not put sensitive content in a public task label. Reconnection, restart or suspension rotates the host UUID; existing commands continue, but old telemetry is rejected. Start new wrapped tasks after reconnecting.

Missing, expired or invalid facts remain unavailable. Every source refresh is bounded; failed CLI reads leave an explicit status. Mac resource readings do not identify apps or capture input. Manual sleep and system security remain under macOS control.

## Arrange modules

In **Plugins → Arrange your curtain**, drag a handle onto another row to place it before that module. Use the up/down buttons for keyboard-accessible ordering. The visible order persists between launches. Changes affect native modules; imported package ordering remains owned by its template.

In **Appearance**, choose **Side rail** for a centered vertical group or **Quiet corner** for a horizontal group above return controls, then select **Left** or **Right**. On constrained displays the group can scroll. Reset an applied template before changing its composition. Arrangement happens in the desktop Hub; curtain modules do not bypass authentication to enter an editor.

Spotify needs **Configure Spotify → Allow Spotify Automation…** while the desktop is visible. Keep Spotify open. If macOS declines, check Privacy & Security → Automation. Background reads never open a consent dialog; an unresponsive Spotify reports unavailable rather than remaining indefinitely on Connecting. Permission setup alone does not establish successful playback access.

## Edit the whole screen

Choose **Edit screen…** in **Settings…**, or launch with `--editor`. The native editor uses the full screen. Select/drag the clock or a visible native module for continuous placement. The toolbar selects modules, provides directional movement and continuous sizing, adds enabled widgets and removes selected widgets. Clock remains available. All ten built-in plugins can be visible; the editor reports crowding based on actual geometry instead of blocking the fifth module.

**Done** or Escape returns to the Hub. The **Custom canvas** composition is applied immediately and saved locally; reopening preserves positions and sizes. Reset layout restores defaults. Position is proportional to display geometry, with bounds protecting the header and return-control region. The host measures actual module bounds, seeks nearby free space and falls back to Balanced when the chosen geometry cannot fit. Very constrained screens or unusually tall cards can still require Compact or fewer widgets; the editor reports crowding. Separate per-display scenes are not implemented. The editor currently arranges compiled native modules; declarative template/import editing remains separate. Applying another template replaces the canvas composition, while saved canvas positions remain available.

The editor is an ordinary native service window, not an active privacy curtain. It never starts authentication or changes source consent. Inactivity cannot activate the curtain while this editor is visible. The active curtain displays the saved scene without editing gestures.

Spotify authorization is now a bounded owned helper operation, started only by **Allow Spotify Automation…**. **Cancel connection** ends the owned request; it does not revoke an existing OS grant. An unresolved request ends after at most 30 seconds with a visible message. Still only marks Spotify connected after an actual property read succeeds. macOS controls any permission dialog; background reads remain noninteractive. An ad-hoc rebuild may require another consent check. Actual consent and playback are distinct from successful timeout handling.

## Unified settings

**Settings…** (Command-comma from the Still menu) is the single window for General, Appearance, Agents and Plugins. General contains inactivity settings; Appearance chooses the composition and theme; Agents connects local clients; Plugins configures sources. **Edit screen…** opens the full-screen editor. Done returns to Settings. Independent awake-session controls remain implemented but hidden.

Settings uses a persistent sidebar and header; only the current section content scrolls. Appearance is available only inside Settings. Custom canvas hides the side-position control because positioning belongs to the full-screen editor.

### Spotify connection troubleshooting

Open the local Spotify app, then choose **Settings → Plugins → Configure Spotify → Allow Spotify Automation…**. Accept the system request if shown. A successful response connects the source; no grant is inferred from a timeout. A denied request points to Automation; an unresponsive player asks for a retry. Do not reset the system privacy database.

The helper targets the running Spotify process, using fixed read-only Apple Events. `node scripts/verify-spotify-transport.mjs --app Still-preview` checks that helper returns playback state without track/artist titles. Its caller has a different permission attribution from a request originating in Still: a passing receipt does not prove Still's Automation grant.

## Multiple displays

One main scene follows the macOS main display ID. Secondary displays remain opaque with a Go to main display control; they do not duplicate clock, widgets or authentication. Physical topology and authentication acceptance remain required.

## Responsive canvas presets

The editor uses the same macOS main display as the active scene, independently of where Settings has focus. In the editor choose **Layout → Balanced**, **Focus** or **Dashboard**. Each preset replaces saved positions only when selected. The host measures card heights, keeps the return region reserved, and may use a Balanced rendering fallback without rewriting saved positions. Dragging starts from the rendered position; named directional buttons remain available. Built-in canvas task cards show one task with an explicit count for remaining tasks. The desktop source preview retains the fuller list.

### Continuous sizing

The latest development candidate is `out/Still-preview.app`. Quit other Still instances before opening it with `open out/Still-preview.app --args --editor`.

Select a module and pull its bottom-right handle horizontally to resize it continuously. Height always follows the content; the clock type scales with its width. The native **Module width** slider provides the keyboard alternative. Widths have readability and display bounds, rather than named size categories. **Automatic** adapts width to the current display; presets and reset use this mode. Existing saved size categories migrate to equivalent widths, retaining centers. Enable Automatic on a migrated module to opt into display adaptation.

Placement is continuous within the protected area; there is no mandatory grid snap. Directional buttons move by one percent of the viewport. While a resize handle is held, modules retain their centers; overlap can temporarily occur. On release, collision fitting resumes. Reduce Motion disables the settling animation. The editor toolbar uses native glass on macOS 26, with opaque accessibility fallbacks. Live gesture smoothness and keyboard/VoiceOver acceptance still require an interactive trial. See [verification](../verification/continuous-native-canvas.md).

There is no global four-plugin visibility limit. Presets include every selected native module. On a large display, all ten can share the canvas; on a small display, reduce widths or remove modules when crowding is reported. Source consent is unchanged. See [capacity verification](../verification/display-aware-plugin-capacity.md).
