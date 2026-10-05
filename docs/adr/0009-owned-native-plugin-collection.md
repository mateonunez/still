# ADR 0009 — Owned native plugin collection

Date: 2026-10-05. Status: implemented locally; source-specific OS consent and visual acceptance remain separate gates.

## Decision

The mateonunez collection contains ten compiled native plugins: Agents, Build Watch, Deploy Watch, Task Watch, Mac Pulse, Next Up, World Clock, Quiet Timer, Weather and Spotify. Agents groups Codex and Claude under one configurable plugin with separate quota/activity source choices and executable discovery. Installing or discovering a plugin is distinct from enabling it, configuring its source and showing its card. At most four plugin cards are visible; all ten can be connected and previewed in the Hub.

Native modules ship with Still and normalize vendor data into typed StillNativePlugins payloads. The workspace CLI installs versioned manifests/configuration; it does not download or execute arbitrary source code. Unknown native IDs cannot add executable adapters. A new native plugin requires code review and rebuilding the host. The external declarative v1 .stillplugin protocol remains supported and distinct; native catalog/configuration and Task Watch receipts use version 2 and are not a breaking reinterpretation of v1 facts.

## Trade-offs

Compiled modules provide native rendering, bounded source reads and host-controlled consent without a dynamically loaded binary/plugin runner. Manifest installation alone cannot provide a missing module or isolate executable code. npm/remote catalog publication, signature verification, marketplace delivery and arbitrary community execution remain future distribution work.

GitHub/Vercel read narrowly selected resources using separately authenticated installed CLIs. Tokens are not copied. Calendar requires explicit EventKit access and a selected calendar. Spotify requires explicit Automation consent; a bundled read-only native helper isolates blocking Apple-event calls with an owned process timeout. Automatic startup does not request permissions or start playback. Task Watch observes explicitly wrapped commands only and never receives stdout/stderr or command text.

Open-Meteo is the local evaluation weather source, with attribution. Its free endpoint is non-commercial; a commercial product needs a licensed provider/endpoint before release. No persistent sleep/security settings change, and these plugins do not change Still's privacy-curtain/security-lock boundary.
