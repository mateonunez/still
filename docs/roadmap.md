# Still roadmap

Updated 2026-10-05. The website is live; the native app remains a development preview. Search Console setup has been reported complete. Search indexing and rankings are not yet verified.

## Next milestones

| Priority | Milestone | Evidence required |
| --- | --- | --- |
| 1 | Desktop coverage and transitions | Reproduce Mission Control and fast/slow three-finger horizontal swipes left/right, including partial transitions, on the exact candidate; evaluate supported AppKit behavior; verify multiple displays and document remaining exposure |
| 2 | Native interaction polish | Live Touch ID and Mac-password success/cancel/retry; smooth cover/return; menu discovery; keyboard, VoiceOver, light/dark and accessibility materials |
| 3 | Unified inactivity and energy concept | Automatic system-awake default implemented while covered; complete real sleep/wake and authentication acceptance; retain hidden independent timed/display controls |
| 4 | Widget and plugin foundation | Review the interactive Porcelain Hub/card prototype; define and version the manifest, metadata protocol and host-rendered templates; validate a locally imported example plugin without granting implicit permissions |
| 5 | Codex and Claude adapters | Real opt-in quota/reset reporting implemented locally; complete compatibility and failure acceptance; distinguish account quotas from session state; add lifecycle/attention only where supported sources are verified; handle stale, missing and disconnected data |
| 6 | Beta readiness | Choose the support matrix, complete onboarding/preferences, test fresh installation, sleep/wake, display changes and recovery; verify retained power behavior if reintroduced |
| 7 | Direct distribution | Confirm release identity and license; Developer ID signing, hardened runtime, notarization, clean-Mac installation and update policy; publish a verified download before advertising install commands |
| 8 | Release website | Replace illustrative previews with verified native visuals, publish real compatibility/version/download details and release notes, then observe search coverage and production performance |

Homebrew is a follow-up distribution option once the signed artifact is available. No App Store release is planned.

## Later

The plugin protocol and first Codex adapter are planned before beta and distribution. Community authoring starts with documentation, fixtures, validation and local import. A curated catalog, automatic plugin updates, payments and a hosted marketplace are later scope; the extensibility contract must accommodate them without requiring them for the first plugin.

Claude quota is now part of the local native slice. Further provider capabilities and theme collections follow validated source contracts. Plugins never receive conversation content by default.

## Current constraints

Mission Control and trackpad desktop transitions can expose the desktop. Still is a visual privacy curtain, not the macOS security lock. Build success, structural tests and website delivery do not establish native hardware acceptance or release readiness.

See [widget/plugin proposal](plugins-and-widgets.md), [Codex integration research](research/codex-plugin-2026.md), [development status](development/README.md), [trackpad finding](verification/native-trackpad-coverage.md), [desktop findings](verification/phase-02-deferred-awake-and-spaces.md), [native guide](guides/native-preview.md) and [distribution plan](distribution.md).
