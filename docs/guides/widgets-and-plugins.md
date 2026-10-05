# Widgets and plugins

The development app includes native quota/activity sources and a local declarative plugin library. It is not a released or notarized app. Quit any older Still yourself, then launch the freshly built candidate:

```sh
./scripts/build-macos.sh debug Still-preview
open out/Still-preview.app --args --widgets
```

**Settings…** opens the Hub after returning to the desktop. Appearance offers Porcelain Light/Dark/System, Quiet corner, Side rail and Custom canvas. An applied library template owns composition until **Reset composition**. The clock and system return controls remain host-owned.

## Native collection

The **Plugins** tab also contains the ten configurable mateonunez native modules. When Agents is enabled, Codex and Claude share one card; quota and advisory activity remain separate opt-ins in the **Agents** tab. Native and imported cards share four visible slots. See [native plugin setup](native-plugins.md) for installation, permissions and Task Watch commands.

## Sources

Enable quota and activity separately. There is no global four-card visibility cap. Canvas fit depends on display space; imported protocol-v1 snapshots still contain at most four declared facts per snapshot. This wire-format bound is not a curtain plugin limit.

**Connect Codex quota** uses the installed, already-authenticated Codex CLI. **How it connects → Choose Codex executable…** handles failed discovery. Sign in in Codex itself. Refresh is at most once per minute. Windows report account quota, never task progress.

**Connect Claude quota** installs the bundled native status-line bridge in Claude Code settings. Existing status-line command/options survive, and a private backup is retained under Application Support/Still. Normal Claude work provides the next supported quota observation. Claude Code 2.1.80+ and a supported account are required. Disconnect restores only Still-owned configuration; external edits require manual resolution. This is a Claude Code status-line integration, not a macOS menu-bar plugin. Fresh observations expire after five minutes. Older Claude quota may remain explicitly labelled **Last reported**, with its original observation time, for up to 24 hours and only while each reported window has a known future reset. Reset windows disappear; missing or invalid data remains unavailable. Reactivation does not create a new server observation.

**Enable Codex/Claude activity** adds local command hooks backed by bundled Swift StillAgentBridge. The installer preserves other hooks/settings. Hook input may transiently include content; only anonymous event states are persisted, and referenced transcripts are never opened. This is optional and distinct from quota.

For Codex, review Still's commands and trust them with **/hooks in Codex**. Do not bypass the client's trust step. Reload/restart the client if it requires it, then perform ordinary work. Claude also needs to load the updated hook settings. Current source research covers Codex 0.160.0 and Claude Code 2.1.289; these versions are not a general compatibility guarantee.

Attention requested is advisory: progress replaces it, and expiry removes it. It is not proof of a currently pending approval. Working expires after 120 seconds, attention after 90, completed/interrupted/failed after 30. Resolve decisions in the original client. Disable activity removes Still's exact hook groups and local projection; unrelated hooks remain. Private backups are not activity telemetry.

## Library

Import a `.stillplugin` directory. Still validates and stores the manifest; it runs no package code and connects no source. Review publisher/version/license; these are attribution, not verified identity. Templates apply only existing host slots. Metadata packages require a separate **Enable local source** action, then a separately started external producer publishing to **Show inbox**.

A sample snapshot is visibly labelled **Sample**. Native first-party cards never substitute sample data for a failed source. Disable removes the connection/snapshot and clears cards. External producer permissions are outside Still; stop it yourself if appropriate. Re-enable/app restart creates a new connection UUID.

See [developer guide](plugin-development.md) for starters, schemas, validator, producer transport and limits. A marketplace, automatic upgrades and external executable runner are future scope.

## Preview and acceptance

`pnpm dev` serves the Next.js design preview at `/preview?view=widgets&theme=porcelain&appearance=light`. Browser values are fictional Demo data; it cannot prove native access or authentication. Preview is noindex and unavailable in production.

[Physical native checks](pre-release-native-checks.md) cover trackpad transitions, Touch ID/password, display changes, accessibility and source failure. [Phase evidence](../verification/phase-05-plugin-sdk-and-agent-signals.md) separates completed checks from open acceptance.
