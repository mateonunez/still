# Password-dialog privacy boundary

2026-10-05. Status: observed password handoff gap; isolated Touch-ID-only comparison pending. No change to the selected authentication methods and no custom code implementation.

## Confirmed current candidate

Executable SHA-256 `7257c18eef82883dfd1a25234e3c5058fa85ef48a69572c27af50353cde793b6`. The guided owner report now confirms embedded Touch ID visible on first and second cover; neither settled gesture trial exposes underlying windows. The activation-time swipe still exposes windows. The native trace records attached Touch ID and authentication success, with exact presentation-option restoration after return. This accepts the reported first-activation visibility correction on this host, not universal compatibility or complete privacy.

## Password evidence

The owner also observes exposure after selecting Mac password. Existing trace/code distinguish:

- System-authentication handoff: Still deliberately restores its prior presentation options and lowers its panels so the macOS credential dialog can be used. The current source sets normal panel level; this is source evidence, not a window-level measurement in this trace.
- In the password attempt ending successfully, Still is inactive/non-key with presentationOptions=0. Two active-Space changes occur before authentication succeeds. This agrees with the reported dialog-time exposure.
- A canceled system attempt records inactive/non-key state. The covered policy becomes 38 again, but activation/key restoration appears about 1.3 seconds later. This is an observed recovery interval; whether the eventual activation was automatic or caused by user interaction is not established.
- The later activation-time swipe changes Space while Still first reports active/key with options38, then inactive/non-key. The preceding sequence used password, so it does not isolate a possible prior-dialog effect from a separate transition limitation.

[Apple presentationOptions](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.property) describes options applying while the app is active. [disableProcessSwitching](https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disableprocessswitching) documents Command-Tab, not a blanket Spaces/trackpad veto. Current Apple Markdown documentation was checked directly on 2026-10-05.

Conclusion: the native password handoff has a verified presentation gap. It is not yet established that it causes the activation-time swipe failure. Removing the dialog could avoid this specific handoff, but is not evidence of a general gesture fix.

## Controlled comparison

```sh
node scripts/verify-native-password-boundary.mjs
```

Uses the existing unchanged preview, separate fresh processes, timestamped private receipts and no account-password entry in Terminal. Observe while covered and answer only after returning, to avoid making Terminal focus part of the test.

A: activation-time swipe and Touch-ID-only return; trace must contain no system-authentication attempt and at least one Touch-ID-mode authentication success. B: a fresh process, settled cover, password dialog open, cancel, immediate swipe and another after two seconds without clicking another window. Return only afterwards. Trace must contain a system attempt and canceled outcome. Invalid/nonisolated trials are explicitly marked; any exposure yields exit1, which is expected for the currently known boundary.

The script parses state-only native receipts and stores the owner verdict in `out/verification/password-boundary/<timestamp>/comparison.json`. Baseline receipts remain private/ignored. Syntax and Biome checks pass; full guided execution remains pending physical input.

## Decision after evidence

Keep Touch ID + Mac password for now. A Still-specific code is a separate product/authentication decision: it would need deliberate setup, local Keychain-backed secret handling, attempt limits, recovery and accessibility acceptance. It must never be the Mac account password and would not make Still the macOS security lock. No custom-code design or source access is silently enabled by this investigation.

If A fails without any password dialog, changing fallback alone cannot close that reproduced privacy case. If A passes while B fails, investigate dialog presentation/recovery separately before choosing whether to retain Mac password or build an in-app fallback. A single passing trial is not a compositor guarantee.
