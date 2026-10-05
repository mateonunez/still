# Desktop transition boundary — public macOS APIs

2026-10-05. Scope: public AppKit/CoreGraphics APIs for the macOS 26 curtain. **Research only; no live gesture fix or new native behavior is proven by this document.**

## Recommendation

Keep the current opaque per-display panels and their overlay collection behaviors. A supported, reversible presentation policy can reduce Dock and Command-Tab exposure while Still is active. It must not be described as blocking Spaces swipes, Mission Control, App Exposé or Show Desktop. The reported slow/fast three-finger swipe failure remains open until a candidate passes the physical-trackpad matrix.

No documented public API reviewed here provides a general veto of macOS desktop-management gestures or a guarantee that an ordinary application window covers every compositor transition frame. This is a conclusion about the reviewed contracts, not proof that every conceivable public implementation is impossible.

## Current implementation and evidence

`CurtainCoordinator.rebuildPanels()` creates one opaque borderless `NSPanel` per `NSScreen`, at `.screenSaver`, with `.stationary`, `.canJoinAllSpaces`, `.fullScreenAuxiliary`, `.ignoresCycle` and `.canJoinAllApplications`. The owner nevertheless observed desktop/application previews during three-finger horizontal swipes, including partial slow transitions. [Existing reproduction](../verification/native-trackpad-coverage.md).

The collection is compatible with the installed public SDK declarations. In particular, `.stationary` must not be combined with `.managed` or `.transient`; `.canJoinAllApplications` must not be combined with `.primary` or `.auxiliary`. `.fullScreenAuxiliary` belongs to a separate mutually exclusive full-screen group. Replacing stationary with transient is unlikely to help: the SDK describes transient windows as hidden during Exposé, while stationary windows remain visible without moving. [Apple stationary contract](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/stationary), [Apple collection behaviors](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct).

`.canJoinAllSpaces` permits presentation on multiple Spaces; it does not promise a gesture veto or animation-frame continuity. `.canJoinAllApplications` is designed for floating windows/system overlays and permits eligible full-screen participation, while excluding the window from Stage Manager layout. Neither is a compositor security boundary. [All Spaces](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallspaces), [all applications](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallapplications).

## Narrow supported hardening

A candidate can set `NSApp.presentationOptions` to the following while the curtain owns presentation:

```swift
[.hideDock, .autoHideMenuBar, .disableProcessSwitching]
```

This disables Dock access and the Command-Tab interface, while retaining a discoverable menu bar. The options affect the system when the application is active. Dependencies matter: disabling process switching requires a Dock hiding option, and menu-bar auto-hide also requires Dock hiding. Opposing auto-hide/hide options cannot be combined; invalid combinations raise an Objective-C exception. Snapshot existing options and compose a valid policy rather than blindly adding flags. [Presentation options](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct), [active-app scope](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.property), [Command-Tab scope](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disableprocessswitching).

Restore the original options on authenticated return, suspension, teardown and any failed cover setup. Release or appropriately reconcile the policy while handing off to the system-owned authentication dialog; restore only if coverage remains requested. Check recovery and activation after cancellation, sleep/wake and application termination. Keep Force Quit, session termination and system lock available. Do not add a focus-stealing activation loop that fights system dialogs.

The currently published `disableScreenCornerInteractions` symbol is marked macOS 27.0+ and is absent from the installed macOS 26 SDK. It cannot be used as a macOS 26 solution, and its contract concerns screen corners rather than all gestures. [Apple availability and scope](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disablescreencornerinteractions).

## Approaches that do not establish coverage

| Approach | Verified contract and limitation |
| --- | --- |
| `NSWorkspace.activeSpaceDidChangeNotification` | Reports a Space change. It offers no cancellation API or documented before-transition frame barrier. Reasserting window order afterward cannot prove that earlier frames stayed private. [Apple notification](https://developer.apple.com/documentation/appkit/nsworkspace/activespacedidchangenotification) |
| Local/global `NSEvent` monitors | A local monitor can cancel only dispatch within its application; global monitors cannot change or suppress other delivery. Receiving an application swipe does not establish interception of a system-owned Spaces gesture. [Apple event monitoring](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/MonitoringEvents/MonitoringEvents.html) |
| CoreGraphics event tap | The installed `CGEventTypes.h` enumerates mouse, keyboard, scrolling and tablet events, with no documented three-finger Spaces-gesture event. Suppressing scrolling is not a demonstrated system-gesture veto. No input hook was installed. |
| `sharingType = .none` | Concerns access to the app's window content, not hiding the other apps in Spaces previews. Current Apple docs label `none` a legacy constant no longer used. Older SDK prose is less current and should not override that contract. [Apple sharing type](https://developer.apple.com/documentation/appkit/nswindow/sharingtype-swift.enum) |
| Level above `CGShieldingWindowLevel()` | The function describes a captured-display shield. Apple warns that placing a window above such a shield can produce unusable output and discourages that technique. It does not promise Mission Control coverage or compatibility with authentication UI. [Apple shielding function](https://developer.apple.com/documentation/coregraphics/cgshieldingwindowlevel()) |
| `CGDisplayCapture` | Public exclusive-display capture is a different graphics ownership model. Its SDK availability does not prove a safe AppKit curtain with system authentication, recovery and modern compositor behavior. It was not invoked or selected. |
| Native fullscreen window | Creates a fullscreen presentation/Space, rather than a documented systemwide transition barrier. It still needs the same adjacent-Space and recovery trials. |

Persistent Dock/Trackpad preference edits, Dock restarts and private WindowServer/MultiTouch APIs are outside this implementation. Changing those settings would also create restoration failure modes and would not establish a supported runtime contract.

## Manual acceptance still required

Use only synthetic nonsensitive windows. Record the exact executable SHA-256, OS build, display topology, Stage Manager setting, separate-Spaces setting and gesture configuration. Compare baseline and candidate using the same setup.

1. Swipe left/right quickly, then slowly; pause midway and cancel the gesture in both directions. Fail if any underlying desktop or app content appears at any intermediate point.
2. Repeat with an ordinary neighboring Space and a neighboring fullscreen app, on each display.
3. Test Mission Control, App Exposé, Show Desktop, hot corners and keyboard desktop shortcuts independently. A passing Command-Tab restriction does not substitute for these cases.
4. Verify Touch ID, system-password dialog, cancellation/retry and Force Quit/system lock access; test return to the original application without stuck presentation policy.
5. Repeat after sleep/wake, fast-user switching and display disconnect/reconnect. Inspect termination/crash recovery separately from graceful teardown.

Automation of window flags, levels, frames and option restoration is useful structural evidence. It cannot generate a faithful physical three-finger transition or establish that every intermediate compositor frame was private. Keep the open acceptance finding explicit in product claims and release planning.

## Source provenance

Apple documentation was checked on 2026-10-05; when web extraction rejected Apple's Markdown content type, the same official `.md` endpoint was retrieved directly. Public installed headers were inspected read-only under the `xcrun --show-sdk-path` result: `AppKit.framework/Headers/NSApplication.h` (presentation flags), `NSWindow.h` (collection exclusivity and sharing), and `CoreGraphics.framework/Headers/CGDirectDisplay.h` / `CGEventTypes.h`. No preferences, gestures, display capture or running applications were changed during this research.
