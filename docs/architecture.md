# Proposed native architecture

Status: native curtain plus inactivity/finite energy slice implemented with SwiftPM; domain, structural and native assertion-lifecycle checks pass. Native interaction/hardware acceptance is pending. Activity and distribution modules remain proposals.

## Composition

Swift + SwiftUI for screens, settings, and menu bar presentation; AppKit for desktop window coordination; LocalAuthentication for system-owned authentication; Security/Keychain for any future app secret; IOKit for scoped idle-sleep assertions; CoreGraphics for idle-time investigation; NSWorkspace for selected application lifecycle events.

The first local `.app` is built with SwiftPM and a small bundle-assembly script, with a local Swift package for session transitions. A distribution target/signing configuration remains later work; see [ADR 0003](adr/0003-phase-01-local-native-build.md). Prefer a single app process initially. No Electron, embedded browser, always-on server, privileged helper, or external identity service is required for the proposed MVP. Native API candidates and unresolved behavior are documented in [research](research/macos-feasibility.md).

## Repository proposal

```text
apps/macos/                  # native target, lifecycle, presentation
packages/SessionKit/         # feature modules, domain, OS adapters, Swift tests
  Sources/SessionKit/
    Session/
    Authentication/
    Power/
    Activity/
    Appearance/
apps/website/                # Next.js App Router production landing
design/                      # owned artwork and shared token definitions
docs/adr/                    # accepted architecture decisions
docs/research/               # sourced facts and experimental receipts
docs/verification/           # hardware/OS coverage and release evidence
prototypes/                  # disposable UI exploration, delete or absorb
```

Discovery documents, shared brand tokens, licensed fonts, the visual prototype, the native executable package and the SessionKit package exist now. The production Next.js target is not scaffolded yet. `malock` remains the workspace path; Still is the working product name. The development bundle ID is `co.mateonunez.still.development`; `co.mateonunez.still` is proposed for release. No remote visibility, confirmed release identity, license, or Git branching policy is assumed. See [website plan](website-plan.md) and [distribution](distribution.md).

## Deep boundaries

Post-v1 seam: `Activity` may consume optional `AgentProvider` adapters that normalize session status, attention signals and usage windows. Do not add these integrations to the first app slice; the proposed contract is in [agent awareness](agent-awareness.md).

| Module | Responsibility | Public result |
| --- | --- | --- |
| Session | Activation, idle policy, authenticated return, recovery | SessionState and typed transitions |
| Authentication | Capability discovery and one evaluation at a time | Success, canceled, unavailable, denied, error |
| Power | Own and release this app's assertions | Requested policy plus actual acquisition status |
| Activity | Opted-in providers, redaction, freshness | Typed facts, never fabricated progress |
| Appearance | Theme catalog, assets, contrast and motion | Render-ready theme |

AppKit screen windows are owned by one coordinator; display attach/detach never creates a second independent authentication flow. Domain state stays independent of window existence. OS changes and async auth callbacks enter the same coordinator; main-actor UI mutations serialize presentation.

## Orthogonal state

```text
Presentation: inactive → covering → covered → authenticating → inactive
                                         ↘ canceled/error → covered
OS session:   active | systemLocked | sleeping | suspended
Power:        normal | awakeUntil(deadline) | cleanupPending
Activity:     hidden | countsOnly | selectedApps | adapterFacts
```

OS/session transitions take precedence over app presentation. Native experiments must determine how system lock notifications and reactivation work. On wake/unlock, re-evaluate policy and fresh authentication; never treat a stale callback as authorization. Bind an authentication attempt to the current session ID and invalidate it on cancellation, screen/session changes, or teardown.

`Power` state expresses intent; assertion failure produces a visible degraded status rather than a false “awake” label. Timers use an injected monotonic clock; wall-clock changes do not extend sessions accidentally. Release owned assertions on expiry, user stop, and graceful teardown. A crash cannot be treated as a secure lock.

## Credentials and data

The macOS account password is entered only into system-owned authentication UI. Never collect or store it in an app form. Keychain is credential storage/access control, not a separate biometric method. A future app PIN needs a salted slow verifier, attempt policy, secure storage, and system-authenticated reset; process termination still bypasses the overlay.

Preferences and theme selections can be local settings. Recent activity begins at observation time, is redacted before rendering, and is ephemeral for MVP. No cloud backend, account, screen recording, or telemetry of activity content. If an export exists later, make it explicit and redact by default.

## Required proof before app commitment

1. Window coverage across monitors, full-screen apps, Spaces, Mission Control, Dock/menu bar interactions, screen hot-plug and display sleep/wake. Record known escapes, not only successful coverage.
2. Touch ID success, cancellation, password fallback, unavailable biometrics, lockout, system-lock transition, and secondary-screen initiation on supported hardware.
3. Idle detection with minimal permissions; baseline and sandbox comparison. Never request Accessibility/Input Monitoring speculatively.
4. Power assertion acquisition/release, timed expiry, battery transition, display sleep, system sleep and lid behavior; representative task progress under coverage and real lock.
5. Crash and Force Quit behavior, restored settings, explicit recovery route and no leaked assertions.

## Validation and delivery

Use Swift Testing or XCTest for meaningful state transitions, stale auth results, idle policy, expiration, redaction, and cleanup ownership. OS behavior requires real native runs; browser mockups cannot prove it. Native UI automation covers the primary loop without handling account passwords. Record OS version, machine class, displays, power source, and exact build for manual acceptance.

CI proposal: compile with supported Xcode, test domain/adapters, validate bundled assets, and build an unsigned review artifact. Direct signed Developer ID build/notarization, update mechanism, hosted downloads and public publication remain separate delivery gates. App Store submission is excluded. Minimum macOS version, Apple Silicon/Intel support and distribution model stay open until spike results.

## Phase 1 interaction refinement

A native template mark, first-launch welcome window and a session-derived menu replace the initial static menu. Supported Touch ID uses an `LAAuthenticationView` attached to one active display before evaluation. Biometric failure/cancel retains the curtain; the next attempt is user-initiated, avoiding prompt loops. A separate fresh LAContext presents the system password fallback; embedded UI is never used as a password form. No PIN/custom password is included in this version. [Evidence and outstanding native checks](verification/phase-01-interaction-refinement.md).

## Phase 2 implementation

`IdlePolicy` owns fresh-interval/activation rules; `EnergySession` owns finite deadlines and assertion IDs behind a typed driver. Both live in SessionKit. `SessionControls` connects persisted local preferences, a ContinuousClock and the CoreGraphics idle-age scalar to presentation. `EnergyAdapter` owns IOKit bridging and OS timeout safety. The coordinator polls on the main actor, ends awake requests on sleep/session resignation, and resets inactivity after authenticated return/resume. Presentation and energy remain independent. See [ADR 0004](adr/0004-idle-and-finite-awake-sessions.md) and [native evidence](verification/phase-02-idle-and-energy.md).

`StillMaterials` selects native macOS 26 glass button styles with guarded older-OS/Reduce Transparency fallbacks. Only welcome/preferences service windows are non-opaque; curtain panels and their Porcelain background remain opaque. No custom blur of desktop screenshots is used.
