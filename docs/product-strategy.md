# Still — product strategy

Prepared 2026-10-04. Selected an ambient screen, the working name Still, Porcelain with a burgundy direction, direct native app distribution and a Next.js website. Remaining product and implementation choices are proposals for discussion.

## Product thesis

A beautiful native Mac utility that creates a calm screen while the computer keeps working, with optional activity summaries and system authentication to return to the desktop.

The design opportunity is the combination of visual calm, a simple away ritual, and understandable energy controls. Maintaining wakefulness alone is already served by established utilities. The hypothesis is that people will value the experience enough to replace a keep-awake utility; this needs interviews and real usage evidence.

## Two different promises

| Mode | User benefit | Boundary |
| --- | --- | --- |
| Ambient curtain | Custom full-screen design, optional activity, authenticated dismissal | An ordinary app surface; cannot guarantee protection against OS shortcuts, termination, or session changes |
| System lock | macOS protects the session | The OS owns the lock screen and authentication; our custom interactive UI cannot be promised there |

Native research: [feasibility and sources](research/macos-feasibility.md).

Recommendation: lead with the ambient curtain in trusted environments, explain its boundary during setup, and preserve easy access to the system lock. A user requiring security equivalent to macOS changes the product contract: use the native lock and reduce custom UI scope. Do not use marketing language suggesting an app overlay is a secure replacement.

Keeping the system awake reduces one cause of interruption. It cannot guarantee that every app keeps processing, that the network remains available, or that an app avoids its own background throttling.

## Primary audience and jobs

Initial hypothesis: developers, designers, editors, and people running long tasks at their own desk.

1. Step away while a build, transfer, or render continues.
2. Replace an exposed desktop with a pleasing screen.
3. Return with Touch ID or a system authentication fallback.
4. Check a small, deliberately shared summary of what happened.

Public/shared workspaces require the real system lock. An overlay is not a solution for a hostile physical-access threat model.

## Candidate MVP

- Native menu bar entry: Cover screen, Keep awake, Settings, system-lock guidance.
- Manual activation plus optional activation after an idle threshold.
- Separate controls for automatic cover, preventing idle system sleep, and keeping displays on. Disabling one must not silently change the others.
- Timed keep-awake sessions and an explicit end condition; power-source change and battery policy visible.
- One overlay per connected display, with one authentication owner.
- LocalAuthentication dismissal, capability-aware labels, accessible fallback.
- Porcelain as the initial standard, with light/dark appearance and user-selected local wallpaper. Other theme families are retained as future collection candidates.
- Optional app names and this app's session history; activity sharing off by default.
- Onboarding with preview, energy explanation, security boundary, and authentication check before activation.

Defer app-specific progress integrations, custom PIN, animated wallpapers, accounts, cloud sync, theme marketplace, remote unlock, face recognition, and other platforms. A custom PIN needs a separate credential and recovery design; it is not a substitute for system authentication.

The roadmap retains Spectrum, Meadow, and new themes as a possible future marketplace direction. Start with a local theme catalog; decide curation, asset rights, distribution, payments, and external contributions only when that evolution is opened.

## Activity contract

Post-v1 direction: agent status, approval attention, and usage summaries without conversations. Keep it outside MVP; evaluate provider capabilities and an optional CodexBar usage adapter. See [agent awareness](agent-awareness.md).

Running application is not running job. MVP can show selected running apps and events observed by this utility from the time observation starts. It does not reconstruct arbitrary historical activity. A future adapter may report a build or transfer with genuine progress; it must identify its source and freshness. Unknown progress stays unknown.

Before authentication, use counts or user-approved labels only. Never expose document names, websites, terminal commands, message previews, or arbitrary screenshots by default. Decide whether detailed recent activity belongs only in the authenticated app.

## Phases and acceptance

| Phase | Deliverable | Acceptance |
| --- | --- | --- |
| 0 — Decide | Strategy, concepts, selected positioning | Select security contract and visual direction |
| 1 — Prove | Disposable native API experiments | Hardware/OS matrix establishes coverage, auth, idle, power, exit behavior |
| 2 — Build | One complete manual-cover slice | Cover → authenticate → return, multiple displays, cleanup and recovery |
| 3 — Complete | Idle, themes, timed awake sessions, optional activity | Real workflows continue within documented limits; privacy and battery behavior verified |
| 4 — Beta | Signed distribution candidate and support docs | External testers understand the boundary and reliably complete the primary loop |
| 5 — Launch | Final name, public site, release assets | Name clearance, truthful claims, distribution and release approval |

No date estimate until native experiments resolve the main unknowns.

## Naming

**Still** is the working product name. It expresses calm and continuity without a security promise. Domain, relevant trademark checks, package identity and handles are not established. App Store availability is not a distribution requirement.
