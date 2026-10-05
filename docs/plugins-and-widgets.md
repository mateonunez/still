# Widgets, plugins and templates

Protocol v1 is implemented in the local development app: a declarative package importer, Swift validator/CLI, native library, constrained Porcelain templates and explicitly enabled local metadata sources. First-party Codex/Claude quota adapters are present; optional native hooks supply advisory activity states. Real client hook delivery/trust and physical desktop acceptance remain open. No marketplace, package execution or signed release is available.

| Concept | Responsibility | Implemented v1 |
| --- | --- | --- |
| Widget | Host-owned rendering of typed facts | Quota and advisory agent activity; four optional cards globally |
| Plugin | Declares compatible facts and supplies validated snapshots | Local metadata, externally started producer, explicit connection/revocation |
| Template | Constrained composition of existing slots | Porcelain, corner/rail, built-in Codex/Claude slots; never connects sources |
| Marketplace | Discovery and distribution | Future scope; no accounts, payments or automatic updates |

Still owns the opaque curtain, clock, authentication, layout and accessibility. Plugins cannot supply WebViews, JavaScript, shell commands or arbitrary controls. A publisher name is attribution, not a trust certificate. Import does not grant source access.

## Adopted protocol

The normative implementation is [StillPluginKit](../packages/StillPluginKit); [manifest](../schemas/plugin-manifest-v1.schema.json) and [snapshot](../schemas/plugin-snapshot-v1.schema.json) schemas document the wire shape. Integer versions are 1. Snapshots identify the package and host-issued UUID, increase revision, contain ISO 8601 observation/expiry, explicitly mark samples, and replace at most four facts. Unknown fields fail closed. Supported facts are account-quota windows and advisory states, not pending approval records.

The host bounds input, validates declared widgets/capabilities, rejects old connections/revisions, and enforces a five-minute maximum freshness via a monotonic deadline. Empty snapshots remove facts. Disconnect clears cards and connection files; re-enable rotates identity. Revocation stops host consumption, not an external producer's OS access. No subprocess runner or sandbox claim is part of v1.

## Native Hub

Appearance selects Light/Dark/System and composition. Sources separates quota from optional activity and discloses access. Library imports packages, displays publisher/version/license, applies templates and separately enables local metadata. Fixtures are visibly Sample. Unavailable real data never becomes a fixture fallback.

Native activity hooks can receive content-rich stdin. The helper discards content and persists only salted anonymous event states. Codex trust remains in the client. Attention requested is time-limited and advisory; decisions stay in the original client. [Agent awareness](agent-awareness.md).

## Later extensions

Arbitrary theme assets, typed plugin settings, isolated executable runners, provider actions, curated discovery, upgrades and marketplace economics need separate contracts and evidence. Current support does not promise these features. CodexBar informed provider semantics; its JavaScript plugin format is not binary/runtime-compatible with Still v1.

Start with the [developer guide](guides/plugin-development.md), [starter packages](../examples/plugins), [ADR](adr/0008-declarative-plugin-contract.md) and [phase evidence](verification/phase-05-plugin-sdk-and-agent-signals.md). Native swipe/authentication acceptance remains a separate gate.
