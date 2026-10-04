# Desktop-transition acceptance

Current status: Still can expose other apps during Mission Control and horizontal trackpad transitions. It is not a secure macOS lock. No automatic gesture-blocking setting is available in the app.

## Controlled trial

1. Use two neighboring Spaces with nonsensitive test windows. Note macOS version, displays and the exact Still build.
2. Activate Still and slowly swipe three fingers left. Pause halfway, then cancel back to the starting Space.
3. Repeat to the right; repeat both directions at normal speed and complete the transition.
4. Record **Fail** whenever any desktop/window content is visible, even briefly. A transition ending on Still does not undo a failure during its animation.
5. Test Mission Control, App Exposé, Show Desktop and full-screen neighbors separately. Repeat with additional displays where available.
6. Return through Touch ID or the macOS password dialog; verify normal navigation and recovery. No account password belongs in reports or recordings.

Capture only synthetic content if recording the trial. Source flags and structural receipts cannot substitute for these observations. A proposed gesture restriction must also demonstrate correct restoration and crash recovery before acceptance.

See the [finding and public API boundary](../verification/native-trackpad-coverage.md).
