# ADR 0006 — Automatic awake default for an active curtain

Date: 2026-10-05. Status: implemented in the local native preview; hardware acceptance pending.

## Decision

An active curtain owns one PreventUserIdleDisplaySleep assertion with no timer. This also prevents idle system sleep. Manual and inactivity-triggered coverage share the same rule. Running the menu-bar app, welcome or preferences alone creates no request. Successful authentication releases it; failed or canceled authentication keeps coverage and the request. Rebuilding display panels preserves its ID. System sleep, user-session resignation and termination release it. Resume reacquires it only when the curtain is still requested.

CurtainAwakeSession owns this lifetime independently of retained finite EnergySession controls. Acquisition and release failures remain typed, retry during policy ticks and never stack requests. A lost OS assertion is reacquired while covered. A failed acquisition shows an explicit warning on the curtain. Independent timed/display controls stay hidden; their timeouts and persistence rules remain unchanged.

The display stays on while covered. The app uses no input synthesis, global power preference changes or privileged helper. Explicit Sleep, lid closure, low battery and OS overrides retain authority. Preventing idle sleep cannot guarantee progress in every application. Automatic screen-saver behavior requires prolonged hardware acceptance; this assertion is not a replacement for the OS security lock.

## API evidence

The installed macOS SDK's IOKit pwr_mgt/IOPMLib.h documents timeout 0 as no timeout for IOPMAssertionCreateWithDescription, and states that PreventUserIdleSystemSleep permits display sleep and explicit/lid/low-battery sleep. Assertions are process-owned; probes additionally verify removal after their own process exits. See [runtime evidence](../verification/curtain-awake-default.md).

## Display-on refinement

The initial system-only decision permitted display inactivity. Following an observed screen saver after one hour of coverage, the curtain now uses the public display assertion. Apple documents that it prevents idle dimming/display-off and inherently prevents idle system sleep. No periodic user-activity declaration is needed. See [display assertion source documentation](https://github.com/apple-oss-distributions/IOKitUser/blob/main/pwr_mgt.subproj/IOPMLib.h) and [refinement evidence](../verification/curtain-display-awake.md). Screen-saver suppression is a separate observed acceptance gate, not a guarantee inferred from the API description.
