# Native Codex and Claude quota widgets — local evidence

Historical checkpoint. For the current local SDK and advisory-hook scope, see [Phase 05](phase-05-plugin-sdk-and-agent-signals.md).

Date: 2026-10-05. Candidate executable SHA-256: `48dd4e4e1f82800383ed001ff4ecae16dba4e1f25d79800edef6b1b10da44268`.

## Delivered

The local Next.js design preview now supports independent Codex and Claude demonstration cards. The installed native app at `~/Applications/Still.app` instead uses real sources, with opt-in connection, disconnect, window labels, reset times, freshness, missing/stale states, and Quiet corner/Side rail composition. No native fixture fallback exists. The app remains an ad-hoc signed development build, not a notarized release.

Native UI interaction connected Codex and showed 40% weekly account quota with its reset. Connecting Claude installed the native status-line bridge; a subsequent client update showed 20% five-hour quota and 44% weekly quota. These are observations at this checkpoint, not permanently current values. Conversation content, credentials and account labels are absent from retained quota evidence.

## Passing checks

- Nine StillWidgets domain tests: projections, actual time windows, invalid/oversized data, freshness, safe settings patching and conflict-aware restoration.
- All 34 SessionKit tests pass. Eleven native structural/awake lifecycle checks passed on the pre-polish widget candidate; they do not establish visual or authentication acceptance of this final candidate.
- Six scratch helper checks cover forwarding existing stdout, exit status, normalized windows, private-field exclusion, unchanged-data freshness and removal of obsolete healthy data. They do not use real user settings.
- Actual Claude connection verification confirms unrelated settings and status-line options are unchanged, the original status line is retained, and the projected quota file is mode 0600. The initial verifier used JSON string order and was corrected to structural equality; the five resulting checks pass.
- Final candidate Codex native probe succeeds; its result retains only usage windows and reset times. Installed and generated app executables match the candidate hash.
- Biome, TypeScript and the Next.js production build pass. Browser interaction confirms two cards and independent provider state: setting Claude stale leaves Codex current. Both cards render in the dark curtain prototype. This browser content remains clearly labelled demonstration data.

## Native window defect and correction

A direct executable launch produced the reported interaction problem. After restarting the owned installed instance through `open -n ~/Applications/Still.app --args --widgets`, the composition picker accepted a selection and both Connect buttons completed. The older user preview was not terminated.

The title-bar gap used transparency without full-size content. Full-size content and a background extending under the chrome remove the gap. A scroll check then exposed content under the title; reserving the measured AppKit title-bar height prevents that overlap. Final screenshot verifies clean rounded top corners, unified material and readable title while scrolled. Minimize, resize and zoom are enabled. Live picker, Connect and scrolling were exercised; drag resizing, keyboard-only, VoiceOver and all accessibility settings remain unverified.

Ignored evidence is under `out/verification/live-widgets`: `native-final/live-usage.json`, `claude-live.json`, `bridge-safety.json`, `native-hub-connected.png`, and `web-claude-codex-dark.png`. Backups and source metadata stay outside Git. No remote deployment was performed.

Agent activity and approvals, community packages/import and marketplace are not implemented. Multi-display visual placement, real cover/return authentication and the known Mission Control/trackpad exposure still require acceptance. See [guide](../guides/widgets-and-plugins.md) and [decision](../adr/0007-native-account-quota-widgets.md).
