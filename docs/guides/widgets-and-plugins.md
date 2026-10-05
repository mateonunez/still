# Widgets and plugins

Status: first-party native Codex and Claude quota widgets are available in the local development app. Community plugin installation and marketplace are not available.

## Native app

Build with `scripts/build-macos.sh debug Still-preview`, then install with `scripts/install-macos-local.sh`. Quit any older preview yourself before ordinary use. Launch the app through macOS:

```sh
open ~/Applications/Still.app --args --widgets
```

The menu's **Customize…** opens the Hub after returning to the desktop. Choose **Quiet corner** or **Side rail**. Connect sources individually; connection does not expose conversations or agent approvals. The native app never substitutes demonstration data.

**Connect Codex** uses your already-installed, already-authenticated Codex CLI. **Choose Codex executable…** selects it if automatic discovery fails. Account quota is distinct from task progress; the source's actual time window and reset are shown. Refresh is limited to once per minute. Sign in through Codex itself when needed.

**Connect Claude** installs a bundled native status-line bridge in Claude Code settings. It preserves your existing command and options and retains a private backup in `~/Library/Application Support/Still`. Continue normal Claude work; the next supported quota update supplies the card. Claude Code 2.1.80+ and account quota support are required. **Disconnect Claude** restores the previous status line only if it still belongs to Still; if another tool edited it, resolve the conflict rather than overwriting that change.

Missing or stale data is shown as unavailable. Refreshing retained, unchanged Claude status-line data does not prove a fresh account fetch. No Mac password is collected by widgets; return remains system-owned authentication.

## Design preview

Run `pnpm dev` and open `/preview?view=widgets&theme=porcelain&appearance=light`. The prepared loopback preview uses [port 3018](http://127.0.0.1:3018/preview?view=widgets&theme=porcelain&appearance=light).

Add Codex and Claude independently, compare layouts and Light/Dark/System, and select each provider's sample state. Browser values and identities are fictional and labelled Demo. Return is simulated. Choices live in memory; no source access or credentials are stored. The preview remains noindex and unavailable in production.

Developers: start with the [plugin authoring guide](plugin-development.md).

See [native evidence](../verification/native-live-widgets.md), [extension proposal](../plugins-and-widgets.md) and [roadmap](../roadmap.md).
