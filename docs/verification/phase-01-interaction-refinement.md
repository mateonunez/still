# Phase 1 — Interaction refinement

Date: 2026-10-04. Status: implemented and compiled; native interaction acceptance remains open.

## Observed behavior

A live native menu screenshot documented the first `.app`. This verifies discovery of the menu-bar entry and the original idle menu, not an authentication result. The screenshot exposed three product issues: launch was difficult to notice, the pause icon was not sufficiently recognizable, and the menu simultaneously offered Show Still and Return to desktop regardless of session state.

This version supports **Touch ID + the Mac password**, with biometric-first dismissal. An app PIN/custom password is excluded from the current version.

## Changes

- Original quiet-aperture mark, drawn as a native template image at menu-bar size. Covered sessions add an inner point; status also has text, never icon/color alone. The vector reference is `design/still-mark.svg`.
- First normal launch shows a small Porcelain welcome window explaining the menu-bar location. Reopening the app brings that window back when inactive. Development-only wording moves to About.
- One context-sensitive primary action in the menu, refreshed on open. Appearance marks the current choice. About is disabled while covered to avoid hiding an alert behind the curtain. Quit remains available.
- When supported Touch ID is available, attach Apple's `LAAuthenticationView` to the active curtain display, then evaluate a fresh biometric context. The initial attempt begins after the view enters a window, without a Return-button click.
- A separate fresh context handles system authentication/password fallback. Embedded UI does not support password entry. The **Use Mac password…** action opens the system dialog; choose its password fallback there. The app never receives the password. The OS may still offer Touch ID/Watch first in that dialog.
- Escape cancels a waiting attempt while retaining the curtain. Failed/canceled biometric attempts do not automatically loop; Return can prepare a fresh attempt. Switching method invalidates the old attempt before evaluating the new one.
- Only one display hosts the live biometric view/context. Other displays share the session and can request the system fallback. Hot-plug/session changes invalidate pending attempts.

| Session | Primary menu action | Enabled |
| --- | --- | --- |
| Inactive | Show Still | Yes |
| Covered, no active attempt | Return to desktop… | Yes |
| Embedded Touch ID pending | Other unlock options… | Yes |
| System dialog pending | Authentication in progress… | No |
| Suspended | Return after waking your Mac | No |

Apple documents the embedded authentication view and the normal Mac-password fallback separately. The installed SDK header explicitly limits embedded policies to biometric/companion authentication; `deviceOwnerAuthentication` in that embedded view does not turn it into a password form. [Embedded UI](https://developer.apple.com/documentation/localauthenticationembeddedui), [LAAuthenticationView](https://developer.apple.com/documentation/localauthenticationembeddedui/laauthenticationview), [owner-authentication policy](https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication).

## Evidence

Artifact verified for this step (superseded by the [visual polish](phase-01-visual-polish.md)): `out/Still-preview.app`, co.mateonunez.still.development, arm64, ad-hoc signature, no TeamIdentifier. The previously running `out/Still.app` process was not terminated or replaced. The first compile attempt failed before bundle assembly; corrected closure isolation and missing generated palette role, then built the separate preview successfully.

Executable SHA-256: `24798f89d0b09b0a54d65406f18b0d4322a09d8501385e03712850956cbe6478`.

```sh
./scripts/build-macos.sh debug Still-preview
swift test --package-path packages/SessionKit
python3 scripts/verify-native-runtime.py --app Still-preview
```

- Swift Testing: **16 tests pass**, including menu availability during pending system/biometric attempts and rejection of an old biometric result after method switching.
- Candidate native probe: **8 structural checks pass** on Mac16,7 / macOS 26.5.2 (25F84), one reported display. Panel geometry matches 1728 × 1117; panel level 1000; bundled display font is registered.
- Synthetic hashing subprocess iterations: 1 → 2,729,062 → 3,415,365 before/during/after the probe interval. This is limited progress evidence, not a universal app-continuation guarantee.
- Native light/dark and welcome renders inspected. Exports live under ignored `out/verification/phase01-refinement/`, alongside runtime/smoke receipts and an actual raster export of the menu-mark image.
- The view renders illustrate the fingerprint area with an SF Symbol because ImageRenderer does not capture a live `NSViewRepresentable` authentication control. They do **not** prove sensor readiness, the live authentication animation or a successful fingerprint. The live app uses Apple's view.
- The runtime probe explicitly avoids starting biometric authentication. It validates the actual candidate's structural presentation and stops only its own subprocesses; existing interactive processes remain available.

Render-only reproduction, with no curtain or authentication request:

```sh
out/Still-preview.app/Contents/MacOS/Still --render-only \
  --evidence-directory out/verification/phase01-refinement
```

A render-only receipt is labeled separately and is not a runtime-coverage receipt. Running the structural probe regenerates the runtime receipt. Keep all exports local and ignored.

## Human acceptance next

Quit the old Still using its menu, then open `out/Still-preview.app` (same development identity). Follow [the updated guide](../guides/native-preview.md).

Verify the new welcome window/icon/menu, then Show Still and rest a finger on Touch ID without first clicking Return. Record whether the inline control becomes ready and whether a separate system dialog appears unexpectedly. Test password fallback, cancellation, Escape/retry, fallback while biometric auth is pending, and restoration of the previous app. Repeat on a secondary display and after sleep/system lock/hot-plug.

System timeout, lockout, enrollment and hardware capabilities remain OS-controlled. The app cannot silently sample fingerprints globally, replace the OS lock, hide the system password dialog or disable normal recovery. The computer-use tool's inability to recognize the app still blocks automated native interaction verification. Phase 1 is not accepted yet; Phase 2 is unstarted.
