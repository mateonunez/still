# Native candidate acceptance

Use the exact rebuilt `out/Still-preview.app`. Quit the older app yourself first; do not run two curtains. Record the executable SHA-256, macOS version and connected displays. This development candidate is ad-hoc only, not a signed/notarized beta.

## Desktop privacy and return

1. Leave an ordinary window visible behind Still; activate the curtain from the menu.
2. Three-finger swipe slowly right and left, stop midway, reverse direction; repeat fast in both directions. Test every display and full-screen Space.
3. Open Mission Control, App Exposé, Show Desktop and Stage Manager if configured. Check Cmd-Tab and Dock access. Do not change persistent Trackpad preferences to manufacture a pass.
4. Report any exposed underlying window, including partial previews, with gesture/direction/speed/display. A single leaked frame fails privacy coverage for that case.
5. Return with Touch ID. Test the system-owned Mac-password fallback, cancel and retry. No password goes into Still.
6. Check ordinary Quit/Force Quit and system lock/recovery. Sleep/wake and display unplug/replug must not leave stranded panels or restart an ended session.

Public presentation restrictions are not a documented Spaces/trackpad block. Mission Control/desktop exposure remains a known open limitation until observed otherwise on the exact candidate.

## Hub and sources

- Appearance Light/Dark/System, active/inactive service window, resize/scroll and keyboard focus. Verify VoiceOver labels/order, Reduce Transparency, Increase Contrast and Reduce Motion without hiding native focus.
- Import each starter through Library. Import connects no source; applying a template enables no provider. Invalid/duplicate/executable/symlink packages must be rejected.
- Enable Local Signals, run the sample producer, verify Sample/expiry, then disable and confirm card/connection removal. Never use this as real-agent evidence.
- Connect real Codex/Claude quota; verify missing sign-in, unavailable account, stale/no data, disconnect and reconnect. Distinguish account windows from task progress.
- Enable activity deliberately. Review Codex /hooks trust; reload each client as needed. Verify work, attention, subsequent progress, stop/failure/interrupt, simultaneous sessions, expiry and disable. Claude may not emit user-interrupt events, so silence must expire.
- Resolve approvals in the original client. An attention signal is not an authoritative pending count.

## Power and failure

Keep a controlled background task running during coverage. Confirm normal input inactivity does not suspend the system while covered; display sleep remains allowed. Return releases the curtain-owned assertion. Verify on battery/AC and after sleep/wake. Force invalid/expired metadata and a missing source: curtain/authentication must remain usable and missing data must never become healthy zero/sample quota.

Source/contract tests and a controlled workload do not prove universal task continuity, live credentials, physical gestures or release readiness. Record each case as pass/fail/not tested.

## Activation regression diagnostic

A reported first activation hides Touch ID, while later activation/swiping changes gesture behavior. Privacy acceptance currently fails. To capture comparable trials after building the separate diagnostic bundle:

```sh
./scripts/build-macos.sh debug Still
node scripts/verify-native-interaction.mjs
```

The guided loop asks you to quit every existing Still yourself, launches `out/Still.app`, then checks first activation, second activation and a swipe during activation. Answer y/n from actual observation. Exit 1 means a failed or untested acceptance case, not a build error. Keep its state-only `interaction.json` and `owner-trial.json` local; no passwords/content are recorded.

The stable-activation candidate can be tested separately without rebuilding a running diagnostic app:

```sh
node scripts/verify-native-interaction.mjs --app Still-preview
```

This selects the already rebuilt `out/Still-preview.app` and stores the new report/trace under `out/verification/interaction-trial/Still-preview`. Both settled covers and the activation-time swipe must pass; see [regression evidence](../verification/activation-readiness-regression.md).

## Isolate the password handoff

`node scripts/verify-native-password-boundary.mjs` compares two fresh processes: Touch-ID-only activation-time swipe, then a separate password-dialog/cancel trial. Observe all gestures while covered; return before answering in Terminal. Never enter an account password in Terminal or an app-owned field. Reports identify whether trace events match the required method; failed/invalid trials exit1. The candidate and selected methods stay unchanged. [Evidence and decision boundary](../verification/password-dialog-boundary.md).
