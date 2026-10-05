# Module arrangement and bounded Spotify reads

2026-10-05 · Native development candidate, not a release.

## Changes

World Clock rows now have an explicit vertical container inside TimelineView. Side rail uses its intrinsic height when possible, stays centered between header/footer, and reserves horizontal clock space. Quiet corner becomes an inline horizontal module group above return controls, so layout accounts for its height. A horizontal/vertical scroll fallback handles constrained space. Native cards retain their intrinsic height instead of compressing their contents.

Appearance selects left/right position. Plugins offers an ordered visible-module list, native drag handles and named up/down buttons. Order persists between restarts; invalid saved IDs and duplicates are discarded. Arrangement controls exist in the desktop Hub, not the authenticated curtain. Reordering does not change source consent. Declarative templates still own their selected composition; native module order and side remain host preferences.

Spotify's background helper previously stalled during its permission preflight. A five-second standalone probe produced no response and had to kill only its owned helper. The revised helper sends fixed property-get Apple Events with never-interact and a two-second reply timeout. It does not execute scripts or request background permission. The same probe returned an explicit unavailable/error -1712 result in approximately 2.3 seconds. Parent lifetime is additionally bounded to seven seconds. Automatic retries preserve an existing error rather than repeatedly replacing it with Connecting.

This proves the stalled read becomes a bounded error, not successful playback. The current local Spotify configuration has spotifyAuthorized=false; consent/playback must still be verified through the Hub. A standalone terminal process also has different TCC responsibility from the native app. No consent grant or playback success is inferred from these probes.

## Evidence

- Native host: six tests pass, including order uniqueness/no-op behavior and a stalled-source timeout regression.
- `pnpm check`, `pnpm typecheck`, native build/ad-hoc signing and `git diff --check` pass.
- `node scripts/verify-native-plugins.mjs --app Still`: 17/17 checks pass. Receipt: ignored `out/verification/native-collection/2026-10-05T14-18-29.432Z/native-plugins.json`.
- Candidate: `out/Still.app`; SHA-256 `ee2df77754cec83cac20d6117f3a8080d1a8f02b5230169afa3d4bec02f93d32`. Existing owner-running Still-preview was preserved.
- Full 1920×1080 native-view exports for Side rail and Quiet corner were inspected: three distinct World Clock rows and separated header/clock/module/return regions. SwiftUI rendering is not physical desktop or authentication evidence.

Open acceptance: live dragging and keyboard ordering, persistence after restart, both sides/compositions on smaller/large/multiple displays, VoiceOver/native focus, Spotify consent/denial/revocation and real playback. Existing trackpad/password and prolonged screen-saver checks remain open. Signed/notarized beta remains deferred.
