# Developing Still plugins

This guide covers the implemented first-party adapter path and the proposed community extension path. Still currently ships native Codex and Claude quota adapters. There is no installable third-party plugin SDK, package importer or marketplace yet. A manifest alone cannot install or execute a plugin.

## Choose the extension

| Extension | Supplies | Current authoring path |
| --- | --- | --- |
| Data adapter | Validated facts such as account quota and reset | Contribute reviewed Swift code to the native app |
| Widget | Host-owned presentation of validated facts | Extend native SwiftUI views with tests and accessibility review |
| Template | Appearance and composition of approved slots | Built-in Quiet corner and Side rail; package import is planned |
| Community package | Declarative manifest, templates and supported adapter capabilities | Proposed contract; no external executable runner |

An adapter never owns return/authentication or arbitrary curtain UI. A template never enables a source. Quota percentages are account usage, not task progress. Approvals remain in the original agent client until a separate supported source is implemented.

## Understand the current modules

- `packages/StillWidgets/Sources/StillWidgets/UsageSnapshot.swift`: typed quota model, validation and provider input projections.
- `packages/StillWidgets/Sources/StillWidgets/ClaudeBridgePlan.swift`: pure settings patch/restore contract.
- `apps/macos/Sources/Still/CodexUsageAdapter.swift`: bounded, cancellable request process.
- `apps/macos/Sources/Still/ClaudeBridgeInstaller.swift` and `apps/macos/Sources/StillClaudeBridge/main.swift`: reversible installation and local metadata projection.
- `apps/macos/Sources/Still/WidgetCenter.swift`: opt-in connection, polling, stale data, cancellation and persistence.
- `apps/macos/Sources/Still/WidgetsView.swift`: host-rendered Hub/card.
- `apps/macos/Sources/Still/CurtainView.swift`: host-controlled placement on the curtain.

`UsageSnapshot` version 1 contains `provider`, `observedAt` and one or two `UsageWindow` values. Each window has its actual duration in minutes, finite used percentage and optional reset time. It accepts at most five minutes of observation age and five seconds of future clock skew. Percentages are 0–100 and duration is 1–44,640 minutes. Unknown, malformed or expired information is unavailable; never invent zero usage.

The current `Codable` encoding is an internal Swift file format: dates use JSONEncoder's default seconds since 2001-01-01. It is **not** the proposed public plugin wire format. Do not copy these numbers into an interoperable community protocol; that protocol still needs an explicit date encoding and versioned schema.

## Build a first-party quota adapter

1. Verify a supported metadata API from primary provider documentation. Record client versions and the exact quota meaning in `docs/research`. Avoid undocumented credential, cookie, transcript and private-cache scraping.
2. Add a provider case/title in `UsageProvider`. The enum is intentionally closed today; adding a case is a source contribution, not runtime plugin discovery.
3. Implement a pure projection returning `Result<UsageSnapshot, UsageFailure>`. Decode only permitted fields, bound input before decoding, use actual window duration and normalize reset timestamps. Vendor wire data must not become the renderer's domain model.
4. Implement acquisition in a provider-owned native adapter. Use fixed executable arguments, one in-flight request, bounded output, a deadline and owned-process cancellation. Do not pass provider responses to logs or evidence. A subprocess is not an OS sandbox.
5. Add explicit Connect/Disconnect handling in `WidgetCenter`, with cancellation, callback invalidation, observation freshness and safe errors. Review provider-specific polling cadence. A selected layout or installed template must not implicitly connect it.
6. Add disclosure and setup instructions in the Hub. Keep credentials and sign-in in the original client. If configuration changes are necessary, preserve unrelated keys and command options, back up privately, and restore only when the configuration still belongs to Still.
7. Use `UsageCardView` for quota data. A new fact family needs its own typed contract and host renderer; do not disguise activity or approvals as quota.
8. Add tests and real local acceptance evidence before documenting support. Keep raw source data, backups, logs and screenshots out of Git.

A projection can be exercised without connecting any account:

```swift
import Foundation
import StillWidgets

let now = Date()
let source = Data("""
{"rateLimits":{"primary":{"usedPercent":25,"windowDurationMins":300}}}
""".utf8)

switch UsageProjection.codex(source, now: now) {
case .success(let snapshot):
    // Fixture-only example: pass validated values to the host renderer.
    assert(snapshot.isUsable(now: now))
    assert(snapshot.windows.first?.minutes == 300)
case .failure(let failure):
    // Render an unavailable state with a safe message, not vendor output.
    print(failure.message)
}
```

This example is fixture data for authoring. It must never become a fallback for a live card.

## Claude's local bridge

Claude Code invokes its configured status-line command with JSON on stdin. The bundled `StillClaudeBridge` executable decodes only `rate_limits.five_hour` and `rate_limits.seven_day`, projects quota and writes `~/Library/Application Support/Still/usage/claude.json` with mode 0600. Still reads that projected file. The existing user-owned status-line command receives the original input and retains its output. Still does not open the referenced transcript or credential stores.

Connect updates `~/.claude/settings.json` while preserving existing options and unrelated settings. Its private backup and restoration record live under Application Support/Still, never in the repository. Disconnect refuses to overwrite external status-line edits. Repeated unchanged metadata does not refresh the observation timestamp; missing metadata clears an earlier healthy snapshot.

This is a local native helper attached to **Claude Code's status line**, not a macOS menu-bar plugin. Claude Code supplies the account data and may itself communicate with its service; Still's Claude adapter makes no independent quota-network request. Supported account data appears during normal Claude operation. See [Claude's documented input](https://code.claude.com/docs/en/statusline#available-data), [source research](../research/claude-usage-integration-2026.md) and [ADR 0007](../adr/0007-native-account-quota-widgets.md).

## Validation

```sh
swift test --package-path packages/StillWidgets
swift test --package-path packages/SessionKit
swift build --package-path apps/macos
pnpm check
pnpm typecheck
pnpm build
```

Cover missing windows, actual durations, oversized/malformed input, non-finite/out-of-range percentages, reset expiry, future/stale observations, cancellation, reconnect and unavailable sign-in. Configuration bridges also need preserved stdout/exit behavior, unrelated settings, options, safe restore and external-edit conflicts.

Exercise real Connect/Disconnect and stale/unavailable states on the native candidate. Verify light/dark, keyboard/VoiceOver, Reduce Transparency, long labels, layout and multiple displays. Verify cover/authentication recovery separately. Unit tests and a projected fixture do not establish live provider compatibility or desktop privacy.

## Prepare a community plugin

Until the importer is implemented, prepare a proposal with a namespaced package ID, publisher/source/license, supported protocol version, declared facts, typed settings, refresh limits, template slots and explicit source capabilities. Follow the [extension proposal](../plugins-and-widgets.md). Treat that manifest as a review artifact, not a supported installation format.

The next SDK milestone must deliver a versioned schema, fixture corpus, validator, starter package, explicit local import and revocation tests. External executable support requires a separately verified isolated runner; accounts, payments and automatic updates are outside this first authoring path.
