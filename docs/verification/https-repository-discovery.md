# HTTPS repository discovery

2026-10-07. Scope: read-only workspace CLI discovery; no host installation, native release, website deployment or npm publication.

## Delivered

The Node CLI's `inspect` accepts local folders and public HTTPS Git URLs, with explicit revision/subdirectory/package selection. It resolves the fetched reference to a commit, projects package/index files from raw objects, delegates compatibility to the native Swift CLI and removes its temporary tree. JSON records source/commit alongside the normative compatibility report. Existing built-in list/add commands are retained.

Git environment/configuration is isolated. Credentials and URL queries/fragments are rejected; prompts, helpers, redirects and alternate transports are disabled. No checkout, repository package scripts, submodule recursion or producer connection is performed. Projection rejects symlink/executable modes, unsafe paths, unsupported tree entries and oversized blobs. Child output/time and tree/projection sizes are bounded; fetched disk size is sampled and may overshoot.

## Verification

- `pnpm --filter @mateonunez/still-plugins test`: 13 tests passed (existing four plus nine new cases).
- Real temporary Git repositories: immutable projection despite working-copy changes, index selection, subdirectory and single-package scopes, symlink/executable/traversal rejection, oversized blobs and submodule rejection.
- Process tests: elapsed timeout, output limit, isolated configuration/credentials and structured CLI failure without credential echo.
- Live HTTPS: `https://github.com/mateonunez/still.git`, requested `main`, `examples/plugins`, resolved `53f8f03cc997d319f0e35a1b44030b07dddf04ca`; two compatible packages, empty actions taken.
- Live pinned commit: same source/commit, `examples/plugins/local-signals.stillplugin`; one compatible package, empty actions taken.
- Biome and whitespace checks passed. Native validator was actually invoked in both live trials; no JavaScript manifest compatibility reimplementation was used.
- Logs/reports remain ignored under `out/verification/https-repository-discovery/`.

A new CLI test initially failed because it assumed workspace-root cwd while pnpm executes package tests from the package directory. It now resolves the CLI relative to the test file, and the suite passes from pnpm.

## Open boundaries

Only GitHub HTTPS was exercised live; transport is host-independent but other hosts are not certified. Private/SSH authentication, redirects, cancellation UI, bundled validator delivery, fault-injected fetch timeout/disk-overrun and strictly enforced network/resource budgets remain open. No malicious-server sandbox is claimed. Config isolation does not constitute proof against unknown Git vulnerabilities.

No installation receipt is retained. CLI/Settings reviewed import must preserve the inspected commit/tree or refetch and verify it before installation, with atomic rollback and explicit disconnected state. Updates/removal and richer imported widgets/configuration remain later slices. Existing owner native candidates were untouched. This phase does not prove native plugin configuration or physical runtime acceptance.
