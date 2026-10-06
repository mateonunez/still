# Development status

Implementation, automated verification and manual acceptance are tracked separately. Reports include both passing checks and unresolved limitations.

## Phases

| Phase | Deliverable | Status | Evidence |
| --- | --- | --- | --- |
| 0 — Fundamentals | Porcelain light/dark, brand, product scope and delivery plans | Prepared | [Brand](../brand-fundamentals.md), [design](../../DESIGN.md) |
| 1 — Native curtain | Menu bar, display presentation, system authentication and ordinary recovery | Step 1A built/structurally verified; Step 1B manual acceptance pending | [Phase 1](../verification/phase-01-native-curtain.md), [interaction refinement](../verification/phase-01-interaction-refinement.md), [visual polish](../verification/phase-01-visual-polish.md) |
| 2 — Idle and power | Inactivity and native materials; energy implementation retained with controls hidden | Automatic curtain-owned awake default implemented and assertion lifecycle verified; manual acceptance and Mission Control/Spaces findings open | [Phase 2](../verification/phase-02-idle-and-energy.md), [automatic awake evidence](../verification/curtain-awake-default.md), [guide](../guides/idle-and-energy.md) |
| 3 — Product experience | Onboarding, preferences and accessibility acceptance | Unified Settings, first-run built-in collection and full-screen editor implemented; physical accessibility acceptance pending | [Current audit](../verification/pre-beta-product-audit.md) |
| 4 — Website | Next.js landing, labelled design preview, SEO, support and hosting | Built and delivered; production HTTP/CI verified; Search Console setup reported complete; indexing and visual acceptance pending | [Evidence](../verification/phase-04-website-and-hosting.md), [hosting guide](../guides/website-and-hosting.md) |
| 4A — Widgets/plugins | Reusable metadata protocol, native templates and local community authoring path | Native Hub, public v1 validator/CLI, local importer, templates and explicit metadata connection/revocation implemented; hardware acceptance open | [Contract](../plugins-and-widgets.md), [phase evidence](../verification/phase-05-plugin-sdk-and-agent-signals.md), [authoring guide](../guides/plugin-development.md) |
| 4B — Codex plugin | First opt-in provider adapter with verified source capabilities | Real quota exercised; advisory native hook bridge implemented/synthetically verified; client trust/delivery open; no approval actions | [Live evidence](../verification/native-live-widgets.md), [research](../research/codex-plugin-2026.md), [agent scope](../agent-awareness.md) |
| 4C — Native collection | Ten configurable mateonunez modules, unified Agents and Task Watch CLI | Built and locally exercised with real sources; OS consent and native interaction acceptance open | [Evidence](../verification/native-plugin-collection.md), [user guide](../guides/native-plugins.md), [authoring](native-plugin-authoring.md) |
| 5 — Distribution | Developer ID, notarization, downloads, updates and Homebrew | Not started | [Plan](../distribution.md) |

The design preview and verification tooling now share Node/Next.js; see [migration evidence](../verification/nextjs-preview-and-node-tooling.md). Trackpad gesture coverage remains [open](../verification/native-trackpad-coverage.md).

Build artifacts, screenshots and private logs are excluded from source control. A written checklist does not establish that its cases passed.

The first-activation biometric/gesture regression now has [native red/green lifecycle evidence](../verification/activation-readiness-regression.md). The corrected candidate still requires the original physical trial; automated passes do not establish gesture privacy or successful authentication.

The pre-beta catalog and SDK are locally verified across 18 web routes. Fresh profiles expose all ten native configurations disabled. One main scene replaces duplicated monitor content; physical acceptance remains open. See the [pre-beta audit](../verification/pre-beta-product-audit.md).

The next native candidate adds display-local measured canvas geometry, three presets, global widget-slot reservations and session hardening. It passes 65 Swift tests, 17 native collection checks and 17 isolated energy checks. Calendar consent, physical gestures/authentication and elapsed screensaver prevention remain open. See the [candidate report](../verification/main-display-canvas-and-native-hardening.md).

Continuous resizing now replaces named canvas sizes in the editor. The separately built `Still-canvas` candidate adds automatic widths, content-driven height and free placement. See [verification and remaining interaction checks](../verification/continuous-native-canvas.md).

The latest candidate removes the global four-card limit and includes every selected native module in presets. It passes the fifth/all-ten regressions and large-display geometry checks; actual display crowding remains an interactive acceptance item. See [capacity evidence](../verification/display-aware-plugin-capacity.md).

The latest native canvas supports adaptive Grid and preserved Free scenes. Grid aligns tracks/content rows and supports native insertion reorder; it passes 37 targeted Swift tests and 19 source checks. Dense small-display overflow and interactive smoothness remain acceptance items. See [grid verification](../verification/adaptive-native-grid.md).

The Glass/contextual-editor phase adds a second official theme, a widget gallery, native Grid drag sessions and persistent scene/module presentation controls. See [implementation](glass-and-contextual-editor.md) and [verification](../verification/glass-and-contextual-editor.md).

The [pre-beta refinement](pre-beta-refinement.md) adds model-owned theme persistence, visible advisory-source expiry, measured Free alignment and an exact-candidate [beta handoff](../guides/beta-handoff.md). [Evidence](../verification/pre-beta-refinement.md) keeps offline exports, live-source results and physical acceptance separate.

The [end-user beta preparation](private-beta-preparation.md) records release inputs, a macOS 14+/Apple Silicon and Intel compatibility target, and the remaining acceptance gates. Intel cross-compilation passed; older-system and Intel runtime acceptance remain open. No signing, notarization or beta distribution has been performed.

The [brand and copy phase](marketing-and-license.md) aligns the product message, website workflow and repository materials, adds the MIT license and public license notices, and preserves the current development/availability boundary. [Verification](../verification/marketing-and-license.md) separates the built-site audit from browser and remote delivery.
