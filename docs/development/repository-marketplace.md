# Repository-first plugin marketplace

Status: product and engineering proposal, 2026-10-07. Repository installation is not implemented or published. This phase defines the experience and delivery sequence; it does not expand the executable runtime or publish an npm package.

## Product principle

**Your screen. Your sources. Your plugins.**

A compatible plugin should be discoverable and installable from its author's repository, without first submitting it to a central service. Still's public catalog helps people find useful packages; it is not the only installation authority. The CLI and Settings use the same compatibility decisions and receipts. A public listing is curation, not a security endorsement.

The current ten native adapters remain compiled first-party modules. The public SDK accepts strict declarative `.stillplugin` manifests, local metadata and constrained Porcelain templates. Importing a repository cannot turn a compiled adapter or an arbitrary agent plugin into a Still runtime extension. Codex/Claude/Skills packages may coexist in a repository; compatibility must be explicit.

## Experience for people

Settings gains a single Plugins workspace with **Discover**, **Installed** and **Add repository**. Retain per-plugin configuration and separate connection/visibility controls; do not create a second Settings window.

1. Paste a repository URL or choose a local folder. Show host, owner/repository and selected reference.
2. Inspect before downloading/installing. List compatible packages with names, authors, licenses, supported Still/protocol versions and clear reasons for incompatible entries.
3. Select packages. Review exact commit, files to import, declared data and source requirements. A repository name, star count or publisher field is not verified identity.
4. Install declarative packages, disconnected by default. Give each package a stable receipt. Installation must not run a producer, grant OS permissions, overwrite configuration or add a widget without a deliberate choice.
5. Offer **Configure**, **Connect source** and **Add to screen** as appropriate. A template has **Apply template**, with a preview of replaced composition and no source grant.
6. Installed shows installed version, origin, commit, connection state and last observation. Updates show version/source/contract changes before approval. Disconnect and Remove are distinct; removal must revoke host consumption before deleting owned package files.

States are explicit: Inspecting, Compatible, Incompatible, Installed, Needs configuration, Disconnected, Connected, Data unavailable and Update available. A fresh install does not say Connected. Unsupported repositories explain what is missing and link the authoring guide. Empty discovery is not success.

UI direction: native sidebar and system search; calm cards, readable detail panel, one primary action per state. Source/commit and access details belong in review/details, not persistent decoration on curtain cards. Preserve keyboard alternatives, VoiceOver state announcements, standard focus, reduced materials/motion, cancellation and retry.

## Experience for developers and agents

The intended published CLI is the existing personal package `@mateonunez/still-plugins`. It is currently private in the workspace and not published. The intended verbs are **inspect**, **add**, **list**, **check**, **update** and **remove**. Existing built-in configuration commands remain backward compatible; package versioning and final syntax are implementation deliverables.

- `inspect`: discovery and compatibility only; no host writes or source enablement.
- `add`: select package IDs, pin a resolved commit, review/import once. Interactive selection for humans; explicit IDs and structured output for agents.
- `list`: installed identities and provenance, with no private source values.
- `check`: compare pinned receipts with available versions without modifying packages.
- `update`: explicit selection and review; failure preserves old version/configuration. No automatic producer execution or automatic source reconnection.
- `remove`: revoke consumption and remove only owned imported content/receipt. Never delete an author's working repository or separately started producer.

Expose `--json`, stable typed error codes, nonzero exit status on incompatibility and a noninteractive explicit-selection mode. Machine output includes candidate IDs, compatibility reasons, resolved commit, declared data, actions taken and actions still required. Never print credentials, private snapshots or connection secrets. Stdout carries the result; diagnostics/progress go to stderr.

**Proposed, not a working install command:** after npm publication, the intended entry point is `npx @mateonunez/still-plugins ...`. Until then use documented workspace tools; do not advertise an install button/clipboard command that cannot succeed.

## Repository contract

Propose a separate versioned repository index, `still.plugins.json`, containing package paths and optional discovery copy. It does not replace the normative `.stillplugin/manifest.json` validator or grant capabilities. Index paths must be relative, bounded and unique, and remain inside the pinned repository tree.

Support an explicit `.stillplugin` directory path regardless of repository layout. For convenient discovery, inspect the root and bounded conventional plugin locations; an index avoids unrestricted recursive scans. A monorepo can contain multiple Still packages and unrelated products. Repository transport and package compatibility are separate: architecture must support HTTPS Git hosts and local repositories, not bake GitHub into package identity. First delivery targets public HTTPS Git and local paths; private host authentication requires a separate explicit flow.

Resolve a branch/tag to a commit once and inspect/import that same immutable tree. Never install from a moving branch after reviewing a different commit. Do not execute hooks, lifecycle scripts, submodules, LFS filters or repository commands. Bound file count, bytes and time; reject path escapes, symlinks, oversized files and executable payloads. Never run `npm install` in an author's repository.

Receipts record source locator, requested ref, resolved commit, package path/ID/version, protocol, manifest digest, installer version and installed time. This supports provenance and update comparison; a digest does not prove authorship or safety. Never preserve auth-bearing URLs. Store receipts separately from snapshots and host connection files.

## Compatibility and extension progression

Compatibility is determined by the host's actual validator and rendered capabilities, not a badge supplied by the repository. Report schema/protocol versions, package kind, supported theme/layout/capabilities and declared host requirements. Missing requirements mean Unknown, not certified compatible.

The repository transport can wrap current v1 packages first. Before calling the ecosystem generally customizable, resolve its real gaps: imported cards have a separate four-card budget, imported templates remain Porcelain-only, custom positioning/configuration and updates are not supported. Do not imply the native canvas's uncapped composition applies to imported v1 packages.

A future versioned SDK should expose constrained host-rendered text/metrics/progress/list/time widgets and typed configuration forms, with both official themes and the existing canvas. Specify migration and data classifications before implementation. Native data adapters and separately started producers remain distinct from declarative rendering. Arbitrary Swift/JavaScript/plugin execution, credential access and producer installation are separate architecture decisions, not hidden additions to repository support.

## Delivery slices and evidence

| Slice | Deliverable | Evidence required |
| --- | --- | --- |
| 1 — Discovery | Repository index/schema, bounded inspect, compatibility report, fixtures | Local/public HTTPS repositories, multiple packages, no packages, unsupported versions, traversal/symlink/oversize/timeout, no host mutation |
| 2 — Install | Shared native import transaction, disabled install, provenance receipt; CLI and Settings source review | Same candidates/reasons in both surfaces, pinned tree, atomic failure, duplicate/conflicting IDs, existing config preserved, cancellation |
| 3 — Manage | Installed, disconnect/remove, explicit update review and migration | Active source revocation, failed update preserves old package/config, permissions/identity changes require fresh consent, stale data not revived |
| 4 — Author | Versioned typed configuration and richer host widgets, author validator/starters | Contract parity, migration fixtures, rendering/geometry, both themes, keyboard/VoiceOver and revoked source behavior |
| 5 — Discover publicly | Repository-backed catalog, detail/install guidance, submissions via GitHub PR | Repository/commit/license/protocol visible, verified working command only after publication, no fabricated install counts or verification badges |
| 6 — Publish | Tested npm CLI release, docs/site/agent guide, coordinated announcement | Fresh npm invocation on a clean Mac, exact app compatibility and uninstall/update trials, matching published copy |

Slices are vertical: each has both user and developer outcomes. Keep account/payment services and arbitrary executable runners out of this plan. npm publication, a hosted listing, native distribution and operational acceptance remain separate evidence gates.

## Communication

- Landing: retain Still's calm-screen outcome first. Plugins are a supporting proof of personalization, not a second product with a competing hero.
- Catalog: use **Native collection** for shipped adapters and **Community packages** only when repository-backed packages can actually be installed. Show Compatible / Unsupported / Not yet checked instead of generic Verified.
- Developer page: readable quick start, package anatomy, compatibility, local validation, source review, configuration and lifecycle. Mirror machine-readable contracts for agents.
- Posts: explain the experience with a real install recording and a working package once shipped. Development updates can state what is being built; they must not imply repository installation is available today.
- Measure useful outcomes separately: discovery → compatible selection → install → configured connection → visible widget. Website analytics do not prove any native transition. No native telemetry is introduced by this plan.

Primary-source comparison: [repository marketplace research](../research/repository-plugin-marketplaces.md). Rollout copy: [marketplace communication](../marketing/repository-marketplace.md).
