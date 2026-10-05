# Still domain context

Still is a personal native macOS privacy curtain in development. Porcelain is the initial light/dark theme. A curtain visually covers the desktop; it does not provide the macOS security lock's guarantees. Return uses system-owned Touch ID or Mac-password authentication. Inactivity means elapsed time since input, never recorded input contents.

An active curtain automatically prevents idle system sleep until return, suspension or quit. The curtain-owned display assertion also prevents idle display sleep; explicit sleep and OS overrides remain available. Independent timed awake controls remain retained and hidden. First-party opt-in Codex and Claude account-quota widgets and a native customization Hub are implemented locally. StillPluginKit v1 provides declarative local import, explicitly connected metadata sources, constrained templates and host-rendered cards. Optional native hooks project advisory agent activity; no authoritative pending approvals or decisions. Theme collections and a hosted marketplace remain future scope. A design preview is an illustration, not native runtime or compatibility evidence.

The public website origin is https://meet-still.app. The code repository is private under mateonunez. Next.js serves product/support content; macOS uses SwiftUI/AppKit. Public website delivery does not release the development app.

## Extension vocabulary

- Native collection: reviewed, compiled first-party plugins owned by mateonunez, with per-plugin configuration and source consent.
- Agents: one plugin grouping discovered supported clients and their independently configured quota/activity sources.
- Installed: a known native module has local catalog/configuration metadata; no source access is implied.
- Enabled: Still may read configured sources; OS grants and external client authentication remain separate.
- Visible: a visible plugin has a curtain card; available display space governs fit; hidden enabled sources remain previewable in the Hub.
- Task Watch: status of commands explicitly registered by the caller, without command output or automatic process discovery.

- Widget: host-rendered typed fact card; no global four-card visibility limit.
- Template: approved Porcelain composition, never a source grant.
- Local metadata connection: host-issued UUID granting consumption of declared snapshot facts; not external-process permissions.
- Attention requested: expiring advisory event, not an authoritative pending approval.
- Sample: explicitly marked fixture, never live fallback.
- Revocation: clear host data/connection and reject the old identity.
