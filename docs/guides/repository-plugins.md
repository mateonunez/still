# Repository plugins: what to expect

Status: planned workflow. Remote repository installation and a public npm installer are not available yet. Current authoring/import: [plugin development](plugin-development.md).

## For people

The planned Settings flow is Plugins → Add repository → inspect compatible packages → review source and exact version → install → configure → connect → add to screen. Installing does not authorize a data source. A package can be installed while disconnected or awaiting configuration.

The catalog will help with discovery, but a compatible package should not need a catalog listing to be installed from its author's repository. Unsupported packages explain the host/protocol/capability mismatch. A Skills, Codex or Claude package is not automatically a Still package.

Updates should show what changes before replacing the installed version. Disconnect revokes Still's consumption; removal deletes only owned imported content. Separately installed producers and their OS permissions remain outside Still's control.

## For authors and agents

Keep a supported `.stillplugin` package with a valid manifest in your repository. The proposed optional `still.plugins.json` index will describe package paths in multi-package repositories; its final schema is not published yet. Do not add speculative fields to the current strict v1 manifest.

Planned inspection returns package IDs, compatibility reasons and resolved source commit without installing or enabling anything. Agent workflows will use structured results and explicit selections. npm syntax and publication are delivery work; no working npx command is documented before clean-install acceptance.

Until that path ships, validate locally and use native Import package. Still does not execute repository hooks/scripts or launch a producer as part of import. Preserve manifest/license provenance and mark fixtures as samples.

[Product contract and delivery slices](../development/repository-marketplace.md) · [Marketplace research](../research/repository-plugin-marketplaces.md) · [Implementation issue](https://github.com/mateonunez/still/issues/4).
