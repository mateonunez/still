# Try the native Still preview

Status: local development preview. Still provides visual privacy; use the macOS security lock when you need a secure lock.

## Switch to the updated preview

1. Choose **Quit Still** in the old app's menu. Both previews share one development identity, so close the old process first.
2. From the workspace root, open the prepared candidate:

```sh
open out/Still-preview.app
```

To rebuild that candidate:

```sh
./scripts/build-macos.sh debug Still-preview
```

Normal builds can still use `./scripts/build-macos.sh` and `open out/Still.app`; quit a running preview before replacing/reopening it. Requirements: Xcode/Swift 6 and Node for token generation. The verified compilation host is Apple Silicon/macOS 26.5.2; macOS 14 is only a provisional deployment floor.

## Find Still

The first normal launch shows **Meet Still**, including the mark to look for at the top of the screen. Still has no Dock icon. Its menu-bar mark is an open ring with a point above it. Reopening the app shows the welcome window again while inactive.

Choose **Appearance → Light**, **Dark** or **System**, then **Show Still**. Appearance is saved locally. The menu offers one primary action matching the current session; it no longer shows Show and Return together. The covered state adds an inner point to the icon and updates the status text.

## Touch ID

If enrolled Touch ID is available, Still prepares Apple's inline authentication control when the curtain appears. **Rest your finger lightly on Touch ID; do not press the power button.** The intended path needs no preceding Return-button click and uses no separate app-owned biometric dialog.

The Mac controls readiness, timeout and lockout. If an attempt times out or is canceled, the curtain stays visible. Choose **Return to desktop** to prepare another attempt, or use the system-password path. Escape cancels a pending attempt without removing the curtain.

Only the active curtain display hosts the biometric control. All displays share the same session. A secondary display can request the system authentication path.

## Mac password

Choose **Use Mac password…** below the inline fingerprint control. Still invalidates the biometric attempt and opens the macOS-owned authentication dialog with a fresh context. macOS may initially offer Touch ID or Apple Watch; choose **Use Mac password** (or the OS's equivalent fallback label) there.

Enter the password only in that system dialog. Still has no password form and does not receive/store your Mac password. Canceling keeps the curtain. A successful result removes all Still panels and asks macOS to reactivate the previous application.

Without available Touch ID, **Return to desktop** opens the system path. This version has no Still PIN or custom password,.

## Recovery and current scope

Ordinary Command-Q, **Quit Still** and macOS Force Quit remain available. App termination necessarily exposes the desktop; it does not stop the other apps. The preview makes no sleep-prevention requests and has no idle timer yet. Agent activity, updates, public installation and the production Next.js site are later phases.

## Manual acceptance

Use [the interaction report](../verification/phase-01-interaction-refinement.md) for this candidate and [the broader Phase 1 matrix](../verification/phase-01-native-curtain.md) for desktop/hardware modes.

- Confirm the welcome window, mark and single useful menu action.
- Check actual Light/Dark/System rendering and readable focus rings.
- Show Still; attempt Touch ID without clicking Return first.
- Try the Mac-password path, cancellation, Escape/retry and a method switch during biometric waiting.
- Check previous-app restoration, keyboard navigation and VoiceOver.
- Repeat with a second monitor, another Space, fullscreen, Mission Control and Stage Manager. Record any uncovered desktop.
- Connect/disconnect a display while covered and during authentication.
- Test real system lock/unlock and sleep/wake without altering lock settings.
- Confirm a representative non-sensitive workload advances before/during/after coverage; the synthetic test is not enough to prove all apps.
- Confirm Quit/Force Quit recovery.

The live biometric flow, password dialog and desktop-mode coverage still need these human observations. Build success and exported native renders do not replace them.

## Latest visual fix

The current preview removes the forced initial password focus and the extra outline, while retaining native keyboard focus. The embedded fingerprint now uses regular control size and explicit hosting bounds. Quit/reopen the preview to load the new binary. Verify initial presentation and keyboard navigation; OS accessibility/keyboard settings still govern native focus behavior. [Evidence and large-screen follow-up](../verification/phase-01-visual-polish.md).

Three-finger horizontal swipes, including slow partial transitions, remain a failing visual-privacy case. See the [desktop-transition acceptance guide](desktop-coverage.md) and [current finding](../verification/native-trackpad-coverage.md). No gesture restriction is currently implemented.
