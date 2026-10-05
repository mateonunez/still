# Developing Still plugins

Protocol v1 supports local declarative templates and metadata packages. The native host imports and validates manifests, renders approved cards, and never executes package code. There is no marketplace or isolated executable runner. See [ADR 0008](../adr/0008-declarative-plugin-contract.md).

The separate mateonunez compiled native collection has configurable adapters and a local workspace installer. See [native authoring](../development/native-plugin-authoring.md) and [configuration](native-plugins.md). Its version-2 configuration/Task Watch receipts do not change this v1 protocol.

## Start with a package

A package is a directory ending in `.stillplugin`, containing `manifest.json` and optionally `README.md` and `LICENSE`. Other files, directories, executable payloads and symbolic links are rejected. The manifest is limited to 32 KiB; optional files to 64 KiB each. Import copies the manifest only. Publisher attribution is not a verified identity.

Use either starter:

- [Porcelain Side Rail](../../examples/plugins/porcelain-rail.stillplugin/manifest.json): a template selecting existing Codex/Claude quota/activity slots. Applying it connects no source.
- [Local Signals](../../examples/plugins/local-signals.stillplugin/manifest.json): one local activity card with an externally started producer.

Validate from the workspace root:

```sh
swift run --package-path packages/StillPluginKit still-plugin validate examples/plugins/porcelain-rail.stillplugin
swift run --package-path packages/StillPluginKit still-plugin validate examples/plugins/local-signals.stillplugin
swift test --package-path packages/StillPluginKit
```

The CLI validates in a private scratch directory and removes it afterwards; it does not enable a source or run the package. Import through **Customize → Library → Import package…**. Installation and connection are separate actions.

## Manifest contract

[Manifest schema](../../schemas/plugin-manifest-v1.schema.json) documents the JSON shape; `StillPluginKit.PluginManifest.decode` is the normative validator, including cross-field constraints. Schema IDs are identifiers, not published HTTP endpoints.

Both `schemaVersion` and `protocolVersion` are integer 1. IDs use a lowercase reverse-domain namespace with at least three segments and at most 96 ASCII bytes. Version is bounded major.minor.patch. Name is at most 48 characters, publisher 80; controls and directional overrides are rejected. Supported licenses are MIT, Apache-2.0, BSD-3-Clause and CC0-1.0.

- `kind: template`: built-in providers `codex` or `claude`; theme `porcelain`; layout `corner` or `rail`.
- `kind: metadata`: provider `local`; its required Porcelain template descriptor does not apply a composition. Declared capabilities are `quota` and/or `agentActivity`.
- `widgets`: one to four unique widget IDs, each with a declared kind and compatible provider. Every widget kind must occur in capabilities.

Unknown keys fail validation. Commands, URLs, arbitrary UI, credentials, custom settings and theme assets are not supported fields. The host clock and return/authentication cannot be replaced. Four optional cards is the global display/connection budget; the library holds at most 32 packages. Duplicate package IDs are rejected; upgrades are not yet supported.

## Produce metadata

Choose **Enable local source**, then **Show inbox**. The private folder under `~/Library/Application Support/Still/plugins/<pluginID>` contains a host-issued `connection.json`. Your separately started producer must read that connection and atomically replace `snapshot.json` with a full snapshot. Still does not launch, sandbox or terminate that producer. It has whatever permissions you gave it outside Still.

[Snapshot schema](../../schemas/plugin-snapshot-v1.schema.json) uses:

```json
{
  "protocolVersion": 1,
  "pluginID": "app.example.signals",
  "connectionID": "00000000-0000-0000-0000-000000000000",
  "revision": 1,
  "observedAt": "2026-10-05T12:00:00Z",
  "expiresAt": "2026-10-05T12:01:00Z",
  "isSample": true,
  "facts": [{ "widgetID": "agent", "kind": "agentActivity", "state": "working", "count": 1 }]
}
```

This is illustrative and cannot be accepted as a current live snapshot. Use your manifest/widget ID and current connection UUID; dates are ISO 8601 with optional fractions. Every accepted update increases a positive revision, bounded to JavaScript's safe integer range. At most four unique facts and 64 KiB per update. Unknown or private fields are rejected, not forwarded to UI.

Activity states: `working`, `attentionRequested`, `completed`, `interrupted`, `failed`, `unknown`. Count is 0–64 recent signals, never an authoritative pending-approval count. Quota facts contain one or two windows with actual `minutes` (1–44,640), finite `usedPercent` (0–100), and optional future `resetsAt`. Missing quota stays unavailable.

No prompts, responses, commands, paths, transcript references, tokens, cookies or raw errors belong in a snapshot. Use `isSample: true` for authoring fixtures; the native card visibly labels Sample. Production facts require real source evidence and `isSample: false`.

Freshness is at most five minutes, with five seconds of future skew. The host converts expiry into a monotonic deadline. Re-reading the same revision does not extend it. Each snapshot replaces all facts: `facts: []` clears old signals. Bad input clears displayed facts; old revisions cannot overwrite newer facts. Suspension clears facts and does not revive an old snapshot on return.

To exercise the included fixture producer after enabling Local Signals:

```sh
node examples/plugins/publish-sample.mjs "$HOME/Library/Application Support/Still/plugins/app.meet-still.local-signals" attentionRequested
```

Check the starter's actual ID before running. The script publishes a 60-second **sample**, observes no real agent, and exits. Disable the source afterwards. Disconnect removes its connection and snapshot, clears cards, and rejects the old UUID. Re-enable/app restart rotates the connection: producers must reread it. Revocation stops consumption; it cannot revoke the external process's OS permissions.

## First-party native sources

`StillWidgets` owns internal quota/activity normalization; `StillPluginKit` owns the interoperable public wire protocol. Internal Swift Codable dates are not this public ISO 8601 format. Vendor payloads never become renderer models.

Codex quota uses its installed, authenticated app-server client. Claude quota uses the bundled Swift `StillClaudeBridge` in Claude Code's status line, preserving an existing command/options. It reads supported quota fields, writes a bounded private projection and opens no transcript or credential store. It is not a macOS menu-bar plugin. See [quota research](../research/claude-usage-integration-2026.md).

Optional activity uses `StillAgentBridge` and supported client hooks. Hook stdin may include prompt/tool content transiently. The helper projects only event/session/agent identity to a state, privately HMACs identities, and does not persist/display content or open referenced transcripts. Configuration preserves unrelated hooks and removes only Still's exact group; private backups remain outside Git. Codex's client-owned `/hooks` trust is required. No approval decisions or trust bypasses are emitted. Attention expires after 90 seconds, working after 120, completed/interrupted/failed after 30; session end clears its group. See [source research](../research/agent-hooks-2026.md) and [setup guide](widgets-and-plugins.md).

## Validate a contribution

```sh
swift test --package-path packages/StillPluginKit
swift test --package-path packages/StillWidgets
swift test --package-path packages/SessionKit
./scripts/build-macos.sh debug Still-preview
node scripts/verify-agent-bridge.mjs
pnpm check
pnpm typecheck
```

Test unsupported versions, unknown/private fields, oversized files, symlinks, undeclared facts, stale/future dates, old connection/revision, empty replacement, reconnect and revocation. Inspect real import/enable/disable and Sample labelling in the native Hub. Verify keyboard, VoiceOver, light/dark, reduced materials, long labels and displays separately. Fixtures/builds do not prove real client delivery, physical trackpad coverage or authentication. [Native acceptance guide](pre-release-native-checks.md).
