# Widgets, plugins and templates

Status: **First-party native Codex and Claude quota widgets are implemented locally. The community architecture and protocol below remain proposed.** This ordering supersedes the earlier post-v1 activity timing. No plugin runtime, community protocol, import flow or marketplace is implemented; runtime, schema and detailed acceptance scope remain proposals.

Still remains a quiet native Mac curtain. Customization should make a small amount of selected information useful while preserving system-owned authentication, recovery and an opaque curtain. The default remains clock/date with optional information hidden. The essential hub manages customization after returning to the app; it does not turn the covered screen into a dashboard.

A disposable [Next.js Hub and curtain prototype](guides/widgets-and-plugins.md) is now available for Porcelain layout review. The browser implements visual interactions only. A separate native renderer and real first-party quota adapters now exist; a validated community package importer remains absent. See [native evidence](verification/native-live-widgets.md) and [ADR 0007](adr/0007-native-account-quota-widgets.md).

The [developer guide](guides/plugin-development.md) documents the real first-party contribution path and separates it from the proposed community SDK.

## Four separate concepts

| Concept | Responsibility | Example |
| --- | --- | --- |
| Widget | Host-rendered display of typed facts | Clock, agent state, quota window |
| Plugin | Adapter that supplies facts through a versioned protocol | Codex usage adapter |
| Template | Declarative composition of approved widget slots and theme tokens | Porcelain with clock and one compact card |
| Marketplace | Discovery and distribution of approved packages | A future community catalog; business model undecided |

A widget can use built-in facts without a plugin. A plugin cannot supply arbitrary UI. A template cannot grant data access or change authentication. A marketplace is not required to prove any of these boundaries.

## Recommended extension boundary

Begin with a declarative package manifest and a metadata protocol. Still owns SwiftUI rendering, layout, accessibility, privacy filtering and interaction. Allow approved widget kinds and semantic tokens, not arbitrary JavaScript, HTML, WebViews, custom controls or executable template expressions in the curtain. Ship the first adapter as reviewed first-party code; open community templates and fixture-backed development before considering external executables.

CodexBar v0.71.1 has a public TypeScript plugin format with a JavaScript sandbox runtime; it is an existing compatibility candidate, not a universal community standard. Evaluate reuse of its metadata/schema semantics through a native adapter or bridge before considering execution of its JavaScript inside Still. Keep templates host-rendered and treat any external adapter as requiring independently verified isolation; a permissions manifest does not establish that boundary. See the [version-pinned Codex integration research](research/codex-plugin-2026.md) for evidence and compatibility checks.

Proposed package fields:

| Field | Contract |
| --- | --- |
| `schemaVersion`, `protocolVersion` | Explicit major/minor versions; reject unsupported major versions and required capabilities |
| `id`, `version`, `publisher` | Stable namespaced package ID, package version and attributed publisher; attribution alone is not trusted identity |
| `license`, `provenance` | License and source/asset references; retain font licenses and provenance |
| `kind`, `widgets`, `templates` | Declared adapter, approved widget kinds and constrained slot compositions |
| `capabilities` | Requested facts/actions, source access and purpose; each must be supported by the host |
| `settings` | Typed boolean, enum, bounded number or bounded string definitions with defaults; credentials are never manifest values |
| `refresh`, `limits` | Requested cadence, stale interval and declared resource needs; host ceilings prevail |
| `actions` | Named host-approved actions with typed parameters; no shell strings or arbitrary URL opening |

Settings changes require validation. New permissions, source changes and executable replacements require a fresh explicit grant; installing a template never enables a provider. Unknown optional metadata may be ignored, while unknown required features fail validation. Keep accepted migrations explicit and reversible.

An external executable is a separate risk boundary. A manifest declares intent; it cannot honestly sandbox a process. Before allowing community executables, prove an isolated runner with OS-enforced access restrictions, explicit scoped grants, bounded transport, cancellation/termination, revocation and failure containment. If a requested restriction cannot be enforced, reject that execution mode. Do not claim sandboxing from a subprocess or schema validator alone. This runner is an investigation, not a promised beta feature.

## Metadata protocol draft

Every update contains `protocolVersion`, `pluginID`, opaque `sourceID`, host-issued `connectionID`, increasing `revision`, `observedAt`, `expiresAt`, `capabilities`, typed `facts` and optional typed `error`. Reconnecting obtains a new connection ID and starts with a full snapshot. The host rejects updates from old connections or revisions at/below the last accepted revision. For the initial protocol, every update replaces that source's complete snapshot; omitted facts disappear. This makes resolved attention requests unambiguous without a partial-update merge engine.

Supported fact families begin with agent state, attention counts and usage windows. State is `working`, `awaitingInput`, `awaitingApproval`, `completed`, `failed` or `unknown`. Requests use opaque stable IDs; clearing or canceling a request removes it in the next snapshot. Usage includes measurement kind, unit, used/remaining semantics, account alias, time window and optional reset timestamp. Do not turn quota into task progress or infer attention from a process existing. Unsupported facts remain unavailable.

Typed errors use codes such as `permissionDenied`, `sourceUnavailable`, `authenticationRequired`, `rateLimited`, `invalidPayload` and `unsupportedVersion`, with a bounded optional retry delay. The host maps codes to safe copy; arbitrary provider errors never reach the curtain or telemetry. Stale, disconnected and failed are distinct from healthy zero counts. Evaluate freshness using a host monotonic deadline, with a host maximum age even if a provider requests more. Ignore implausible future observations rather than prolonging freshness.

Privacy filtering happens before display: no transcripts, prompts, responses, commands, paths, passwords, tokens, cookies or raw log messages. Prefer metadata-only sources. Sources that require inspecting conversation material need separately documented access and an explicit grant; displaying only counts does not make that access implicit. Default disclosure is anonymized counts. Account/project labels and agent detail are optional, separately selected fields. Keep facts ephemeral and avoid activity-content telemetry.

Proposed initial ceilings, to measure before acceptance: four optional curtain cards, 32 facts per source, 64 KiB per message, 80 characters per display label, five seconds per adapter request and at most one accepted display update per second. Clamp quota polling to no more than once per minute with backoff; negotiate any lifecycle event stream separately. Suspend a source that repeatedly exceeds limits and show an unavailable state. Measure CPU, memory, battery and sleep/wake behavior before fixing runner budgets. No plugin may extend an awake session or continuously wake the screen.

Actions start with authenticated, user-initiated `openClient`, available only for a validated destination supported by that adapter. Resolve approvals in the original client. No approve, execute, dismiss-request or credential-entry action is part of this protocol slice.

## Layout, theme and hub

Use canonical [Porcelain tokens](../design/tokens.json), Instrument Serif for display and system text for native controls. Templates select approved clock/card slots, spacing and token roles; they cannot hide return/authentication, mode identity or degraded system state. Validate light/dark variants, contrast, text scaling, localization, keyboard focus and VoiceOver ordering. Reduce Motion removes optional transitions; accessibility preferences retain solid surfaces and clear boundaries. Reject layouts beyond the card ceiling or outside display-safe bounds. Static owned assets come before animated assets.

Illustrative compositions only; values are fictional and these are not native screenshots:

```text
PORCELAIN LIGHT · warm porcelain / burgundy accents
10:42                    Codex · Account quota
Sunday, October 4        5-hour quota used 64% · resets in 1h 20m
                         Updated 2m ago
Return to Mac            Details hidden

PORCELAIN DARK · deep plum / soft ivory / wine card
10:42                    Codex · Needs attention
Sunday, October 4        1 request · updated 12s ago
Return to Mac            Open client after authentication

STILL HUB · compact native service window
Preview     Widgets     Appearance     Sources
Porcelain   Light / Dark / System
Codex card  [off]   Disclosure: Counts only
Source      Not connected   [Configure]
Layout      Clock + one card   [Preview]
```

Keep the hub essential: live preview, add/remove/reorder within approved slots, per-provider enablement, disclosure/settings, source/freshness status, and a clear reset to Porcelain defaults. Configuration remains outside the covered screen. Preview fixtures are labeled; unavailable live data is never silently substituted with sample values.

## Two workstreams, one merge dependency

1. **Native customization and hub:** define slots and host widget rendering; build template validation, privacy settings and the compact hub with fixtures.
2. **Codex adapter and community contract:** define manifest/envelopes, validation fixtures and a first usage adapter informed by [the CodexBar evaluation](agent-awareness.md). Verify the actual source contract and access behavior before choosing integration. Lifecycle and attention require their own evidence.

Both workstreams depend on one reviewed manifest/envelope and privacy contract. Merge the smallest vertical slice only after they agree on identity, revision/freshness, units, errors and disclosure: fake Codex usage fixture → validated envelope → native card → hub toggle → real opted-in usage source. A fixture does not establish live integration, and live usage does not establish session/approval support.

Acceptance covers malformed/oversized updates, stale/out-of-order revisions, reconnects, removed requests, denied/revoked access, offline sources, unknown quota/units, privacy redaction, long labels, appearance/accessibility, multiple displays and adapter failure while the curtain remains recoverable. Native curtain/authentication acceptance and signed distribution remain separate gates.

## Community path and open decisions

Publish a versioned starter manifest, sample template, fixture corpus, validator and author guide once the contract has survived the vertical slice. Then evaluate explicit local import with validation and provenance display, followed by a curated catalog. A marketplace backend, accounts, payments, paid plugins and automatic updates require later concrete requirements; none are assumed for beta.

Before implementation, resolve which card families and slot arrangement to support, which Codex usage source to adopt, and whether the first community scope includes templates only. External execution, lifecycle/attention observation, in-app approval and marketplace economics remain independent decisions. Track adopted decisions in the decision register and implementation evidence in development, guides and verification documents.

See the [preview guide](guides/widgets-and-plugins.md) and [planning evidence](verification/phase-04a-plugin-planning.md).
