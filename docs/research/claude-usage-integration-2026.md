# Claude usage integration

Research date: 2026-10-05. Installed Claude Code: **2.1.289**. This note records source feasibility and a proposed integration; no account request, connector installation or settings change was performed.

## Recommended source

Use Claude Code's documented **status-line stdin JSON**, projected by a native Still helper into a small local usage file. Claude Code retains ownership of authentication. CodexBar is useful as a behavior reference, but is unnecessary for this path.

Anthropic added status-line `rate_limits` in **2.1.80**; the installed version is newer. A later fix prevents expired windows retaining their pre-reset percentage. [Official changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md#2180)

The documented fields are `rate_limits.five_hour` and `rate_limits.seven_day`, each with `used_percentage` (0–100) and `resets_at` (Unix seconds). Subscription windows are available for claude.ai Pro/Max after the first API response; each may be absent and is removed after expiry. Gateway spend limits are a different measurement. Status-line execution is local and costs no API tokens. Updates include assistant responses, compaction, mode/config changes and reset events. An optional refresh interval reruns the script; the documentation does not promise a fresh account request on each rerun. [Official status-line contract](https://code.claude.com/docs/en/statusline#available-data)

The installed `claude --help` exposes no standalone quota JSON command. `--output-format json` belongs to print/model execution; `claude auth` offers login, logout and status rather than quota. Do not send a model prompt solely to refresh a widget. [Official CLI reference](https://code.claude.com/docs/en/cli-reference)

## Proposed native bridge

This section is implementation advice, not an Anthropic API guarantee.

1. Provide a `Still --claude-statusline` mode that executes before AppKit startup. Consume bounded stdin in memory and project only allowed quota fields; never read `transcript_path`, credential files, browser stores or conversation history.
2. Atomically write a versioned envelope to `~/Library/Application Support/Still/usage/claude.json`, with owner-only permissions. Reject symlink substitutions and invalid/nonfinite percentages or timestamps. Keep all unrelated input keys out of the file and logs.
3. Preserve the previously configured status-line command and its options. Forward the same stdin to that existing command, preserving its stdout. Its own behavior remains user configuration rather than Still's permission to inspect more data. Avoid recursive wrappers and use bounded subprocess lifetime/output handling.
4. Native widgets read only the projected envelope. Label the source as **Claude Code status line**, and timestamp as **reported**, without claiming an independently verified provider refresh.
5. Keep the first connection explicit in the Hub: explain the exact settings patch, retain a backup, and provide a conditional restore that never overwrites subsequent user edits. Merely adding a widget should not silently replace an established terminal customization.

The existing local user settings have a `statusLine` object with `type`, `command` and `padding`. A command exists (26 characters). Only this shape was reported; the command itself and unrelated settings were not printed or modified.

Suggested projection semantics:

| Input | Native meaning |
| --- | --- |
| `rate_limits.five_hour.used_percentage` | Five-hour quota consumed; never context-window usage |
| `rate_limits.five_hour.resets_at` | Optional absolute reset instant |
| `rate_limits.seven_day.used_percentage` | Weekly quota consumed |
| `rate_limits.seven_day.resets_at` | Optional absolute reset instant |
| Missing window | Unavailable, never 0% used or 100% remaining |
| `context_window`, `cost`, model and identity keys | Excluded from this quota-only projection |

Do not copy the full input: it can contain workspace identifiers, transcript paths and session names. A versioned projection allows future providers without exposing arbitrary vendor payloads. [Official input schema](https://code.claude.com/docs/en/statusline#available-data)

## Availability and acceptance

- **Waiting for data:** bridge configured but no real payload received. A normal user-driven Claude response is needed; a synthetic fixture is not connection proof.
- **Unavailable:** no supported numeric window in the latest report. Show an explanation and retain neither invented quotas nor a successful-looking zero.
- **Stale:** old report or expired window. Retain optional last-known values visibly dated, or hide expired windows; do not advance reset times or infer a refill.
- **Invalid:** malformed/oversized payload. Discard safely; preserve the existing status-line behavior and avoid logging the input.
- **Concurrent sessions:** independent writers need atomic replacement. Without account identity, this is the latest report from the connected Claude Code environment, not verified multi-account aggregation. Do not sum repeated windows.
- **Freshness:** an observation timestamp proves receipt, not a new server measurement. Repeated unchanged reports must not be advertised as continuously verified account usage.
- **Approvals/task activity:** outside this quota contract. No fabricated approval count, running-agent status or task progress can be inferred from percentage changes.

Required real acceptance: configure the bridge without losing the existing status line; perform ordinary Claude work; confirm nonempty projected windows reach the native widget; test expiry, disconnected CLI and restore. Research alone does not establish that this account exposes supported windows.

## CodexBar reference and optional fallback

Pinned reference: **steipete/CodexBar v0.71.1**. Its Claude CLI path launches Claude in a dedicated PTY, requests `/usage`, optionally `/status`, and parses rendered terminal screens. It disables configured MCP servers for its probe and may use a non-PTY fallback. It also manages probe-local transcript artifacts; that is materially more intrusive than observing an existing user session's documented metadata. [Pinned Claude provider guide](https://github.com/steipete/CodexBar/blob/v0.71.1/docs/claude.md#cli-pty-fallback)

The explicit CLI command is:

```sh
codexbar usage --provider claude --source cli --format json --json-only
```

Useful output mapping: `usage.primary/secondary.{usedPercent,windowMinutes,resetsAt}` and `usage.updatedAt`; require `provider == "claude"` and the expected CLI source. Errors and missing values remain unavailable. Exit codes distinguish missing executable (2), parse error (3), timeout (4) and unexpected failure (1). Avoid `auto`, web/OAuth source modes, `cost`, dashboard/serve and browser enrichment for a strictly quota-only bridge. [Pinned CLI guide](https://github.com/steipete/CodexBar/blob/v0.71.1/docs/cli.md)

The source separates `usage` fetching from the local cost command, but this is **not** a whole-process no-transcript-access audit or an assertion that user/custom CLI settings have no side effects. Do not claim a proven zero-read boundary from a command name alone. [Usage command implementation](https://github.com/steipete/CodexBar/blob/v0.71.1/Sources/CodexBarCLI/CLIUsageCommand.swift), [Claude fetcher](https://github.com/steipete/CodexBar/blob/v0.71.1/Sources/CodexBarCore/Providers/Claude/ClaudeUsageFetcher.swift)

If the fallback is deliberately selected later, the maintainer provides separate macOS arm64/x86_64 CLI archives and SHA-256 sidecars. For arm64, the release archive digest observed was `b6be8fe4b9b4baefbd63997ec795f5961fe53d9319fca5eb782dc1cc0458f3b6`. Obtain it only from the official release, verify its checksum and archive contents, and install locally rather than changing personal system tooling implicitly. No archive was installed during this research. [Official v0.71.1 release](https://github.com/steipete/CodexBar/releases/tag/v0.71.1)
