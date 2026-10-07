# Local discovery vertical slice

Implemented 2026-10-07 as the first local portion of the [repository marketplace plan](repository-marketplace.md).

People and agents can inspect local packages before importing them. The native library exposes one compatibility engine reused by import and the CLI; JSON consumers receive stable overall/candidate compatibility, relative paths, validated metadata, rejection reasons and actions taken. Unsupported or empty discovery cannot appear as successful installation.

The repository index is schema version 1 with package paths only. No new capability, execution or permission is granted by discovery. The existing examples demonstrate multi-package repositories without a catalog service. [Authoring guide](../guides/plugin-development.md#inspect-a-local-repository) · [Evidence and boundaries](../verification/local-repository-discovery.md).

Next slice: resolve public HTTPS source references into a bounded immutable tree, then use the same inspection result in reviewed CLI/Settings import transactions. Keep transport, package validation and source connection separate.
