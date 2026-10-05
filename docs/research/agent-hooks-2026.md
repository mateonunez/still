# Local agent metadata hooks

Research date: 2026-10-05. Scope: opt-in activity and advisory attention metadata for local Codex and Claude clients. This research does not prove installation, trusted execution, real approval capture, or native UI behavior.

## Findings and primary sources

The installed binaries report **Codex CLI 0.160.0** and **Claude Code 2.1.289**. `codex features list` reports `hooks` as stable and enabled. These commands inspect client capabilities, not conversations or credentials.

Codex supports command hooks loaded from `~/.codex/hooks.json` and inline configuration; matching sources merge. New or changed non-managed definitions require exact-hash trust through `/hooks`. Supported lifecycle events include SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, Stop, Interrupt and SessionEnd. PermissionRequest occurs before an approval request, and other hooks may decide it. SessionEnd covers normal closure, archive/delete of open conversations and eventual idle closure; unsubscribe alone does not immediately end a session. Stop output must be JSON when supplied. Source: [OpenAI hooks](https://learn.chatgpt.com/docs/hooks).

Claude command hooks are nested under `hooks` in `~/.claude/settings.json`. PermissionRequest also fires for calls that cannot prompt and would otherwise be denied. Notification `permission_prompt` is delayed about six seconds, can be suppressed by interaction or earlier answers, and covers sandbox-network prompts missing from PermissionRequest. PermissionDenied concerns auto-mode denial only. Stop does not fire for user interruption; StopFailure covers API errors. SessionEnd includes clear, resume, logout, prompt-input exit and other reasons. Claude hook input includes session_id and optional prompt_id (2.1.196+). Existing matching handlers run alongside Still. Source: [Anthropic hooks reference](https://code.claude.com/docs/en/hooks).

### Version-specific Codex schema evidence

The first-party **rust-v0.160.0** schema lists PermissionRequest fields `session_id`, `turn_id`, `hook_event_name`, `tool_name`, `tool_input`, `cwd`, `model`, `permission_mode`, `transcript_path`, and optional `agent_id`/`agent_type`. **No tool_use_id is available on PermissionRequest.** PreToolUse and PostToolUse have tool_use_id; therefore their tool identifiers cannot directly resolve a permission hook request. Sources: [PermissionRequest input](https://github.com/openai/codex/blob/rust-v0.160.0/codex-rs/hooks/schema/generated/permission-request.command.input.schema.json), [PreToolUse input](https://github.com/openai/codex/blob/rust-v0.160.0/codex-rs/hooks/schema/generated/pre-tool-use.command.input.schema.json), [PostToolUse input](https://github.com/openai/codex/blob/rust-v0.160.0/codex-rs/hooks/schema/generated/post-tool-use.command.input.schema.json).

The tagged Stop output schema accepts `{}` and defaults `continue` to true. A no-op observer must not return `decision`, `reason`, `continue: false`, or model context. Source: [Stop output schema](https://github.com/openai/codex/blob/rust-v0.160.0/codex-rs/hooks/schema/generated/stop.command.output.schema.json).

## Proposed minimal implementation

The following is a Still design recommendation, not a vendor API promise.

Use one compiled Swift helper with an explicit provider argument. Parse only a small Decodable allowlist from bounded stdin. Hook inputs can contain prompts, tool arguments, assistant text and transcript paths: **they reach the helper transiently, but must never be persisted, logged, displayed, or forwarded**. The helper must not open transcript_path or any other path from stdin. Account quota remains a separate source; activity cannot imply quota freshness.

### Input projection

These are deliberately incomplete projections, not complete vendor wire payloads:

```json
{"session_id":"example-session","turn_id":"example-turn","hook_event_name":"PermissionRequest"}
```

```json
{"session_id":"example-session","prompt_id":"example-prompt","hook_event_name":"Notification","notification_type":"permission_prompt"}
```

| Read temporarily | Purpose | Retain |
| --- | --- | --- |
| session_id | Isolate concurrent sessions | Local keyed digest only |
| hook_event_name | Map a known event enum | Normalized activity state/event enum |
| turn_id (Codex) / prompt_id (Claude, optional) | Avoid older-turn events clearing newer attention | Optional local keyed digest |
| agent_id, optional | Distinguish subagent observations | Optional local keyed digest; omit subagent counts until tested |
| notification_type (Claude only) | Admit only permission_prompt | Normalized attention event |
| receipt time | Bound stale information | Host-generated timestamp |

Reject empty/oversized identifiers and unsupported events. Never retain tool_name: MCP names can expose private service identities. No command, cwd, transcript_path, prompt, last_assistant_message, tool_input, tool_response, description, model, email or account identifier belongs in the projected data. A provider-scoped local random key used for HMAC avoids reusing raw session identifiers outside the bridge. Delete the key and metadata on explicit disconnect if no other consumer uses them.

### Hook configuration

Both providers use this command-handler shape. The command below is an illustrative absolute path; installers must quote the actual path for the client shell.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {"type":"command","command":"'/absolute/path/StillAgentBridge' codex","timeout":1}
        ]
      }
    ]
  }
}
```

For Claude replace the argument with `claude` and merge into its existing settings object. Append equivalent separate Still-owned groups for UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, Stop and SessionEnd. Add Interrupt only for Codex. Claude can additionally observe PostToolUseFailure, StopFailure, and Notification with `matcher: "permission_prompt"`. SessionStart/End should have no restrictive matcher. Do not add Notification to Codex; it is not a documented Codex hook event.

Use short synchronous hooks for a tiny metadata projection, with a bounded internal I/O budget and silent fail-open behavior. Background hooks can reorder events and complicate snapshot consistency. Do not return decision/context fields. Returning `{}` is a valid neutral Codex Stop response; silent exit 0 is suitable where output is optional. Never use exit 2. The helper should not send telemetry or make network calls.

Connect must be separate from quota Connect and explain that client hooks receive activity signals. Validate object/array shapes before changes, privately back up the current file, append exact owned groups, and atomically write only if the original bytes still match. Preserve existing groups, handler options, other settings, file symlink destinations and permission metadata. Disconnect removes only the exact groups installed by Still from the current file; never replace the entire file with an old backup. Externally edited Still entries require explicit conflict reporting.

Codex's normal `/hooks` review is a required client trust step. Do not bypass it or manufacture trust records. Retain "Awaiting client events" until a genuine bridge receipt arrives; creating a config file is not runtime evidence.

### Activity and attention mapping

| Event | Observation |
| --- | --- |
| SessionStart | Session available; running work is not yet established |
| UserPromptSubmit | Work observed; clear an older advisory attention signal |
| PreToolUse | Tool activity observed; does not mean approval required or execution completed |
| PermissionRequest | Attention requested; no approval count or final pending status |
| Claude permission_prompt Notification | Delayed attention signal |
| PostToolUse / Claude PostToolUseFailure | Tool progress/result observed; clear advisory attention on compatible session/turn |
| Stop | Turn stop observed; another hook may continue it |
| Claude StopFailure | Turn failure observed, without retaining error text |
| Codex Interrupt | Turn interruption observed |
| SessionEnd | Session end observed |
| No recent event | Stale/unknown, rather than running or pending forever |

Store per-session metadata and aggregate counts only for fresh observations. Protect writes with a short cross-process lock, atomic replacement, a fixed session cap and TTL. Concurrent hooks have no vendor sequence counter: arrival order cannot establish authoritative workflow order. Prefer retaining a short advisory signal over falsely claiming an exact approval was resolved. PostToolUse proves tool progress, not which PermissionRequest was answered. A missing turn/prompt identifier weakens correlation further.

UI wording should be **"Attention requested"**, **"Activity observed"**, **"Last observed …"**, and **"Open the agent client to review"**. Still must never execute approvals. Freshness expiry is essential because crashes, interruptions, permission denials, unattended long tools, missed trust and competing hooks can omit an expected terminal event.

## Evidence and acceptance still required

Only version/help/feature checks and primary schemas were inspected. No user hook configuration, conversation files or credentials were read or changed. No live approval hook was triggered.

Before describing the bridge as operational, test opt-in installation and conflict-safe removal against disposable files, privacy projection with sensitive decoys, concurrent sessions, oversized input, stale expiry, runtime timeout/failure, and genuine client-generated events after ordinary trust. Real approval presentation, answer/rejection and cancellation need separate client acceptance. A synthetic PermissionRequest fixture verifies parsing only.
