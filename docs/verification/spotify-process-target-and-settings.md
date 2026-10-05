# Spotify process targeting and unified Settings refinement

Date: 2026-10-05. Status: transport correction verified; interactive Still consent and Settings appearance acceptance pending.

## Reproduction and diagnosis

The connection failed and Still was absent from the owner's Automation list. A direct `StillSpotifyBridge --hide-titles` read reproduced `unavailable`, error `-1712` (timeout). This was not an observed `-1743` permission denial.

Ranked hypotheses were bundle-ID event routing, helper identity/consent attribution and Spotify responsiveness. A differential test compiled the same helper, changing only the target descriptor from bundle ID to the PID of the already-running Spotify instance. Bundle targeting timed out; PID targeting returned `ready` and playback state. This identifies a transport failure on this machine. It does not establish that helper permission identity can never cause another failure.

Regression loop:

- `node scripts/verify-spotify-transport.mjs --app Still` failed: `ready:false`, `errorCode:-1712`. Receipt: ignored `out/verification/spotify-transport/2026-10-05T15-09-23.283Z/receipt.json`.
- `node scripts/verify-spotify-transport.mjs --app Still-preview` passed: `ready:true`. Latest receipt: ignored `out/verification/spotify-transport/2026-10-05T15-10-21.650Z/receipt.json`.

The correction uses [Apple's process-identifier application descriptor](https://developer.apple.com/documentation/foundation/nsappleeventdescriptor/init(processidentifier:)) and keeps the existing owned-process timeout/cancellation. The helper resolves only a currently running Spotify instance; it does not launch or control playback. Permission-denied, transport-timeout and unavailable results now have distinct user messages. The parent app retains its [Apple Events usage description](https://developer.apple.com/documentation/bundleresources/information-property-list/nsappleeventsusagedescription). No credentials, track titles, raw privacy logs or screenshots are tracked.

## Settings refinement

The single Settings window now has a persistent native sidebar for General, Appearance, Agents and Plugins, a fixed section heading and Edit screen action, and independently scrolling content. Appearance was removed from the menu-bar menu. The window has more horizontal room; theme/composition controls have distinct groups. Custom canvas hides the irrelevant left/right position control. General shows the automatic awake behavior without revealing the retained hidden timed-awake controls. Native List/Picker/Button semantics and system focus remain intact; no animation or forced focus was added.

Build/ad-hoc signature verification, six native host tests, check/typecheck and whitespace checks pass. Candidate: `out/Still-preview.app`; host SHA-256 `f5d0e88687eb680bf9c6ddf8d4c6cbe7aa04cf4f80dbb37eb2e3b3761adf6506`. The running `out/Still.app` remained unchanged.

## Acceptance still required

The helper verifier runs under its invoking process and does not prove Still-owned Automation consent. From the new app, test Allow, accept/deny, cancel/retry and real playback updates. Do not treat the standalone transport read as permission evidence. Live Settings light/dark/material appearance, keyboard/VoiceOver navigation, scrolling and full-screen-editor return need native acceptance. Signed/notarized distribution remains deferred.
