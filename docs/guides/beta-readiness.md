# Pre-beta acceptance guide

Use the [product audit](../verification/pre-beta-product-audit.md) to separate implemented behavior from verified behavior. Keep development binaries and private screenshots out of Git.

## Try the current candidate

Quit the running Still yourself, then run from the workspace root:

```sh
open out/Still-preview.app
```

Settings contains General, Appearance, Agents and Plugins. A clean profile lists all ten native plugins disabled; enable and configure only the sources you want. No Node installer is needed for built-in modules. Calendar and Spotify use explicit system permission actions before the curtain is active.

With multiple monitors, expect a single main scene on the macOS main display. Other displays remain opaque and offer Go to main display. Verify changing the main display, unplugging/reconnecting, different scaling and return through Touch ID. A view export does not establish this behavior on physical screens.

## Report native results

Include executable SHA-256, macOS build, hardware, display arrangement, activation method and exact reproduction. Record first and second activation, slow/fast/partial desktop swipes, Mission Control, password cancel/retry, sleep/wake and one-hour inactivity on AC and battery. Note any exposed frame. Do not attach credentials, conversations, calendar titles or private desktop captures to public reports.

```sh
node scripts/verify-native-interaction.mjs --app Still-preview
node scripts/verify-native-password-boundary.mjs
```

Read each script's prompt; quit candidates yourself before launching diagnostics. These require a physical observer. Never infer privacy acceptance from unit tests, window flags or a successful build.

## Joint native trial

Use the [responsive-canvas candidate](../verification/main-display-canvas-and-native-hardening.md). Review Layout presets on the main display, move a widget using both drag and directional buttons, resize it, reopen Settings and confirm persistence. Check both appearances and changed display scaling. Then verify actual Touch ID, system-password visibility and cancel/retry, activation-time swipes, one-hour AC/battery inactivity, system lock and sleep/wake. Complete Calendar consent/selection separately. A report of a passing view export must not mark these cases passed.
