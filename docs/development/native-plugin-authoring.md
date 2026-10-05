# Author a mateonunez native plugin

Use the native collection for reviewed, compiled first-party modules. For a separately distributed, declarative community package use the existing [v1 plugin guide](../guides/plugin-development.md). These are distinct extension boundaries.

## Package and ownership

Each native plugin lives under `plugins/mateonunez/<slug>/plugin.json`: schemaVersion 2, reverse-domain ID `co.mateonunez.still.<slug>`, publisher mateonunez, semantic version, license, native-builtin runtime, declared capabilities and required configuration. Host registration is the explicit NativePluginID catalog; importing a manifest never executes code. The workspace package is `@mateonunez/still-plugins`, with `still-plugins` and `still-task` bins. It is local/private and is not published on npm; do not advertise a functioning npx install until publication is separately completed.

Add the plugin ID and bounded configuration to StillNativePlugins, then its typed payload/source projection, native adapter and configuration/card views. Keep external wire payloads out of renderer models. Validate source identifiers before constructing requests. Never interpolate user configuration into a shell or AppleScript. Each module must define capabilities, permissions, unavailable/error states, refresh interval, expiry and cancellation behavior. Source/CLI errors log plugin/state codes only, never raw vendor responses, credentials, calendar contents or tracks.

Choose privacy defaults for each field. Gate OS consent behind a Hub action, not discovery or curtain activation. Sources stop on disable/suspension; in-flight completions must match the current generation. Expired data cannot become healthy zero. Shared native source primitives are implementation details, not a general executable plugin sandbox. UI uses Porcelain tokens and native controls with accessible text/focus and reduced-material fallbacks.

## Task Watch v2 producer contract

The host creates a UUID in `task-watch/connection.json`. A producer reads it and atomically replaces `snapshot.json` with a full snapshot: protocolVersion 2, the same UUID, increasing safe-integer revision, ISO 8601 observedAt/expiresAt and at most four tasks. Each task has label/state and optional startedAt/progress/expiresAt. Supported states: queued, working, completed, failed, canceled, unknown. Labels are 1–64 plain characters; progress is finite 0–100. No other task or root fields are accepted. Payload size is at most 16 KiB; expiry is at most five minutes with five seconds future skew. Each task can expire before the receipt; another producer cannot renew that task’s expiry. Re-reading does not renew the monotonic deadline. Old connection/revision cannot overwrite new facts.

Use the provided `still-task` wrapper as the reusable producer reference. It serializes concurrent updates with an exclusive short-lived lock, emits bounded snapshots and keeps output in the caller's terminal. It never includes commands, environment variables or transcript paths in receipts. Reconnection revokes consumption rather than killing an external job. A crashed producer lock fails closed; inspect/remove only the owned stale lock before retrying, never silently break another producer's lock.

## Verify

```sh
swift test --package-path packages/StillNativePlugins
pnpm --filter @mateonunez/still-plugins test
swift test --package-path apps/macos
./scripts/build-macos.sh debug Still-preview
node scripts/verify-native-plugins.mjs
```

The opt-in live probe uses copied configuration and a scratch task connection, queries selected real GitHub/Vercel/weather sources, exercises a real local command and emits state-only receipts plus light/dark renders. It asks for no OS permission and never changes user source connections. Physical native materials, consent, authentication and screen-saver behavior require their own acceptance checks. Host renders remain illustrations of current card data, not proof of native title-bar/glass appearance.
