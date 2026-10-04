# Still roadmap

Updated 2026-10-04. The website is live; the native app remains a development preview. Search Console setup has been reported complete. Search indexing and rankings are not yet verified.

## Next milestones

| Priority | Milestone | Evidence required |
| --- | --- | --- |
| 1 | Desktop coverage and transitions | Reproduce Mission Control and horizontal Space gestures on the exact candidate; evaluate supported AppKit behavior; verify multiple displays and document remaining exposure |
| 2 | Native interaction polish | Live Touch ID and Mac-password success/cancel/retry; smooth cover/return; menu discovery; keyboard, VoiceOver, light/dark and accessibility materials |
| 3 | Unified inactivity and energy concept | Agree on the interaction model and defaults before implementation; keep existing awake controls hidden and their implementation retained |
| 4 | Beta readiness | Choose the support matrix, complete onboarding/preferences, test fresh installation, sleep/wake, display changes and recovery; verify retained power behavior if reintroduced |
| 5 | Direct distribution | Confirm release identity and license; Developer ID signing, hardened runtime, notarization, clean-Mac installation and update policy; publish a verified download before advertising install commands |
| 6 | Release website | Replace illustrative previews with verified native visuals, publish real compatibility/version/download details and release notes, then observe search coverage and production performance |

Homebrew is a follow-up distribution option once the signed artifact is available. No App Store release is planned.

## Later

Agent awareness can add provider-validated status, approval attention and usage metadata after v1, without conversation content. Additional themes can begin as local collections; a marketplace requires a separate scope and licensing decision.

## Current constraints

Mission Control and trackpad desktop transitions can expose the desktop. Still is a visual privacy curtain, not the macOS security lock. Build success, structural tests and website delivery do not establish native hardware acceptance or release readiness.

See [development status](development/README.md), [desktop findings](verification/phase-02-deferred-awake-and-spaces.md), [native guide](guides/native-preview.md) and [distribution plan](distribution.md).
