# Development status

Implementation, automated verification and manual acceptance are tracked separately. Reports include both passing checks and unresolved limitations.

## Phases

| Phase | Deliverable | Status | Evidence |
| --- | --- | --- | --- |
| 0 — Fundamentals | Porcelain light/dark, brand, product scope and delivery plans | Prepared | [Brand](../brand-fundamentals.md), [design](../../DESIGN.md) |
| 1 — Native curtain | Menu bar, display presentation, system authentication and ordinary recovery | Step 1A built/structurally verified; Step 1B manual acceptance pending | [Phase 1](../verification/phase-01-native-curtain.md), [interaction refinement](../verification/phase-01-interaction-refinement.md), [visual polish](../verification/phase-01-visual-polish.md) |
| 2 — Idle and power | Inactivity and native materials; energy implementation retained with controls hidden | Native lifecycle verified; energy concept deferred; Mission Control/Spaces findings open | [Phase 2](../verification/phase-02-idle-and-energy.md), [latest refinement](../verification/phase-02-deferred-awake-and-spaces.md), [guide](../guides/idle-and-energy.md) |
| 3 — Product experience | Onboarding, preferences and accessibility acceptance | Not started | — |
| 4 — Website | Next.js landing, labelled design preview, SEO, support and hosting | Built and delivered; production HTTP/CI verified; search indexing and visual acceptance pending | [Evidence](../verification/phase-04-website-and-hosting.md), [hosting guide](../guides/website-and-hosting.md) |
| 5 — Distribution | Developer ID, notarization, downloads, updates and Homebrew | Not started | [Plan](../distribution.md) |

Build artifacts, screenshots and private logs are excluded from source control. A written checklist does not establish that its cases passed.
