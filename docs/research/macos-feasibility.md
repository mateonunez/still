# macOS feasibility and native validation plan

Research date: 2026-10-04. Status: public API research, not a tested native prototype. The product is a private, elegant screen while the Mac continues working. The working name is Still and distribution is direct, outside the Mac App Store. Minimum supported macOS version and detailed threat model remain open decisions.

## Verdict

A beautiful native curtain over a logged-in desktop is feasible using AppKit windows, SwiftUI content, LocalAuthentication, and IOKit idle-sleep assertions. It can request that the Mac remain awake while work continues, cover displays, and require authentication before the app voluntarily removes its curtain. These are separate capabilities; combining them does not create an OS security boundary. [Window level](https://developer.apple.com/documentation/appkit/nswindow/level-swift.struct/screensaver), [authentication policy](https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication), [power assertion types](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes).

The product must distinguish **Curtain** from **macOS Lock Screen**. Apple documents the OS lock as a security feature with system-controlled authentication. The reviewed public APIs expose app windows and app authentication, not a supported replacement for that system login surface. The latter conclusion is an architectural inference from the documented API scopes, not proof that every possible privileged mechanism is unavailable. [Apple lock-screen guide](https://support.apple.com/en-my/guide/mac-help/mchl8e8b6a34/mac), [LocalAuthentication](https://developer.apple.com/documentation/localauthentication).

## Coverage and security

Use one native window or panel per connected display, sized to the display frame rather than the usable area. AppKit provides collection behavior for Spaces, Mission Control, Stage Manager, and full-screen apps. The proposed combination of a screen-saver window level and appropriate collection behaviors is a candidate to validate, not a promise that the curtain covers every system surface. [Collection behavior](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct), [screen-saver level](https://developer.apple.com/documentation/appkit/nswindow/level-swift.struct/screensaver).

Mandatory threat-model statements:

- **Crash or termination:** the curtain is owned by an ordinary app process. If it dies, its presentation cannot provide a continuing security boundary. Treat desktop exposure after termination as a design limitation, not a recoverable guarantee. A watchdog would not make this equivalent to an OS lock.
- **Force Quit and system shortcuts:** assume a person with keyboard access can escape or terminate an app curtain. Do not claim resistance without evidence, and do not try to defeat emergency recovery controls.
- **Mission Control, Spaces, Stage Manager, full-screen video, app switching:** each needs runtime coverage and input-routing tests. AppKit settings are window-management preferences, not security guarantees.
- **Displays and session transitions:** unplugging or adding a display, changing scale, mirroring, fast user switching, sleep/wake, and invoking the real system lock must be tested. No window should appear above or interfere with a system credential prompt.

These are engineering inferences about a user-space design. AppKit documentation establishes window-management capabilities; native testing must establish the exact visible behavior on supported OS versions. [Collection behavior](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct), [workspace session notifications](https://developer.apple.com/documentation/appkit/nsworkspace).

**Recommendation:** market the initial product as an ambient desktop curtain with awake controls. Keep macOS Lock Screen available and explain when to use it. If actual unauthorized-access prevention is a mandatory requirement, stop and select a system-lock-compatible product direction before implementation. Do not disable the user's existing lock requirement merely to sustain the curtain.

## Authentication model

| Requested mechanism | Public API assessment | Product decision |
| --- | --- | --- |
| Touch ID | Supported through `LAContext` when the Mac reports availability. Enrollment, lockout, and policy failure must be handled. | Primary convenience path; probe capabilities at runtime. |
| Mac account password | `deviceOwnerAuthentication` delegates fallback to the system password prompt on macOS. | Recommended fallback; never render a lookalike system password form or store that password. |
| Apple Watch | Apple's documented owner-authentication policy includes a paired nearby Apple Watch, subject to availability. | Optional system-provided convenience, with hardware testing. |
| Face ID | The cross-platform biometry enum contains Face ID, but the reviewed macOS owner-authentication policy lists Touch ID, Watch, and password. | Do not promise Mac Face ID. A nearby iPhone passkey flow is a different feature; defer it. |
| Keychain | Stores secrets and can gate item access through LocalAuthentication. | Infrastructure for secrets/access control, not a separate credential the user types. |
| App PIN/code | Can be implemented by the app; it does not unlock macOS or inherit system password protections. | Defer unless needed. It creates verifier storage, rate limiting, reset, and recovery work. |

Sources: [macOS owner-authentication policy](https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication), [biometry capability discovery](https://developer.apple.com/documentation/localauthentication/lacontext/biometrytype), [Keychain access controls](https://developer.apple.com/documentation/localauthentication/accessing-keychain-items-with-face-id-or-touch-id), [Apple's distinction between Mac Touch ID and iPhone/iPad Face ID passkeys](https://support.apple.com/en-ie/guide/passwords/mchl4af65d1a/mac).

Use a fresh authentication attempt for the current curtain session. A delayed completion from a previous session must never uncover a later session. Cancellation, lockout, unavailable hardware, and authentication errors retain the curtain; all paths must remain recoverable through normal system controls. LocalAuthentication returns an authentication result rather than biometric material. These session rules are proposed product logic, not behavior supplied automatically by the framework. [LocalAuthentication](https://developer.apple.com/documentation/localauthentication).

## Keeping work running

`kIOPMAssertionTypePreventUserIdleSystemSleep` requests prevention of automatic system sleep caused by inactivity. Display sleep is separate: holding only the system awake can let the display sleep; keeping the artwork continuously visible also requires an appropriate display-sleep assertion. Use named, inspectable, explicitly scoped assertions and release them when the selected awake session ends. [Assertion types](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes), [assertion creation and release](https://developer.apple.com/documentation/iokit/1557078-iopmassertioncreatewithdescripti).

Power assertions are requests, not absolute guarantees. Apple explicitly permits the OS to override them for low power or thermal emergencies. Closing a laptop display normally triggers sleep; this product should not promise closed-lid operation, override explicit Sleep, or bypass power/thermal safety. Closed-display external-monitor operation is a separate hardware configuration to evaluate later. [Assertion limitations](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes), [Mac sleep behavior](https://support.apple.com/en-gb/guide/mac-help/mh10330/mac).

Covering another app does not intentionally pause it, but **“all activities keep running” is too strong**. Other apps can alter their behavior when obscured or inactive, and App Nap can throttle eligible background apps. Our app cannot promise another app's rendering, download, agent, or media behavior. Validate representative workloads and report observations per workload. Apple's App Nap guide is archival guidance; verify behavior on supported contemporary macOS versions. [App Nap mechanisms](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html).

Proposed independent settings: `Curtain after inactivity`, `Keep Mac awake`, and `Keep display on`. Provide a finite awake duration and clear battery impact rather than silently coupling all three settings. This is a proposed UX policy.

## Inactivity and activity visibility

Quartz exposes elapsed time since the last keyboard, mouse, or tablet input using `CGEventSourceSecondsSinceLastEventType` with the any-input event type. Polling that scalar is a candidate for inactivity detection without collecting input contents. The reviewed page does not establish a complete TCC/sandbox permission contract; verify fresh-install behavior with denied Accessibility and Input Monitoring before making a “no permissions required” claim. [Elapsed-input API](https://developer.apple.com/documentation/coregraphics/cgeventsource/secondssincelasteventtype(_:eventtype:)).

`NSWorkspace.runningApplications` supplies running app identities; frontmost-app information and activation notifications can support a locally observed recent-app list from the point collection begins. They do not reconstruct complete historical activity or describe a task's progress inside another app. [NSWorkspace](https://developer.apple.com/documentation/appkit/nsworkspace), [activation notifications](https://developer.apple.com/documentation/appkit/nsworkspace/didactivateapplicationnotification).

MVP activity should therefore mean **Running apps** and optional **Recently used apps**, not invented progress bars for builds, agent runs, uploads, or downloads. Rich work status needs explicit integrations that supply task metadata. Treat filename, repository, terminal content, and task labels as sensitive; hide those by default on an unauthenticated curtain. This is the proposed privacy model.

Screenshots or previews are a separate opt-in feature with screen-capture consent and review of what is exposed. Apple documents permission for its macOS capture sample; its system picker can grant session-scoped selection without separate broad permission. Neither pathway belongs in the initial app-identity-only MVP. [macOS capture sample](https://developer.apple.com/documentation/screencapturekit/capturing-screen-content-in-macos), [system picker privacy model](https://developer.apple.com/videos/play/wwdc2023/10053/).

## Proposed software composition

SwiftUI supplies themes, preferences, onboarding, and activity views. An AppKit host owns per-display panels, window ordering, session transitions, and display changes. Keep platform behavior behind small interfaces:

- `CurtainCoordinator`: explicit presentation/authentication/session state and stale-result protection.
- `DisplayPresenter`: native window coverage and input behavior.
- `AuthenticationService`: capability discovery and OS-owned prompts.
- `AwakeSession`: power assertion ownership, duration, release, and error reporting.
- `IdleObserver`: elapsed-input signal, not a key logger.
- `ActivityCatalog`: bounded app identities and optional local recent history.
- `ThemeCatalog`: local assets, palettes, accessibility variants, reduced motion.

This is an architecture proposal. No daemon, privileged helper, private API, cloud account, global key interception, or screen capture is necessary to define the first bounded experiment. Whether the final signed/sandboxed build supports every chosen capability remains a release validation task.

## Mandatory native spikes before committing the product promise

| Spike | Required evidence | Failure consequence |
| --- | --- | --- |
| Window coverage | Video/manual checklist across multiple displays, Spaces, Mission Control, Stage Manager, full-screen apps, menus, and hot-plug. | Narrow supported modes or revise curtain behavior. |
| Authentication | Touch ID and password success/cancel/failure; unavailable sensor; paired Watch if offered; prompt visibility above curtain; rapid repeated sessions. | Revise presentation or supported unlock options. |
| Power behavior | Inspect assertions and run controlled idle/system/display tests; compare plugged-in/battery; explicit Sleep and lid closure; assertion release on exit. | Narrow awake claims and settings. |
| Background workloads | Actual long-running terminal build, agent run, transfer, and media session before/during/after curtain. | Document app-specific limitations; do not claim universal continuation. |
| Inactivity permissions | Fresh install with permissions absent/denied, signed sandbox candidate, and actual input-reset timing. | Explain/request minimum necessary permission or revise idle feature. |
| Recovery and security | Force quit/crash, system lock, session switch, restart, display disconnect, and delayed authentication callback. | Keep security claims restricted; reject unsafe transitions. |
| Privacy | Opt-out, clear history, excluded apps, unauthenticated activity redaction, no screenshot collection. | Remove activity detail until behavior is verified. |

Acceptance is native runtime evidence on an agreed OS/hardware matrix. API documentation, HTML mockups, and unit tests cannot establish these behaviors.
