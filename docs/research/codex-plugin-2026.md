# First Codex plugin: source and capability assessment

Research date: 2026-10-04. This is a decision input for Still's plugins/widgets phase before beta and native distribution, not an implemented integration or native runtime proof.

## References and verified boundary

CodexBar's latest published release at inspection was **v0.71.1**, published 2026-10-03, resolving to commit **c04fc93f91f17984d9dff93a556e553e750f2c1c**. All CodexBar source links below use that immutable commit. [Release](https://github.com/steipete/CodexBar/releases/tag/v0.71.1).

The installed Codex executable reported **codex-cli 0.160.0**. Read-only `--version`, `app-server --help`, and protocol schema generation were inspected; generated schemas stayed in temporary storage. No usage fetch, login, credentials, session histories, cookies, or private caches were accessed. No `codexbar` executable was found on PATH, so CLI output and authenticated behavior remain unverified locally.

## What “CodexBar standards” can mean

CodexBar publishes a **project-specific provider contract**, not an established universal agent-observation standard. Its native providers use descriptors, provider-owned fetch strategies, and a shared app/CLI pipeline. It also publishes a genuine local JavaScript/TypeScript plugin interface with manifests and sandboxed host APIs. That interface cannot launch subprocesses, access arbitrary local files, or use native APIs. It is a contract for providers *inside CodexBar*, not an embedding contract for Still. [Provider authoring](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/docs/provider.md), [local plugin contract](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/docs/plugins.md), [canonical TypeScript declarations](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCore/Resources/Plugins/codexbar-plugin.d.ts).

For Still, following its conventions means preserving provider identity, source, quota windows, reset dates, freshness and unavailable states in a small typed adapter. It does not require importing its plugin runtime or credential machinery.

## Evidence table

| Capability | Assessment | Evidence and limit |
| --- | --- | --- |
| Codex account quota and resets | Supported in protocol/source; local integration needs spike | Official `account/rateLimits/read`; CodexBar CLI strategy starts its own RPC client, reads rate limits/account, and shuts it down. This reports account allowance, not the activity of an existing conversation. [Official app-server](https://learn.chatgpt.com/docs/app-server), [RPC implementation](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCore/UsageFetcher.swift). |
| Units and freshness | Supported representation | CodexBar `RateWindow` carries `usedPercent`, nullable `windowMinutes` and `resetsAt`; `UsageSnapshot` carries `updatedAt`. Percentage is quota utilization, not token count, money, progress or elapsed runtime. Its observation timestamp does not prove a live run. Missing windows stay unavailable; derive “remaining” explicitly from “used.” [Models and mapping](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCore/UsageFetcher.swift). |
| Account/source separation | Supported representation; mapping needs spike | CLI payload includes `provider`, optional `account`, `version`, `source`, `usage`, `error`. `version` must not be assumed to mean CodexBar's schema version. Treat identity as private; display an opaque local account label. Do not mix accounts/workspaces or carry an old observation across account changes. [CLI payload](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCLI/CLIPayloads.swift). |
| Service status | Supported; different meaning | CLI `status` describes provider outage/maintenance, not agent running/idle/blocked. It cannot establish that a particular task needs attention. [Status payload](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCLI/CLIPayloads.swift). |
| Session lifecycle and attention | Official mechanisms exist; needs spike | App-server exposes thread/turn lifecycle notifications and runtime flags including `waitingOnApproval` and `waitingOnUserInput`. A spawned server is not proof of monitoring a different client's active session. Schema presence proves a format, not access to the intended original client. [Official protocol](https://learn.chatgpt.com/docs/app-server). |
| Passive lifecycle hook bridge | Official hook contract exists; needs spike | Trusted command hooks include `SessionStart`, `UserPromptSubmit`, `PermissionRequest`, `Stop`, `Interrupt`, `SessionEnd`. A metadata emitter could observe configured future sessions without transcripts. `PermissionRequest` precedes the prompt; it alone does not prove the prompt is still unresolved. Hooks receive sensitive fields, so discard prompts/tool inputs/transcript paths before emitting. [Official hooks](https://learn.chatgpt.com/docs/hooks). |
| Executable approval from Still | Excluded from first scope | App-server approval requests require decision responses. Hook approval decisions can change execution. A notification is not authorization or a guaranteed actionable approval handle. Keep the original client responsible. [Approvals](https://learn.chatgpt.com/docs/app-server#approvals). |
| Per-conversation tokens/costs | Missing in selected first source | CodexBar's cost command scans local histories; do not import it. Account quota cannot estimate conversation tokens, costs or completion. [CLI cost contract](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/docs/cli.md). |

## Minimal first integration proposal

Use a disabled-by-default Still Codex adapter and an optional, separately installed CodexBar CLI. A version-pinned **candidate** invocation, verified against v0.71.1 documentation/options/source but not executed, is:

```sh
codexbar --version
codexbar usage --provider codex --source cli --format json --json-only --timeout 15
```

The first command is a compatibility gate: the caller must require its tested CodexBar version before parsing. Use a resolved executable directly, without shell interpolation. Bound execution/output, read stdout as one JSON document, inspect both exit status and payload errors, and retain only the allowed quota fields. `--source cli` selects the sole CLI strategy and avoids automatic web/OAuth selection; do not assume `--no-credits` removes sensitive JSON fields. [CLI reference](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/docs/cli.md), [options](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCLI/CLIOptions.swift), [strategy selection](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/Sources/CodexBarCore/Providers/Codex/CodexProviderDescriptor.swift).

Still must not read credentials itself. Codex/CodexBar retain their own existing authentication/config behavior; “read-only usage” does not guarantee that a delegated provider process never refreshes authentication or touches its own caches. Never initiate login, account switching, daemon restart, reset-credit consumption or email nudges from this adapter. Unsupported authentication, missing CLI and offline conditions produce an unavailable state.

Keep **usage** and **lifecycle** as separate sources. If a lifecycle bridge is added, forward only opaque session/turn identifiers, event kind and observation time through bounded local IPC. Return no approval decisions, blocking outputs or additional model context. An event timestamp is not a heartbeat: missed events or abrupt client exit must expire to unknown. Hooks need explicit trust and cannot retroactively establish activity in uninstrumented sessions. Default interaction is **Open Codex**, after leaving the curtain through its normal authentication flow; exact-thread navigation needs separate proof.

## Licensing and proof required

CodexBar is MIT-licensed, copyright 2026 Peter Steinberger. Copying code or bundling binaries requires preserving its copyright/permission notice; bundled dependencies/resources require their own inventory. Optional invocation of a user-installed executable avoids redistributing that binary but still requires clear dependency/provenance documentation. No branding endorsement or CodexBar compatibility certification is implied. [License](https://github.com/steipete/CodexBar/blob/c04fc93f91f17984d9dff93a556e553e750f2c1c/LICENSE).

Before accepting the plugin/widget phase:

1. Capture redacted fixtures from the pinned versions and a controlled test account; prove units, nulls, missing windows, timestamps, resets and identity boundaries.
2. Reproduce unavailable authentication, offline, timeout, malformed/oversized output, incompatible versions and cancellation; verify subprocess cleanup and stale-to-unknown behavior.
3. Confirm the selected CLI path performs no cookie import, transcript/cost scan or private-cache import into Still; verify no credential/log leakage from diagnostics.
4. In a disposable instrumented session, prove start, work, approval-needed, resolution, completion, interruption and abrupt exit. Test the intended Codex app/CLI separately. Keep unrelated sessions explicitly unknown until an authorized bridge is proven.
5. Confirm metadata-only hooks cannot approve, deny, block or continue work and introduce no material interaction delay. Treat sensitive hook input as ephemeral and never persist it.
6. Verify readable widget states and privacy while the curtain is active; opening the original client must preserve authentication and OS recovery. Native proof and beta/distribution readiness remain separate acceptance gates.
