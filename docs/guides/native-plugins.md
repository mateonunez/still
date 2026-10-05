# Configure the native collection

The mateonunez collection is built into the native app. The local workspace installer registers ten plugins; native adapters are Swift modules, not JavaScript executed by Still. All configuration stays in `~/Library/Application Support/Still/native-plugins`. The installer/Task Watch CLI uses Node 24, while the Mac app remains native. GitHub and Vercel additionally need their own installed, authenticated CLIs.

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

Each plugin has **Enabled**, **Show on curtain**, **Configure**, **Save settings** where applicable, **Refresh** and a source preview. Disabled plugins stop reads; configuration persists. Connection and visibility are independent, with four total optional cards rendered on the curtain. A source needing access says so; it never shows sample data as live data.

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
