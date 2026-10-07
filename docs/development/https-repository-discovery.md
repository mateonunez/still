# Public repository discovery slice

Implemented 2026-10-07. The workspace CLI wraps local native discovery with public HTTPS Git source resolution. People can select a repository folder/package; agents receive machine-readable compatibility plus the resolved commit. This completes the transport path for read-only discovery, with explicit resource/host limits.

The Node layer owns transport and safe file projection. Swift remains normative for package compatibility, matching native import. No author repository checkout, runtime execution, permission grant, installation or source connection is added. [Guide](../guides/plugin-development.md#inspect-public-https-repositories-from-the-workspace) · [Evidence](../verification/https-repository-discovery.md).

Before installation delivery, add reviewed source retention/refetch verification, a shared native transaction/receipt contract and parity in Settings. Tighten resource acceptance and cancellation before calling discovery ready for arbitrary untrusted repository inputs. npm publication still requires a bundled normative validator rather than a workspace source dependency.
