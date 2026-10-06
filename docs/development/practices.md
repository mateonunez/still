# Developer practices

## Native vertical slice

The native app lives in `apps/macos`; session rules live in the local `packages/SessionKit` Swift package. SwiftUI renders the curtain, AppKit owns all display panels and the menu bar, and LocalAuthentication owns the credential UI. Phase 1 uses SwiftPM to build an actual app bundle without adding a project-generator dependency. An Xcode package workspace can open both packages; a distribution target/signing configuration remains a later deliverable.

Use Swift 6 concurrency checks. Keep AppKit and observable presentation state on the main actor. Normalize authentication results before crossing back to the UI. One session and one authentication attempt serve all displays. Old callbacks must never clear a newer session; invalidate attempts when the screen topology or OS session changes.

Never collect a Mac password, introduce a hidden dismissal bypass, or intercept global system recovery shortcuts. Termination necessarily removes the app's windows. During system authentication the panels lower their window level to avoid obscuring the credential dialog; desktop coverage during that interval is best-effort and requires native validation.

## Build and verification

From the workspace root:

```sh
./scripts/build-macos.sh
swift test --package-path packages/SessionKit
node scripts/check-contrast.mjs
```

The build produces `out/Still.app` with an ad-hoc local signature. This is not Developer ID signing, notarization or an end-user installer. `out/` and SwiftPM `.build/` directories are ignored. macOS 14 is the provisional compile/deployment floor, not a verified support claim. The current host is arm64; Intel support is unverified.

`design/tokens.json` is canonical. Run `node scripts/generate-native-tokens.mjs` when tokens change; the app build also regenerates the native palette. Native controls use system type. Register the bundled Instrument Serif only for the current process and include its license; never install fonts globally.

Swift Testing macros can capture a method receiver by value. Evaluate mutating session operations first, then assert the result; this avoids immutable-receiver macro expansion errors while keeping assertions meaningful.

## Evidence discipline

Domain tests verify transition logic, not LocalAuthentication, Spaces or display coverage. Launch the built `.app` and observe its actual UI. Record the exact executable hash, macOS build and display setup. Use a controlled synthetic workload for progress observations; never inspect private agent conversations or claim all apps continue based on one workload.

Authentication success must be completed interactively through the macOS dialog. Automated inspection can verify prompt presentation, cancel/retry and visible state without obtaining the account password. Multi-monitor, Spaces, Mission Control, Stage Manager, system lock and sleep/wake remain separate acceptance cases.

Keep network calls, analytics, agent discovery, activity collection and power assertions out of Phase 1. No permissions are requested speculatively. The local identity is `co.mateonunez.still.development`. `co.mateonunez.still` is a proposed release identity. Developer ID credentials, the final bundle identity and update policy belong to explicit decisions; local development success does not establish distribution readiness.

## Inactivity and finite energy sessions

Phase 2 adds power assertions as an independent vertical slice. Keep idle decisions and assertion ownership in SessionKit; OS bridging lives in the native target. Inject a monotonic clock into domain rules. Use ContinuousClock for elapsed session deadlines across sleep; never use wall time to extend an awake session. Start disabled and persist only deliberate idle/display choices, never a running awake session. Reset the idle grace interval after return/resume so biometric input cannot immediately re-cover using an old global idle age.

Use the CoreGraphics elapsed-input scalar only while enabled. Do not record input contents, install an event tap or request speculative Accessibility/Input Monitoring permissions. Scalar availability on a configured development host does not establish fresh-install permission behavior.

Acquire finite named IOKit assertions with OS timeout-release safety. Release only owned IDs, retain/retry failures, roll back partial acquisition and avoid replacing a session while cleanup is unresolved. A failed request must not produce a false active label. Display intent only adds a request during an explicit awake session. End requests on Stop, expiry, sleep/session resignation and teardown; do not restart on wake. Always consume the retained CFDictionary before bridging IOPMAssertionCopyProperties.

`node scripts/verify-native-energy.mjs` runs a bounded own-process probe and cross-checks only its own pmset records. Discard unrelated process names and tolerate non-UTF-8 output. Native lifecycle proof is separate from real display/sleep timing, lid behavior, battery transitions and endurance. Update exact artifact hashes after UI rebuilds before attributing runtime evidence to a candidate.

## Native materials

Use availability-guarded native macOS 26 glass button styles for important controls; keep the curtain opaque. Vibrancy belongs in welcome/preferences service surfaces, with solid fallbacks for Reduce Transparency and Increase Contrast. Preserve standard native focus and semantic controls; do not add forced initial focus or hide focus rings. Keep styling in `StillMaterials`, not repeated availability branches throughout features.

ImageRenderer cannot faithfully export live native Pickers, Toggle switches, biometric NSViews or material backdrops. Reject unsupported-control images as UI/marketing evidence. Native compilation and token contrast are useful checks, but live material/accessibility acceptance remains a separate gate. Split complex SwiftUI sections when compiler type/IR generation becomes unstable, then rerun the exact failed build.

## Deferred product controls and compositor behavior

Keep retained functionality behind an explicit product-availability flag when its product concept is deferred. Gate every entry point and current product copy; preserve implementation, tests and saved choices. Do not invent a new combined energy/inactivity policy before its behavior is selected.

Record live collectionBehavior getters, not only assignments. Mission Control and trackpad animation exposure need a native red-capable reproduction; flags, isVisible and frame equality are not evidence of compositor coverage. Native app handles should use the full app path when development bundles share an identifier. App-window screenshots are not whole-desktop-transition evidence. Never use `.transient` as a coverage fix: it hides the window in Mission Control. Keep private desktop captures out of the repository.

## Website and hosting

Use project-local public-registry configuration instead of inherited machine npm settings. Pin the package manager and commit the lockfile. Biome is the sole formatter/linter; do not copy a reference site's broad rule disables. Generated CSS must match formatter output: normalize color case in the generator rather than repeatedly rewriting generated files after builds. Preserve original font licenses and their provenance, including original license whitespace.

Compose typed metadata per route; canonical origin is meet-still.app. Keep a single native robots/sitemap implementation and server-rendered explanations. Explicit noindex headers/meta apply to preview and development, including custom preview domains. Permit crawlers to read accessible previews' noindex; robots is not access control. Do not fabricate reviews, offers, availability or an AI-ranking protocol.

Vercel root apps/website needs sourceFilesOutsideRootDirectory for canonical tokens and the prebuild generator. CLI uploads use .vercelignore to exclude env files, native builds, binaries and unnecessary private artifacts. Read credentials through CLI authentication, never print tokens or copy local env files. Validate production via scripts/verify-website.mjs, then inspect actual mobile/desktop and keyboard behavior. CI success, Vercel READY, domain TLS, correct HTML and real search indexing are separate evidence levels.

## AppKit regression learned in Step 1A

Set `NSPanel.level` after configuring `isFloatingPanel`: the original order reset the level to `.normal`. Verify the getter in the live app, not only the assignment in source. The runtime probe checks panel count, frames, visibility flags, actual window level, font registration and synthetic subprocess progress; these remain structural evidence rather than a desktop coverage test.

Run `node scripts/verify-native-runtime.mjs` after the app build to regenerate local native view exports and receipts. It creates and terminates its own app/workload only, and makes no credential request. Exported PNGs are native SwiftUI view renders, not screenshots of the real desktop. The `--evidence-directory` argument is opt-in; normal launches write no diagnostic files.

## Embedded authentication and menu state

Create one `LAAuthenticationView` for a fresh biometric LAContext; attach it to the initiating display, then evaluate after `viewDidMoveToWindow`. Pass the exact view through the readiness callback and compare identities before evaluation; a readiness callback from a removed view must not start a newer context prematurely. Do not attach the same context to multiple display controls.

Password fallback uses a separate context without an embedded view. The SDK documents that embedded owner authentication still fails when no biometric/companion mechanism is available. Never build an app-owned Mac-password field. Invalidate the old session attempt before switching methods, and reject late results. A canceled or failed attempt stays covered and does not automatically loop.

Derive menu state from the session; keep one primary action, disable duplicate system-dialog attempts and preserve Quit. Development metadata belongs in About. Keep first-launch discovery visible without unsolicited notifications or permission requests. Native menus and authentication need human validation even when the domain-state tests pass.

Build a separate candidate with `./scripts/build-macos.sh debug Still-preview` without replacing an app under interactive testing. Binary replacement uses a new file plus rename rather than truncating a potentially mapped executable. Probes must terminate only their own subprocesses. `node scripts/verify-native-runtime.mjs --app Still-preview` stops only its own subprocesses and avoids biometric evaluation. `--render-only` produces source-view exports without presenting a curtain.

## Focus and embedded-view sizing

Do not force focus onto a secondary password action during biometric-first presentation, and do not stack a custom outline over the native focus effect. Preserve native Buttons, keyboard shortcuts and focus behavior; never change OS accessibility preferences for appearance. Bind both dimensions of an embedded AppKit control to its SwiftUI host, not just its center. Validate live controls separately: native view exports use an illustrative fingerprint and cannot reveal overflow of the system NSView.

## Shared Next.js previews and Node verification

Keep visual prototypes as typed React features in the existing website app, with scoped CSS and canonical tokens. Route groups keep public chrome separate without changing public URLs. `/preview` uses explicit noindex headers/metadata, is omitted from the sitemap and returns 404 on Vercel production. Enable a local production preview only through STILL_DESIGN_PREVIEW. Never substitute sample values for a connected provider's unavailable data.

Node is the sole script runtime. Verification tools use core Node APIs without a Python server or additional parser/test framework. Keep native probes process-owned, output-confined, bounded and credential-free. Historical reports retain their original commands; fresh receipts identify the current executable/tool. Shared font provenance and native resources live in design/fonts; preserve original license bytes.

When moving App Router files, stop the owned dev process and regenerate its .next types before the production build; stale dev validators can reference removed route paths. Next.js agent-rule generation is disabled so generated collaboration files do not enter source control.

## Curtain-owned power lifetime

Keep the automatic system assertion separate from retained finite sessions. Start it when coverage is requested; release it on authenticated return, suspension and teardown. Rebuilding panels must not end the power lifetime. Never acquire on welcome/preferences alone. Retry acquisition or failed release without stacking IDs, and expose a failure instead of claiming the Mac is awake. Use timeout 0 only for this process-owned curtain lifetime; retain OS timeouts for independent finite sessions. Native probes must own and clean their assertions and record the exact executable hash.

## Customization prototypes

Keep disposable UI under the existing Next.js preview route, with explicit fictional data, no provider access and in-memory widget/source/disclosure state. Preserve noindex and production unavailability. Use canonical semantic palette roles; native glass, authentication and multi-display behavior cannot be proven by browser screenshots. Demonstrate unavailable/stale states without substituting healthy quota values. Browser interactions, typed builds and palette checks are evidence at their respective boundaries, not proof of a plugin contract or live integration.

## Native quota adapters

Project provider input into `StillWidgets.UsageSnapshot` before rendering; never retain vendor payloads, transcripts or credentials in evidence. Validate observation age, actual window duration, finite percentage and reset expiry. Absence is unavailable. Keep internal built-in protocol evidence distinct from the public StillPluginKit wire contract.

Use dedicated owned subprocesses with bounded output, timeout, cancellation and cadence. Source changes invalidate callbacks. Claude settings changes must preserve existing command/options and unrelated settings, retain private backups and refuse restoration over external edits. Test wrapper forwarding and stale-data removal in owned scratch directories.

Open interactive app bundles through Launch Services. For transparent title bars, extend the background through full-size content while reserving measured native title-bar space for scroll content. Verify a real control action and scroll screenshot; build success alone does not prove interaction or materials.

## Local plugin contracts and advisory hooks

Keep the public wire format in StillPluginKit, independently versioned from internal StillWidgets Codable files. Validate exact keys, package shape, bounded regular files, provider/capability combinations, connection identity, revisions and freshness before rendering. Use ISO 8601 on public wire dates and a monotonic host expiry. Full replacement/empty facts clear prior signals. Never execute imported code; a manifest is not an OS sandbox or publisher verification.

Treat connection as explicit consumption consent. Reconnect rotates UUID; disconnect clears cards/files and invalidates old producers. External same-user producers keep their own permissions. Label fixtures Sample, and never use them as unavailable live fallback. Validate both starter packages in CI.

Hook input can contain content transiently. Project only supported events/identities, privately HMAC identities, never retain vendor input/logs/transcripts, and emit no decision output. Preserve unrelated hooks/settings and client trust. Test settings conflicts, expiry, concurrent session groups, stop/failure/end, disable, and helper timeouts in owned scratch. Live client delivery is separate from a synthetic stdin test.

Presentation restrictions must restore exact prior options on return, suspension, teardown and system-authentication handoff; cancellation reapplies only while covered. Preserve recovery. Cmd-Tab restriction is not a Spaces swipe veto. Physical slow/fast/partial transitions require their own red-capable test. Inactive glass controls use a readable standard-control fallback; keyboard focus is retained.

For activation/authentication regressions, use the guided native interaction loop and opt-in bounded state trace. Preserve null for untested human observations. Report replay is not unattended gesture synthesis. Capture app active/key-window state, embedded-view attachment and presentation flags before choosing a timing/focus fix; normal launches must not write diagnostics. Do not rebuild a user-owned running candidate during a trial.

## Stable activation and biometric readiness

Screen-parameter notifications include Dock/menu visible-area changes. Compare physical display identity/full frame/scale, guard reentrant panel construction, and retain presentation-policy ownership across a covered rebuild. Invalidate authentication only for an actual new topology or deliberate new cover. Reconcile a physical change arriving during construction after the current build finishes.

A container's window is not proof its embedded LAAuthenticationView is attached. Check the actual child at deferred readiness time, mark readiness only after success and permit later valid attachment. Evaluation requires the current view on an owned key window with the app active; activation notifications can complete pending setup. Never introduce continuous focus reclamation, automatic failed-authentication retries or system-dialog interference. Test detached→attached→duplicate readiness against real AppKit NSViews without evaluating credentials.

The native runtime probe now asserts one panel generation for unchanged topology and writes an explicit state-only trace. This does not replace the physical gesture/authentication checklist. [Regression evidence](../verification/activation-readiness-regression.md).

## Physical authentication comparisons

Separate fresh-process Touch-ID-only trials from system-dialog trials and validate the actual method in the state trace. Ask for observations after returning so Terminal focus does not contaminate a covered trial. Test dialog-open, immediate cancel recovery and settled cancel recovery separately. Presentation flags with an inactive app do not prove effective restrictions. Treat a fallback change as a separate product decision and never infer complete gesture privacy from removing a dialog.

## Curtain power ownership

Use one indefinite display-idle assertion while covered; it also prevents idle system sleep. Do not confuse a system-only assertion with display or screen-saver suppression. Check the real assertion type, owned ID, timeout and cleanup with IOKit and PID-scoped pmset output. Preserve independent timed requests and system overrides. Do not synthesize input or change global screen-saver/security preferences. Short probes establish ownership, not an hour of unattended visual behavior; record that acceptance separately against the exact executable hash.

Use the same full-size content/title-bar geometry for service windows. Measure the native title-bar inset instead of hard-coding a traffic-light offset; reserve that space while extending the material through the entire window. Keep native window controls and visible keyboard focus. See [Settings alignment](../verification/settings-titlebar-alignment.md).

## Native plugin sources

Keep compiled first-party adapters separate from declarative community imports. Installation, discovery, enablement, source consent and visibility are distinct states. Native configuration is validated and persists locally; retain all selected cards without a global count cap; report geometric crowding separately. Fold supported agent providers into one Agents card without turning expiring attention into authoritative approvals.

Read only selected GitHub/Vercel resources with fixed GET arguments and separately authenticated CLIs. Bound each owned subprocess by time and output size; cancellation stops only that process. Test excessive output and cancellation. Spotify Automation runs only after an explicit consent action; isolate blocking property/permission reads in the bounded helper. No command, transcript, environment or raw error enters a task receipt. Revisions/UUIDs and monotonic deadlines protect reconnection/freshness; suspension clears facts. Keep weather attribution and commercial-provider readiness separate from local evaluation. See [native authoring](native-plugin-authoring.md).

Module arrangement is a host preference, not source authorization. Keep drag operations paired with named keyboard buttons, validate dragged IDs, normalize saved order and preserve every known module once. Timeline-driven groups need an explicit layout container; avoid multiple uncontained children whose frames overlap in the live host. Reserve composition space before placing authentication controls. Use ViewThatFits for intrinsic groups and scroll only as a constrained fallback.

Read-only Apple Events must use fixed property identifiers, never-interact and bounded reply/parent lifetimes. Background preflight permission checks can themselves stall; consent belongs to an explicit Hub action. A bounded unavailable response is not provider success. Keep existing errors visible during automatic retries and report consent/playback acceptance separately.

Full-screen composition stores normalized module centers and explicit size values, validates version/known IDs/finite bounded coordinates, and renders the same scene in editor and curtain. Editing belongs to a normal service window; never attach editing gestures to the covered curtain. Keep the authentication region host-owned and suppress idle activation during editing. Dragging must have selection and named directional alternatives. The initial native canvas is not a collision engine or a per-display scene manager.

Explicit authorization may also hang: never put an unbounded native permission API in the app's detached task and treat thread separation as a lifetime bound. Use an owned cancelable helper with reply/process limits and require a real successful read before recording connection. Keep unresolved authorization feedback adjacent to the permission button.

Settings has one window owner and one shared section container. General controls must not introduce a second preferences window or wrap their content in a competing service material/title-bar layout. The screen editor returns to Settings.

Spotify transport regression checks must distinguish the caller identity from Still-owned consent. A timeout is not a permission denial. Resolve the installed, running player to its process descriptor and retain subprocess bounds. Settings navigation and the section heading stay outside scrollable plugin content; appearance controls have one settings entry point.

## Public catalog and fresh profiles

Generate public manifest metadata and SDK downloads with `node scripts/generate-public-sdk.mjs`; do not edit generated copies. Keep provider setup/privacy descriptions typed and separate from canonical manifests. Verify schema-ID URLs and asset bytes as well as HTML metadata. Agent text resources are documentation, not a ranking protocol.

Prepare missing built-in configurations disabled and hidden, preserve existing bounded regular files, and reject symlink roots. Installation must not connect providers or request permissions. Main content uses the macOS main display ID; topology reconciliation also tracks main-display changes. Never replace a running candidate: the builder checks the exact bundle executable path before mutation.

## Display-local canvas geometry

Use the same CGMainDisplayID selection for editor and curtain; NSScreen.main follows keyboard focus. Fixed-frame hosting views must disable content-derived sizing options and use the owning panel viewport. Measure SwiftUI subviews before resolving collisions; cache on measured items and the content area. Fall back to Balanced without rewriting saved positions. Clip optional modules outside the header and measured return region. Surface unresolved crowding in the editor rather than silently claiming a universal collision guarantee. Keep drag origin tied to rendered frames and retain named keyboard alternatives.

Track enabled visible native IDs independently of asynchronous payload readiness. Visibility has no global count cap: return every selected card and diagnose actual geometric crowding. Disabled sources stay hidden without losing remembered visibility. Diagnostic reads of configured agent quota must not install status lines/hooks or write provider preferences.

Keep the original presentation restore point while reasserting covered options after activation. Credential dialogs stay system-owned and visible; retained restrictions are not a Spaces veto. Local activity renewal owns and reuses the returned IOKit identifier, uses a monotonic fifteen-second cadence and stops on return/suspension/quit. Simulated-hour tests are scheduling proof, not screensaver endurance proof.

## Continuous canvas interactions

Persist optional width in points, with explicit null for automatic sizing. Missing width migrates legacy saved size categories; legacy clock width remains automatic. Validate finite values and bounds before loading. Do not quantize free placement. During resize gestures, retain original centers and defer collision fitting until release; keep pointer tracking unanimated and respect Reduce Motion for settling. Provide a native slider and named movement controls as alternatives to pointer handles. Exported SwiftUI images cannot establish native-control rendering or interaction smoothness.

## Structured native layout

Keep Grid and Free as explicit, persisted modes. Old records without a mode remain Free; new scenes/reset use Grid. Grid owns track widths, row starts, wrapping and gaps; it does not use the Free collision-search algorithm. Measure native children before planning rows and keep overflow distinct from overlap. Preserve free placements and widths when changing modes. Free drag and resize gestures use the named canvas coordinate space; use system drag sessions and process-local typed drop targets for Grid live insertion. Free drags freeze other module centers until release. Whole-row keyboard steps must insert at the actual destination, not swap only a distant neighbor. Keep complex SwiftUI toolbars in small computed subviews to avoid compiler failures from oversized view types.

## Theme and editing layers

Keep canonical theme colors in design/tokens.json and generate native palettes. Separate opaque Still scenery, within-window card materials and Liquid Glass controls. Do not wrap glass buttons in another custom glass effect. Respect appearance and accessibility preferences in each layer. Scene preferences must not be persisted as a side effect of constructing diagnostic presentation models. Keep gallery actions separate from source consent, and contextual inspector controls separate from scene geometry. Validate optional per-module preferences during migration and preserve them during fitting. Native drag callback behavior and perceived smoothness require interactive acceptance.
