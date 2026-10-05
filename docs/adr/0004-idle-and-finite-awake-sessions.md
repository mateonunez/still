# ADR 0004 — Independent inactivity and finite awake sessions

Date: 2026-10-04. Status: implemented for the local preview; hardware/interaction acceptance pending.

Product follow-up: awake/display controls are hidden with their implementation retained, pending a unified inactivity concept. `ProductFeatures.awakeControlsVisible` is false. This ADR records the retained implementation, not currently available product controls. The automatic curtain-owned system request is now defined separately in [ADR 0006](0006-curtain-owned-awake-default.md). See [follow-up evidence](../verification/phase-02-deferred-awake-and-spaces.md).

## Decision

The retained implementation has three controls: curtain after inactivity, a finite keep-Mac-awake session, and a separate keep-displays-on preference. All default off on first use. Idle/display preferences persist locally; active awake sessions never restart automatically after launch.

- Inactivity choices: Never or 1, 3, 5, 10, 15, 30 minutes. Poll the combined-session elapsed-input scalar every second only when enabled. No event tap, keystroke capture or input synthesis.
- Enabling/changing the idle threshold, successful dismissal and resume start a fresh interval on a monotonic clock. An old idle age cannot immediately reactivate the curtain after biometric dismissal.
- Awake choices: 15, 30, 60, 120 minutes. Manual activation, curtain dismissal and awake expiry are independent. Awake expiry does not remove the curtain.
- The display preference affects only a running awake session; off-session it is a saved choice. A display-sleep prevention request inherently also affects idle system sleep, so do not promise physically independent display-only sleep behavior.
- An awake session acquires PreventUserIdleSystemSleep; optionally acquire PreventUserIdleDisplaySleep. Toggle display ownership without releasing the system request. Failed partial acquisition rolls back and displays a typed error.
- Use ContinuousClock for deadlines. Configure OS timeout release at the app deadline plus a two-second scheduling margin. Expiry, Stop, explicit sleep, user-session resignation and graceful termination release only owned IDs. Do not automatically restart after sleep/session switch.
- Retain failed releases for retry; refuse a new session while cleanup is pending. Verify owned requests are still active before showing active status. If macOS ends a request early, end the session and show a message.

No global power setting, privileged helper, closed-lid override or accessibility/input-monitoring request is added. The preview cannot override explicit sleep, thermal/low-power safety, system lock policies or other apps' behavior.

## Evidence and consequences

29 domain tests, 11 native energy checks (including pmset cross-checks and OS timeout without app polling), and 8 structural presentation checks pass on the current one-display Apple Silicon host. This is not actual unattended sleep/display/battery timing or fresh-install permission proof. [Phase 2 report](../verification/phase-02-idle-and-energy.md).

Phase 1 interaction and large-screen acceptance remain open alongside Phase 2. Keep both matrices visible. Native preferences use standard system controls and the Porcelain palette; a render exporter cannot stand in for their actual UI.

Sources: [Apple assertion creation/timeout](https://developer.apple.com/documentation/iokit/1557078-iopmassertioncreatewithdescripti), [assertion scopes and OS overrides](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes), [elapsed-input signal](https://developer.apple.com/documentation/coregraphics/cgeventsource).
