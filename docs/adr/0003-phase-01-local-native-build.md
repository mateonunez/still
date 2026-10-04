# ADR 0003 — Build the first native slice with local Swift packages

Date: 2026-10-04. Status: accepted local build approach; distribution configuration remains open.

## Context

Xcode and Swift 6.3.3 are installed on the current Mac. The first slice must be a real `.app`, without requiring accounts, external tooling or release credentials.

## Decision

Build the native SwiftUI/AppKit executable with SwiftPM, keeping pure curtain-session transitions in a local `SessionKit` package tested with Swift Testing. Bundle the binary, Info.plist and licensed display font through one repeatable script. Use ad-hoc signing only for local validation. The final bundle identifier and Developer ID signing are explicit decisions, never inferred from the workspace path.

Phase 1 implements manual presentation, light/dark/system appearance, LocalAuthentication dismissal and ordinary termination. It adds no awake assertions, idle timer or activity reader. The panels use high-level AppKit presentation and lower their level during OS authentication so that the credential UI can appear. This creates a known best-effort interval, not a security guarantee.

## Consequences

A genuine local `.app` is reviewable before selecting distribution targets or adding a project-generator tool. Domain test results do not establish native presentation/authentication behavior. macOS 14 is a provisional compilation floor; only the actual host is initially verified. An Xcode distribution target, app icon, hardened-runtime configuration, final identity, signing, notarization and updates remain later work.

References: [Apple window behavior](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallapplications), [authentication context invalidation](https://developer.apple.com/documentation/localauthentication/lacontext/invalidate%28%29), [architecture](../architecture.md).
