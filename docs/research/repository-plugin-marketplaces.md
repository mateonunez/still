# Repository plugin marketplaces

Research date: October 7, 2026. Sources are first-party documentation and maintainer repositories. These are documented mechanisms, not installation or runtime trials. No packages were installed and no external account state was changed.

## Verified reference mechanisms

### Skills: repository-first discovery

The Skills CLI accepts GitHub shorthand, repository/subdirectory URLs, GitLab, other Git URLs and local paths. `npx skills add owner/repo --list` discovers without installation; `--skill` selects named entries. Public and private repositories use the same interface with existing Git authentication. Discovery reads `SKILL.md` frontmatter (`name`, `description`), searches conventional containers to bounded depth, and also reads Claude plugin declarations. The CLI detects agent targets, supports project/global scopes, and provides list, remove, update and init commands. Basic skills share a specification, but some capabilities remain agent-specific. These compatibility claims concern agent instructions, not native widgets. [Maintainer README](https://github.com/vercel-labs/skills)

The public directory ranks installations using CLI telemetry. Its documentation describes routine audits but explicitly declines to guarantee every listing's safety; installation remains a review decision. A directory listing therefore is not a security endorsement. [Skills documentation](https://www.skills.sh/docs)

### OpenAI: package, catalog and connection are separate

Current packaging documentation specifies portable root `plugin.json` using the Agent Plugins schema, root `skills/` and optional `mcp.json`. OpenAI-specific metadata lives in `extensions.com.openai`; `.codex-plugin/plugin.json` remains a fallback. Catalogs use `.agents/plugins/marketplace.json` and relative plugin sources. `codex plugin marketplace add` accepts shorthand, Git URLs and local directories, with ref pinning and sparse checkout; list/upgrade/remove manage catalog sources. The documentation directs local installation/testing to the ChatGPT desktop app. Repo discovery, workspace publication and public directory submission are distinct paths. Bundled hooks require explicit trust, and hook-containing packages are ineligible for the public directory. [Package your plugin](https://developers.openai.com/plugins/build/plugins)

ChatGPT and Codex share a universal directory, but capabilities can depend on the surface and available execution environment. [Plugin architecture](https://developers.openai.com/plugins/concepts/plugins)

Installing a plugin does not bypass provider authorization or workspace restrictions. Bundled apps may require separate connection/setup. [Plugins in ChatGPT and Codex](https://help.openai.com/en/articles/20001256-plugins-in-codexOpenAI)

### Claude Code: catalogs, scoped installs and visible updates

A repository catalog is `.claude-plugin/marketplace.json`, with `name`, `owner` and `plugins`; each entry supplies a name and source. Registration and installation are separate: `claude plugin marketplace add owner/repo`, then `claude plugin install name@marketplace`. Entries can use local relative paths, GitHub, Git subdirectories, other Git hosts, HTTPS archives, npm packages or command-generated directories. Git sources support ref/SHA pinning. Validation catches schema/path issues; fetching and installation can fail separately. Keep entry and manifest names aligned. [Create a marketplace](https://code.claude.com/docs/en/plugin-marketplaces)

Plugin metadata/configuration uses `.claude-plugin/plugin.json`; components stay at the package root. The manifest can declare skills, hooks, MCP/LSP servers and dependencies. `userConfig` defines prompts with types, labels, descriptions, defaults and required values. Paths must remain inside the plugin root. Validation coverage varies by Claude Code version, so valid JSON alone does not establish runtime compatibility. [Manifest reference](https://code.claude.com/docs/en/plugins-reference)

The `/plugin` UI and shell commands manage the same settings. Installation supports scopes. Third-party auto-update is off by default; official sources have different defaults. Updating a catalog listing and updating installed plugins are distinct actions. A running session keeps loaded versions until reload/new session. [Install and manage plugins](https://code.claude.com/docs/en/discover-plugins)

Claude plugins can execute code with user privileges through hooks, processes and other components. Tool-call permissions do not sandbox independently executed plugin code. Official names are reserved to Anthropic sources; some community entries are commit-pinned. Review source, components and update behavior before installing. [Plugin security and trust](https://code.claude.com/docs/en/plugins/security)

## Recommendations for Still

These are product/design recommendations, not implemented capabilities or interoperability claims.

1. **One shared install contract.** CLI and Settings should both resolve a repository, enumerate compatible packages, show a review plan, validate, install atomically and return the same receipt. Make discovery and inspection read-only. Avoid two different installers with different compatibility rules.
2. **Repository distribution independent of the catalog.** A compatible repository should be installable without first obtaining a public listing. The website catalog adds discovery, screenshots and documentation; it should not become a gatekeeper or require accounts/payments.
3. **Explicit Still compatibility.** A Skills/Codex/Claude repository is not automatically a Still plugin. Require Still's declared schema/runtime contract. Preserve the distinction between declarative community packages and compiled built-in providers; importing metadata must not imply access to new native APIs.
4. **Separate installation, configuration and permission.** Review identity, source URL, resolved commit, plugin version, compatibility and requested capabilities before installation. Afterwards, show configuration prompts and obtain any necessary system permission through the native app. An installed plugin can legitimately be unconfigured, disconnected or disabled.
5. **Reproducible receipts and controlled updates.** Record repository, requested ref, resolved commit, selected package path, content digest and manifest version. Display changes before updates, retain a working previous version, and require renewed review if capabilities expand. Ref names and content hashes are provenance evidence, not publisher verification.
6. **Bounded declarative import.** Do not execute repository install scripts, npm lifecycle hooks, manifest commands or downloaded binaries as part of the first contract. Reject path escapes, symlinks escaping the package, unknown runtime kinds and excessive file/content sizes. Schema validation cannot prove trustworthy content.
7. **Clear developer diagnostics.** Report missing manifests, unsupported schema/runtime, incompatible host versions, invalid paths, network/authentication failures and configuration requirements separately. Machine-readable output should distinguish inspection results from successful installation.
8. **Honest launch communication.** Use a real package name only after availability is verified. Never publish a working-looking `npx` command before the package is actually published and clean-install tested. Label native built-ins, installed repository packages and proposed packages distinctly. Show one terminal walkthrough and one Settings walkthrough using the same real package.

## Evidence still needed

- Decide and document the first supported repository transports; arbitrary Git hosts, private authentication and archives have different implementation requirements.
- Confirm an available personally owned npm scope/package name before public installation instructions or publication.
- Define the supported Still host/schema versions and configuration field types before promising compatibility.
- Verify install/update/remove parity in CLI and Settings with real repository fixtures, failure recovery and clean user data.
- Verify the native app can consume the declared community package kind. A successful importer or catalog card is insufficient runtime evidence.
- OpenAI's documentation currently mixes portable packages with legacy fallback manifests and surface-specific installation. Recheck those surfaces before claiming equivalent feature availability; no local Codex/Claude plugin install was tested here.
