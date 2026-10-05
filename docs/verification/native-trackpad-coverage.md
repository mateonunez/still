# Native trackpad coverage finding

2026-10-04. Status: **open — visual privacy failure, required before beta.** No gesture-blocking fix is implemented or verified.

## Exact symptom

While Still covers the screen, a three-finger horizontal trackpad swipe in either direction reveals other open applications. Moving slowly also exposes intermediate previews during the desktop transition. Mission Control exposure was previously documented separately.

The horizontal swipe is a reported live reproduction. Current automation cannot generate a faithful three-finger trackpad gesture or observe every intermediate compositor frame. A structural panel probe passing does not establish a gesture fix.

## Current evidence

The current candidate remains `out/Still-preview.app`, executable SHA-256 `a3de2013513d26b30982696325e012627f069221ee3b749f70395b7b9ff8dddd`. Existing live structural receipts report `.stationary`, `.canJoinAllSpaces`, `.canJoinAllApplications` and screen-matching frames at curtain level. No native presentation change was made in the template/tooling migration.

Apple documents `.stationary` as keeping the window visible/stationary in Mission Control and `.canJoinAllSpaces` as allowing it to appear in all Spaces. These describe window behavior; the observed transition exposure remains a failing acceptance case despite those flags. [Stationary](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/stationary), [all Spaces](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallspaces).

Apple documents `NSApplication.PresentationOptions.disableProcessSwitching` specifically for the Command-Tab switching interface. The installed AppKit SDK header says “Cmd+Tab UI is disabled.” Neither observation proves that this flag blocks horizontal trackpad transitions. [Process switching](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disableprocessswitching).

## Required native experiment

Use synthetic, nonsensitive windows on neighboring Spaces. Pin the app hash, macOS version, monitor arrangement and trackpad gesture configuration. Test fast and slow swipes left/right, including canceling halfway. Record whether any desktop/window content becomes visible, not only which app is frontmost after completion.

A trial fails if another app or desktop appears at any intermediate frame. Test Mission Control, App Exposé, Show Desktop, full-screen neighbors and additional displays independently. Ordinary system lock and recovery remain available. Any candidate presentation change needs the same before/after gesture trials and authentication/recovery checks.

Temporarily blocking transitions while covered is a desired behavior, not a proven public-API capability. Do not silently change persistent Trackpad/Dock preferences, use private APIs or disable recovery as a substitute for passing coverage. A session-scoped supported restriction must demonstrate restoration on return, cancellation, sleep/wake and process failure.

See [manual guide](../guides/desktop-coverage.md), [prior compositor evidence](phase-02-deferred-awake-and-spaces.md) and [roadmap](../roadmap.md).

## 2026-10-05 public-API hardening

The next candidate adds scoped hideDock/autoHideMenuBar/disableProcessSwitching and exact restoration. Runtime getters/idempotence/restoration are verified, but they are not trackpad or compositor coverage. Public contracts reviewed do not provide a blanket desktop-gesture veto. Three-finger exposure remains open pending physical trials. See [research](../research/desktop-transition-boundary-2026.md), [phase evidence](phase-05-plugin-sdk-and-agent-signals.md) and [acceptance guide](../guides/pre-release-native-checks.md).

## Owner trial — first/repeated activation regression

The owner reports that the first activation suppresses trackpad gestures but has no visible/usable embedded Touch ID, requiring the Mac-password action. Later activations show Touch ID. A desktop swipe during activation reintroduces underlying-window previews and gesture exposure. The loaded executable hash and repeat-without-swipe coverage were not established from the report. This is a failed native acceptance case, not a gesture fix.

Replay of the owner report with `node scripts/verify-native-interaction.mjs --report out/verification/interaction-trial/owner-baseline.json` exits 1: firstTouchIDVisible=false, noExposureDuringActivation=false. Untested fields remain null. This is a human-observation replay, not automated physical gesture synthesis.

A separate diagnostic candidate `out/Still.app` (SHA-256 `622c4433dad26cf93e3d9a9ca70c7772d1e2d18156422eac1744c0a232bd870f`) builds/signature-verifies and adds opt-in `--interaction-trace`. It does not claim to fix the regression. The bounded local trace records application activation, key-panel status, Touch ID preparation/attachment, normalized preparation error code and presentation flags; no input, content, window titles or client data. Normal launches write no trace.

`node scripts/verify-native-interaction.mjs` guides three physical trials and writes private receipts under `out/verification/interaction-trial`. It never terminates an existing user app. Root cause and an original-reproduction pass remain pending this trace.
