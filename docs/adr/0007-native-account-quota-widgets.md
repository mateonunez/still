# ADR 0007 — First-party native account quota widgets

Date: 2026-10-05. Status: implemented and locally exercised with real Codex and Claude quota.

Still owns the SwiftUI renderer, Porcelain composition, authentication and optional source controls. `StillWidgets` normalizes provider data into version-1 `UsageSnapshot` values. This is the built-in quota contract, not the complete proposed community plugin protocol. Templates cannot enable sources. No sample data enters the native renderer.

Codex uses the installed CLI's dedicated stdio app-server: initialize, initialized and account/rateLimits/read only. Polls are at least 60 seconds apart, one request process at a time, with a 15-second deadline and cancellation of the owned subprocess. Payloads are bounded to 64 KiB; identities, credits and unknown fields are omitted. Actual window durations determine labels. Installed Codex 0.160.0 was exercised; compatibility with other versions is not established.

Claude uses the documented Claude Code status-line rate_limits fields through a bundled native helper. Connect preserves the existing command and options, records an owner-only backup, and changes only statusLine. The helper forwards the original input to the previous user-owned command while saving only normalized quota. It does not open transcript files or credentials. Disconnect conditionally restores the original statusLine; external edits are not overwritten. Refreshes of unchanged retained status-line data do not extend freshness. Account support and a normal Claude response determine availability.

Accepted snapshots contain one or two finite quota windows, observation time and optional future reset times. A five-minute freshness ceiling applies. Missing, expired, future-dated, malformed or oversized data is unavailable, never healthy zero. Suspend clears source snapshots and cancels the owned request; reconnect invalidates prior callbacks. Native logs contain provider and safe error code only.

The Hub uses a full-size AppKit content surface with reserved native title-bar space. Scrolling cannot paint over the title. The app is opened through Launch Services, not by running its executable from a terminal, for ordinary interactive use. Glass controls respect Reduce Transparency; the privacy curtain stays opaque.

Community package validation/import, an external isolated runner, agent lifecycle and approval observation, and the marketplace remain separate future work. See [verification](../verification/native-live-widgets.md).
