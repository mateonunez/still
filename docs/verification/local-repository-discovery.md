# Local repository discovery

2026-10-07. Scope: native read-only discovery and CLI compatibility; no repository fetch, installation, website deployment, package publication or native release.

## Implemented

`StillPluginKit.RepositoryDiscovery` accepts a local repository or one `.stillplugin` directory. Optional strict `still.plugins.json` selects bounded relative package paths. Without an index, only immediate root and `plugins` children are considered. Package validation is shared with `PluginStore.importPackage`; `validate` no longer creates a temporary store. Imports persist the validated manifest by encoding its typed value.

`still-plugin inspect <path> [--json]` reports compatibility, validated manifests or typed rejection reasons, and empty `actionsTaken`. Empty discovery is not compatible. Invalid indexes/unsupported versions and CLI usage have nonzero statuses. Discovery never runs package contents, connects a source or writes to the host store.

## Evidence

- `swift test --package-path packages/StillPluginKit`: 15 tests passed, including existing import, connection/revocation and snapshot tests.
- New cases cover mixed compatibility, duplicate IDs, nested indexed packages, traversal, linked ancestors/packages, executable payloads, oversized manifests/indexes, index versions/unknown fields and directory/package limits.
- Actual CLI boundary checks passed: two compatible example packages/JSON, empty discovery/status 1, unsupported index/structured failure/status 1, invalid syntax/status 2 and standalone manifest validation/status 0.
- Example index/schema formatting and staged whitespace checks passed.
- Local logs/report: ignored `out/verification/local-repository-discovery/`.

## Limits

Local directories are mutable; no immutable commit/provenance receipt is claimed. This is not a concurrent hostile-filesystem isolation boundary. All followed directory components must be nonsymlink canonical paths. Discovery does not recurse beyond the documented locations; larger repositories should provide an index. Swift package compilation may write build caches; repository packages and the host store are not modified by inspection.

HTTPS transport, bounded fetching/timeouts, shared CLI/Settings installation review, transactions, receipts, updates/removal and public npm distribution remain open. The v1 imported rendering contract retains its existing constraints. Existing interactive native candidates were not replaced or stopped. No native runtime or physical acceptance is inferred from these checks.
