# Repository marketplace planning evidence

2026-10-07. This phase is research/product definition and truthful website copy, not a remote installer release.

- First-party Skills, OpenAI and Claude documentation compared in [research](../research/repository-plugin-marketplaces.md).
- Existing workspace CLI, PluginCenter, PluginStore, public SDK and native catalog inspected. The npm package remains private/unpublished; the importer supports local declarative packages, not arbitrary repository code or upgrades.
- [Product plan](../development/repository-marketplace.md) specifies Settings/CLI parity, inspect/review/configure/connect, pinned provenance, compatibility diagnostics and six vertical delivery slices.
- [ADR 0011](../adr/0011-repository-first-plugin-distribution.md) marks implementation choices proposed, rather than shipping contracts.
- Catalog/developer/home copy describes repository installation as in development. No working-looking remote npx command, marketplace endorsement, community size or automatic-update claim added.
- [Communication brief](../marketing/repository-marketplace.md) includes available-today wording, development-update draft, gated launch copy and real recording requirements. No campaign post published by this phase.

Open: discover/install implementation, actual npm publication, CLI/Settings acceptance, rich widget/configuration migration, upgrades/revocation tests, accessibility and clean-Mac trials. Repository/source availability is not installation proof.

## Checks and repository delivery

Biome checked 77 files; TypeScript and the production website build passed. The owned local website verifier passed all 20 canonical routes, noindex behavior, sitemap and share-image checks. No new interactive controls or installation actions were introduced.

The public npm lookup for `@mateonunez/still-plugins` returned HTTP 404 from registry.npmjs.org; no public package availability or scope ownership is claimed. GitHub issue #4 tracks the first discovery slice and follow-on install work. Accurate `swift` and `plugins` topics were added while preserving existing repository metadata.

HN/Product Hunt/GitHub channel recommendations use [official guidance](../research/launch-channel-fit.md). Marketing drafts are not published submissions; HN requires maker-written/manual participation. No leaderboard placement, votes, native conversion or install success is claimed.
