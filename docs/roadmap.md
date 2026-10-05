# Still roadmap

Updated 2026-10-05. Native development preview; no signed/notarized beta or public download. The Next.js site is live. Search Console setup was reported complete; indexing/rankings are not established.

| Priority | Next milestone | Acceptance |
| --- | --- | --- |
| 1 | Physical desktop privacy | Exact-candidate slow/fast/partial three-finger swipes, Mission Control, multiple displays and recovery; document any exposed frame. Public API restrictions do not prove gesture coverage. |
| 2 | Native interaction/accessibility | Touch ID + system password cancel/retry, glass active/inactive, keyboard/VoiceOver, reduced materials, resize/display changes, sleep/wake and awake lifecycle |
| 3 | Live advisory agent activity | Client opt-in/trust/reload, parallel sessions, attention→progress, failure/interrupt/end/expiry and disconnect for Codex/Claude |
| 4 | More useful local packages | Implement small real sources on validated v1, review privacy/freshness/resource behavior, refine templates and source ordering |
| 5 | Beta readiness | Choose verified OS/hardware matrix; fresh installation/recovery/failure checks and native visuals |
| 6 | Direct distribution, final gate | Release identity/license, Developer ID/hardened runtime/notarization, clean-Mac install, updates and verified download. Deferred until product acceptance. |
| 7 | Release website | Verified native visuals/version/compatibility/download, release notes, search coverage and performance |

## Completed local foundations

Porcelain light/dark/system, native glass service controls, system authentication, inactivity, automatic display/system-awake ownership while covered, real opt-in Codex/Claude quota, local declarative plugin importer/validator/starters, explicit enable/revoke, and native advisory hook bridge. [Current evidence](verification/phase-05-plugin-sdk-and-agent-signals.md) qualifies which portions were observed vs synthetic.

Independent timed awake/display controls remain hidden pending a unified product concept. Homebrew follows a signed artifact; no usable public install command is advertised. No App Store release is planned. Additional theme assets, catalog, automatic plugin updates, payments, isolated runners and in-app approvals remain separate future contracts.

Still is visual privacy, not the macOS security lock. Trackpad/desktop transitions remain a known limitation; green builds do not establish native hardware acceptance.
