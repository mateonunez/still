# Phase 05 — Local plugin SDK and advisory agent signals

Date: 2026-10-05. Native development only; signing/notarization/public app release are deferred.

## Delivered

- StillPluginKit v1 Swift library/validator CLI, manifest/snapshot schemas, two declarative starter packages and separately invoked Sample producer.
- Native Library import, attribution, explicit source enable/revoke, rotating connection IDs, typed full snapshots, monotonic expiry and constrained Porcelain templates. No imported code execution or implicit provider connection.
- Appearance/Sources/Library Hub, live Porcelain preview, four-card budget, compact narrow-display presentation, native glass controls and a readable inactive standard-control fallback.
- Opt-in Codex/Claude supported-hook installation and bundled native StillAgentBridge. Anonymous advisory states, private HMAC identities, per-session-group cleanup, short expiry and no approval decisions. Codex client trust remains required.
- Public presentation policy for Dock/Cmd-Tab, exact restoration and preserved recovery; system-authentication handoff restores the original policy. No claimed Spaces/trackpad gesture veto.

## Verified evidence

Environment: macOS 26.5.2 (25F84), arm64. Package tests: SessionKit 34, StillWidgets 13, StillPluginKit 8; all passed. Native bundle build/ad-hoc signature verification, both starter CLI validations, Biome, TypeScript, token contrast and Next.js production build passed. No Developer ID/notarization was performed.

| Check | Evidence | Limit |
| --- | --- | --- |
| Plugin contract | Versions/private fields/permissions, reconnect/revisions, monotonic expiry/empty replacement, bounded input, package/symlink rejection and revocation tests | Does not sandbox an external producer or verify publisher identity |
| Real native Library | Both starters imported through NSOpenPanel; template applied without connecting a provider; Local Signals explicitly enabled, Sample attention snapshot displayed, then disabled/cards and connection removed | Sample producer contract/UI proof, not real agent activity |
| Native Hub | Real Light/Dark switches, source controls, scroll, live Codex quota, readable inactive control screenshot and native AX labels | Full VoiceOver/keyboard/reduced-material/hardware acceptance remains open |
| Native helper | 10 synthetic checks, 15 invocations; max 254 ms, mean 22 ms; enablement, privacy, progress, child-agent end, Claude failure, revoke and no decision output | Synthetic stdin; not client hook trust/delivery |
| Public presentation | Six real AppKit checks for requested options, idempotence, recovery flags and exact restoration | No gesture frames, actual recovery UI or authentication success proof |
| Curtain lifecycle | 11 runtime checks including panel getters/frame count, font, controlled workload progress, own power assertion and cleanup | Structural proof; not universal work continuity, actual sleep prevention or visual desktop coverage |

Runtime smoke executable SHA-256: `8ea3ec285c671f91b7cf18cdc027b16274c12c3e69a375d787748be59958c8cf`. Receipts/screenshots are local ignored files under `out/verification/prebeta`. This smoke predates the final system-authentication policy handoff refinement; it is not attributed to that final rebuilt binary.

Final rebuilt `out/Still-preview.app/Contents/MacOS/Still` SHA-256: `a1d5760d65306e139df9e5f421b231453c491826960677fcdd71605db08a952e`. It compiles/signature-verifies; exact final-binary native interaction acceptance remains open. The separately identified Workshop app used for UI checks was closed without terminating the running personal candidate.

## Open acceptance and known limits

Physical slow/fast/partial three-finger swipes and Mission Control can expose underlying windows. Public APIs reviewed do not establish a blanket veto. Owner trackpad trials are pending, alongside Touch ID/system password success/cancel/retry, multiple displays, sleep/wake/battery, fresh installation, VoiceOver and reduced accessibility materials.

Client activity setup/trust/reload and real events from both clients remain pending. Hook stdin transiently receives content; only projected state is persisted. PermissionRequest is advisory, not an authoritative pending approval; Claude interruptions may emit no event and therefore expire. Quota live compatibility does not prove activity support.

External metadata producers retain their existing OS permissions; disabling stops host consumption only. No catalog, arbitrary assets/settings/actions, isolated runner, package upgrades, automatic updates or release distribution is implemented.

## Reproduce

```sh
swift test --package-path packages/StillPluginKit
swift test --package-path packages/StillWidgets
swift test --package-path packages/SessionKit
./scripts/build-macos.sh debug Still-preview
node scripts/verify-agent-bridge.mjs
swift run --package-path packages/StillPluginKit still-plugin validate examples/plugins/porcelain-rail.stillplugin
swift run --package-path packages/StillPluginKit still-plugin validate examples/plugins/local-signals.stillplugin
pnpm check
pnpm typecheck
pnpm check:brand
pnpm build
```

Run owned presentation/curtain probes only when no interactive native trial is in progress. Follow [physical acceptance](../guides/pre-release-native-checks.md), [plugin authoring](../guides/plugin-development.md), [source research](../research/agent-hooks-2026.md) and [ADR 0008](../adr/0008-declarative-plugin-contract.md).

## Owner trial — first/repeated activation regression

The owner reports that the first activation suppresses trackpad gestures but has no visible/usable embedded Touch ID, requiring the Mac-password action. Later activations show Touch ID. A desktop swipe during activation reintroduces underlying-window previews and gesture exposure. The loaded executable hash and repeat-without-swipe coverage were not established from the report. This is a failed native acceptance case, not a gesture fix.

Replay of the owner report with `node scripts/verify-native-interaction.mjs --report out/verification/interaction-trial/owner-baseline.json` exits 1: firstTouchIDVisible=false, noExposureDuringActivation=false. Untested fields remain null. This is a human-observation replay, not automated physical gesture synthesis.

A separate diagnostic candidate `out/Still.app` (SHA-256 `622c4433dad26cf93e3d9a9ca70c7772d1e2d18156422eac1744c0a232bd870f`) builds/signature-verifies and adds opt-in `--interaction-trace`. It does not claim to fix the regression. The bounded local trace records application activation, key-panel status, Touch ID preparation/attachment, normalized preparation error code and presentation flags; no input, content, window titles or client data. Normal launches write no trace.

`node scripts/verify-native-interaction.mjs` guides three physical trials and writes private receipts under `out/verification/interaction-trial`. It never terminates an existing user app. Root cause and an original-reproduction pass remain pending this trace.
