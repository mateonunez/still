# Agent awareness

The development app has real first-party Codex/Claude quota adapters and optional native hook activity. Activity bridge normalization and synthetic delivery are verified; actual client trust/event delivery remains a native acceptance case. There is no in-app approval action or authoritative pending-request count.

## Sources and meaning

| Card | Source | Meaning |
| --- | --- | --- |
| Codex quota | Installed, authenticated Codex app-server | Account usage in the actual reported window; not task progress |
| Claude quota | Claude Code status-line input → bundled Swift helper | Client-reported account quota; unavailable on unsupported accounts |
| Codex activity | Supported hooks → bundled Swift helper | Recent advisory state; client-owned /hooks trust required |
| Claude activity | Supported hooks → bundled Swift helper | Recent advisory state; some interruptions have no event |

Supported activity states are working, attention requested, completed, interrupted, failed and unavailable. A PermissionRequest event does not identify an authoritative pending request. Later progress supersedes the signal; expiry prevents indefinitely retained attention. Working expires after 120 seconds, attention after 90, completion/interruption/failure after 30. Silence is unavailable, not proof of no work.

## Privacy and configuration

Each provider and fact family requires explicit enablement in Sources. Hook stdin can contain prompts, tool input and transcript references transiently. Still projects event names/session identities only, privately HMACs identities, persists bounded anonymous state, and never displays/persists conversations or opens referenced transcripts. Disable removes Still's exact hook groups and projection; unrelated commands/settings survive. Codex trust is never bypassed.

Quota and activity are separate data contracts. No browser cookies, credential caches, raw logs or transcripts are imported. CodexBar is a reference for usage semantics; Still does not embed its JavaScript plugin runtime. No automatic approve/deny or open-client action is implemented. Resolve decisions in the original client.

## Acceptance

Verify live events from both clients, source setup/reload/trust, parallel sessions, subsequent progress, cancel/interrupt, failure, session end, expiry and disconnect. Confirm an unsupported source remains unavailable. Separately verify UI disclosure, card ordering/limits, VoiceOver and native desktop/authentication recovery.

[Hook source research](research/agent-hooks-2026.md) records versions and source limitations. [Setup](guides/widgets-and-plugins.md), [plugin authoring](guides/plugin-development.md) and [phase evidence](verification/phase-05-plugin-sdk-and-agent-signals.md) distinguish native runtime from synthetic probes.

The combined Agents widget now displays fresh activity separately from quota, and explicitly shows “Activity · no recent signal” after expiry. The “Activity observed” label reflects recent hooks, not an authoritative running-job state. No signal does not mean no work. Host integration tests cover receipt ingestion through the combined widget, expiry, suspension and post-resume observations; see [refinement evidence](verification/pre-beta-refinement.md).
