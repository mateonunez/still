# Agent awareness — Codex first

Planned direction, updated 2026-10-04. The widget/plugin foundation and first Codex integration are now scheduled before beta and distribution. Additional providers remain follow-up scope. No integration is implemented.

## Product opportunity

Turn the away screen into a quiet, glanceable view of agent work: what is running, what needs attention, and what capacity remains. Preserve the original calm-screen experience; agent cards are optional and never become a scrolling operations dashboard.

Suggested hierarchy: attention needed first, active sessions second, completed/failed sessions third, account usage last. A pending approval can matter more than a consumption chart. Use restrained status changes rather than constant animation.

## Reference and evidence boundary

CodexBar provides provider-specific usage/reset information, costs where sources support them, a CLI, and optional agent-aware metadata collection. It documents different authentication/data sources and opt-in local inspection. This establishes a useful reference for usage aggregation; it does not prove that our app can observe every agent or handle approvals. [CodexBar README](https://github.com/steipete/CodexBar/blob/main/README.md), [CLI reference](https://github.com/steipete/CodexBar/blob/main/docs/cli.md).

Recommendation: evaluate a version-pinned CodexBar CLI adapter for usage before rebuilding provider-specific access. Inspect its JSON contract, account selection, errors, licensing, packaging, credential behavior and refresh side effects before adopting it. Do not read its private caches as a stable API or silently import browser credentials.

Session lifecycle and approval requests need separate provider integrations. Investigate supported event streams, hooks or local APIs for the supported agent clients. A running process is not proof of active work; a permission-related event is not always proof that the human is currently expected to act. First support one validated client, then expand.

## Proposed cards

```text
Agents · sample concept

Codex       Needs your attention    1 pending request
Claude      Working                 Updated 12 seconds ago

Usage · sample concept
Codex       5-hour quota used: 64%  Resets in 1h 20m
Claude      Weekly used: 38%        Updated 2 minutes ago
```

All values above are illustrative. Specify used vs remaining, time window, account alias, source and freshness. Never combine account-wide quota with session progress. Dollar costs, token counts, credits and subscription percentages are different measures; label estimates and missing values explicitly.

## Capability contract

An optional `AgentProvider` normalizes explicitly supported data into metadata:

- Provider and opaque session identity; user-defined display alias.
- Session state: working, awaitingApproval, awaitingInput, completed, failed, unknown.
- Counts of pending requests, with source event IDs and resolution updates.
- Last observed timestamp and freshness/connection status.
- Usage windows with measurement kind, unit, used/remaining semantics and reset time.
- Source attribution and capabilities: usage, lifecycle, approval notification, open-client action.

Never transport prompts, responses, conversation excerpts, shell commands, paths, or arbitrary log strings to the display. Prefer sources that emit metadata only. If useful fields exist only inside conversation logs, document that access separately; do not silently parse them just because rendering would hide the text. Raw data remains inside a bounded adapter and is discarded after normalization.

## Approval interaction

First agent-aware version: read-only notification and, after authentication, a validated “Open agent” action when the client supports it. Resolve the decision in the original client. Do not dismiss, approve, or execute work automatically.

Future in-app approvals are a separate product decision. They require an officially supported response mechanism, exact request identity, expiry handling, source-side authorization and audit, and a user-visible action description. A metadata-only screen may deliberately lack the context needed to make that decision safely; authentication alone does not supply it.

## Privacy and resource behavior

Opt in per provider. Default screen disclosure: anonymized counts; project/account labels require explicit choice. No automatic token, cookie, keychain, or transcript collection. Identify which source a user enables and the access it needs.

Use event-driven lifecycle updates when available; bounded refresh/backoff for quotas. Mark disconnected or stale sources as unknown rather than “working” or “no approvals.” Avoid waking the screen continuously for updates. Pending work must not extend a keep-awake session without an explicit policy.

## Delivery order

1. Resolve the core curtain/authentication findings and review the proposed widget/template UI and reusable plugin protocol.
2. Prove the first Codex usage adapter with disposable fixtures and live opted-in metadata evidence. Validate session/attention capabilities separately; unsupported capabilities stay explicitly unavailable.
3. Review an optional compact card with real field constraints and privacy defaults.
4. Ship read-only agent awareness behind per-provider opt-in.
5. Evaluate authenticated navigation and, separately, whether in-app approval belongs in the product.

Acceptance must include multiple simultaneous sessions, stale/disconnected sources, resolved/canceled requests, account selection, malformed events, unavailable quota, correct units, and proof that conversation content never reaches UI or app telemetry. No agent integration is implemented in this workspace.

See [widget/plugin proposal](plugins-and-widgets.md) and [current Codex source research](research/codex-plugin-2026.md) for the proposed integration boundaries.
