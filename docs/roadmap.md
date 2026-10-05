# Still roadmap

Updated 2026-10-05. Native development preview; no signed/notarized beta or public download. The Next.js site is live. Search Console setup was reported complete; indexing/rankings are not established.

| Priority | Next milestone | Acceptance |
| --- | --- | --- |
| 1 | Physical desktop privacy | Exact-candidate slow/fast/partial three-finger swipes, Mission Control, multiple displays and recovery; document any exposed frame. Public API restrictions do not prove gesture coverage. |
| 2 | Native interaction/accessibility | Touch ID + system password cancel/retry, glass active/inactive, keyboard/VoiceOver, reduced materials, resize/display changes, sleep/wake and awake lifecycle |
| 3 | Live advisory agent activity | Client opt-in/trust/reload, parallel sessions, attention→progress, failure/interrupt/end/expiry and disconnect for Codex/Claude |
| 4 | Native collection acceptance | Ten configurable modules implemented; complete Calendar consent and fresh-install Spotify revocation, plugin configuration/expiry/disable trials, template ordering and resource acceptance |
| 5 | Beta readiness | Choose verified OS/hardware matrix; fresh installation/recovery/failure checks and native visuals |
| 6 | Direct distribution, final gate | Release identity/license, Developer ID/hardened runtime/notarization, clean-Mac install, updates and verified download. Deferred until product acceptance. |
| 7 | Release website | Verified native visuals/version/compatibility/download, release notes, search coverage and performance |

See [native collection evidence](verification/native-plugin-collection.md) for the ten-plugin implementation and current source states. Claude preserves bounded historical quota as Last reported without changing its observation time.

## Completed local foundations

Porcelain light/dark/system, native glass service controls, system authentication, inactivity, automatic display/system-awake ownership while covered, real opt-in Codex/Claude quota, local declarative plugin importer/validator/starters, explicit enable/revoke, and native advisory hook bridge. [Current evidence](verification/phase-05-plugin-sdk-and-agent-signals.md) qualifies which portions were observed vs synthetic.

Independent timed awake/display controls remain hidden pending a unified product concept. Homebrew follows a signed artifact; no usable public install command is advertised. No App Store release is planned. Additional theme assets, automatic plugin updates, payments, isolated runners and in-app approvals remain separate future contracts.

Still is visual privacy, not the macOS security lock. Trackpad/desktop transitions remain a known limitation; green builds do not establish native hardware acceptance.

Native module arrangement now supports persistent order, drag handles/keyboard alternatives and left/right composition. [Arrangement and Spotify evidence](verification/module-arrangement-and-spotify.md) records inspected native-view exports and the remaining playback consent check.

A [full-screen native canvas editor](verification/full-screen-canvas-and-spotify-authorization.md) now supports clock/module positioning, size choices and saved compositions. Pointer/keyboard/accessibility and Spotify real-consent acceptance remain open; measured collision resolution and responsive presets are implemented; separate per-display scenes remain deferred.

Customize and Preferences are consolidated into one Settings window. Measured canvas geometry, collision fallback and responsive presets are implemented. Native pointer/keyboard/VoiceOver and physical main-display acceptance remain open.

Settings sidebar/header and Spotify process-target correction are built; [transport evidence and remaining native acceptance](verification/spotify-process-target-and-settings.md).

## Pre-beta catalog and SDK

The ten-plugin public catalog, detail pages, canonical schema downloads, starters, JSON catalog and human/agent developer guides are implemented and locally verified. Community publishing, accounts and payments follow beta. See the [current audit](verification/pre-beta-product-audit.md) and [acceptance guide](guides/beta-readiness.md). Spotify connection was reported working interactively; Calendar remains pending. Main scene duplication is corrected in source and awaits physical multi-monitor acceptance. Manual update policy is documented; no automatic update engine is implemented.

## Responsive canvas and native hardening

Balanced, Focus and Dashboard presets use measured module sizes in a viewport owned by each panel. The editor follows the same macOS main display as the curtain. The current candidate removes the initial four-card visibility cap; presets include all selected native modules and actual geometric crowding is reported. Disabled native sources stay hidden. Password cancel/retry returns to the main display; presentation requests remain owned through the system dialog. An owned fifteen-second local activity renewal candidate complements display-awake assertions. Activation/password gesture exposure and one-hour screensaver prevention are not yet physically verified. See [phase evidence](verification/main-display-canvas-and-native-hardening.md).
