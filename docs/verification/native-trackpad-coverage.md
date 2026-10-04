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
