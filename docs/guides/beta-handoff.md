# From development candidate to end-user beta

The current candidate is `out/Still-polish.app`. It is an ad-hoc development build, not a distributable beta. Quit any other Still instance before opening it:

```sh
open "$(node scripts/native-candidate.mjs --path)" --args --editor
```

`node scripts/native-candidate.mjs` prints the exact candidate and executable SHA-256. About Still also shows the candidate name. The manifest identifies the latest successful local build, not the newest modification to the source tree.

## 1. Accept the exact candidate

An acceptance template is prepared at `out/beta-acceptance-polish.json`. Regenerate it for a new build only when starting a new trial; this replaces the template:

```sh
node scripts/beta-preflight.mjs --template > out/beta-acceptance-polish.json
```

Fill in macOS and hardware. Keep untested checks `null`; set only directly observed results to `true` or `false`. Do not paste credentials, conversations, calendar titles or private screenshots into reports.

| Check | Required observation |
| --- | --- |
| appearanceAndEditor | Switch both themes/appearances; restart; move, resize, reorder and cancel; inspect small/large main displays. No clipped controls or unintended layout jumps. |
| agentSignals | Both clients: fresh event reaches the combined widget; attention/progress/end/expiry; parallel sessions; disconnect. A quota alone does not pass activity. |
| pluginsAndRevocation | All ten enabled/configured individually; real source status, unavailable/error, refresh, hide/disable and reconnect. Calendar and Spotify consent must be observed separately. |
| displayTopology | One main scene; opaque secondary displays; main-display changes, scaling and unplug/replug. |
| touchID | First and repeated activation, return and recovery. |
| passwordRecovery | macOS-owned dialog, cancel/retry, correct return, gesture behavior during and after the handoff. |
| trackpadPrivacy | Slow/fast/partial swipes during activation and settled coverage; Mission Control, Show Desktop and configured window-management gestures. Any exposed frame fails. |
| accessibility | Keyboard, visible focus, VoiceOver, Reduce Motion, Reduce Transparency and increased contrast in both themes. |
| awakeAC | At least one hour beyond the configured screen-saver interval on AC: no idle screen saver/sleep; return releases owned requests. |
| awakeBattery | Repeat the endurance/recovery trial on battery. Explicit system sleep remains available. |

```sh
node scripts/verify-native-interaction.mjs --app Still-polish
node scripts/verify-native-password-boundary.mjs --app Still-polish
node scripts/verify-native-plugins.mjs --app Still-polish
node scripts/beta-preflight.mjs --acceptance out/beta-acceptance-polish.json
```

The plugin probe uses owned scratch configuration and does not ask for OS permission. A probe without a receipt is unverified. The preflight rejects missing/failed checks, non-boolean passes and reports for another executable; it never establishes distributed-beta readiness.

## 2. Confirm distribution inputs

The prepared inputs and their confirmation status are in the [end-user beta plan](../development/private-beta-preparation.md). Follow the [Developer ID setup guide](developer-id-setup.md) to prepare a personal signing identity and local notarization profile without signing or uploading the app.

Before signing, choose the verified macOS/hardware matrix and version/build number. The beta audience is opt-in end users, without a fixed small-cohort limit. Evaluate macOS 14+ and both architectures; publish tested combinations separately from intended/experimental ones. `co.mateonunez.still` is still the proposed release bundle ID. Confirm it before creating the release artifact. Keep the development identity separate.

Use a personally owned Apple Developer membership and Developer ID Application identity. The owner configures notarization credentials in the local Keychain; never send passwords, private keys, certificates or API-key contents through chat or commit them. A certificate name/team identifier and an existing Keychain profile name are enough to configure the workflow.

Weather currently uses a non-commercial evaluation endpoint. Confirm that its license covers the planned beta, or keep Weather disabled in the release configuration until a suitable provider is selected. There is no automatic updater; use the [manual update policy](manual-updates.md).

## 3. Sign and notarize a separate release artifact

This phase prepares instructions only. Signing, upload to Apple and publication have not been executed.

Build a fresh release-mode app in a separate staging directory. Set the confirmed release ID/version before signing. Sign every nested helper, then the outer bundle, using the selected personal Developer ID, a secure timestamp and hardened runtime. Do not use `codesign --deep` as the signing strategy. Verify the actual helper entitlements, including Spotify Apple Events automation where required; entitlements do not grant user consent. Do not add JIT, disabled library validation or debugging exceptions without a concrete requirement.

Pin the exact certificate SHA-1 fingerprint and personal Team ID in project-local configuration. Never select the first available identity or inherit a global/default team. Before upload, compare `TeamIdentifier` for the app and every executable helper with the expected team, verify Developer ID Application signatures, and reject any mismatch. Use a dedicated notarization profile created with that same explicit Team ID; a successful history request alone does not prove the profile belongs to the intended team.

Create a notarization ZIP using `ditto --keepParent`. Submit that archive using the existing Keychain profile:

```sh
xcrun notarytool submit <staged-archive.zip> --keychain-profile <personal-profile> --wait
```

Read the notarization result/log. After acceptance, staple and validate the app ticket, create the final download archive from the stapled app, compute its SHA-256 and verify codesigning and Gatekeeper:

```sh
xcrun stapler staple <staged-Still.app>
xcrun stapler validate <staged-Still.app>
codesign --verify --deep --strict --verbose=2 <staged-Still.app>
spctl --assess --type execute --verbose=4 <staged-Still.app>
```

These are placeholder instructions, not currently usable release commands. Apple documents [Developer ID distribution](https://developer.apple.com/developer-id/), [notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) and [custom workflows](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).

## 4. Test the signed download before inviting testers

Download through the intended private HTTPS path on a clean supported Mac, preserving quarantine. Verify install/open, permissions, all helpers, agent connection, recovery, settings persistence, upgrade and uninstall. Do not erase the privacy database or remove quarantine to manufacture a pass. Development-bundle consent does not establish consent for the release identity.

Only then publish the immutable beta artifact and its version, compatibility, checksum, limitations, release notes and feedback instructions through the approved download flow. A private source repository does not make a download URL private. End-user beta availability, Homebrew and stable release remain separate delivery gates.
