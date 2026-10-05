# Development status

Implementation, automated verification and manual acceptance are tracked separately. Reports include both passing checks and unresolved limitations.

## Phases

| Phase | Deliverable | Status | Evidence |
| --- | --- | --- | --- |
| 0 — Fundamentals | Porcelain light/dark, brand, product scope and delivery plans | Prepared | [Brand](../brand-fundamentals.md), [design](../../DESIGN.md) |
| 1 — Native curtain | Menu bar, display presentation, system authentication and ordinary recovery | Step 1A built/structurally verified; Step 1B manual acceptance pending | [Phase 1](../verification/phase-01-native-curtain.md), [interaction refinement](../verification/phase-01-interaction-refinement.md), [visual polish](../verification/phase-01-visual-polish.md) |
| 2 — Idle and power | Inactivity and native materials; energy implementation retained with controls hidden | Automatic curtain-owned awake default implemented and assertion lifecycle verified; manual acceptance and Mission Control/Spaces findings open | [Phase 2](../verification/phase-02-idle-and-energy.md), [automatic awake evidence](../verification/curtain-awake-default.md), [guide](../guides/idle-and-energy.md) |
| 3 — Product experience | Onboarding, preferences and accessibility acceptance | Not started | — |
| 4 — Website | Next.js landing, labelled design preview, SEO, support and hosting | Built and delivered; production HTTP/CI verified; Search Console setup reported complete; indexing and visual acceptance pending | [Evidence](../verification/phase-04-website-and-hosting.md), [hosting guide](../guides/website-and-hosting.md) |
| 4A — Widgets/plugins | Reusable metadata protocol, native templates and local community authoring path | Native Hub, public v1 validator/CLI, local importer, templates and explicit metadata connection/revocation implemented; hardware acceptance open | [Contract](../plugins-and-widgets.md), [phase evidence](../verification/phase-05-plugin-sdk-and-agent-signals.md), [authoring guide](../guides/plugin-development.md) |
| 4B — Codex plugin | First opt-in provider adapter with verified source capabilities | Real quota exercised; advisory native hook bridge implemented/synthetically verified; client trust/delivery open; no approval actions | [Live evidence](../verification/native-live-widgets.md), [research](../research/codex-plugin-2026.md), [agent scope](../agent-awareness.md) |
| 5 — Distribution | Developer ID, notarization, downloads, updates and Homebrew | Not started | [Plan](../distribution.md) |

The design preview and verification tooling now share Node/Next.js; see [migration evidence](../verification/nextjs-preview-and-node-tooling.md). Trackpad gesture coverage remains [open](../verification/native-trackpad-coverage.md).

Build artifacts, screenshots and private logs are excluded from source control. A written checklist does not establish that its cases passed.
