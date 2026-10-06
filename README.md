<p align="center">
  <img src="design/still-banner.svg" alt="Still — A little space to step away." width="100%" />
</p>

# Still

**A calm screen for a working Mac.**

Cover your desktop. Keep your Mac awake. Bring only the details you want into view.

[Meet Still](https://meet-still.app) · [Native plugins](https://meet-still.app/plugins) · [Developer SDK](https://meet-still.app/developers) · [MIT license](LICENSE)

**Experimental preview.** [0.1.0-preview.2](https://github.com/mateonunez/still/releases/tag/v0.1.0-preview.2) provides a universal Mac archive, checksum and known limits. It is ad-hoc signed, not Developer ID signed or notarized. The repository remains private; download access follows repository access. No public native download, published npm package or working Homebrew install command exists yet. [Preview release guide](docs/guides/github-releases.md)

## Your kind of quiet

- **Porcelain and Glass.** Two official themes, each in light and dark, with licensed local fonts and native controls.
- **A screen you compose.** Arrange the clock and widgets in adaptive Grid or continuous Free layout. Save your composition.
- **Ten optional native plugins.** Agents (Codex and Claude), Build Watch, Deploy Watch, Task Watch, Mac Pulse, Next Up, World Clock, Quiet Timer, Weather and Spotify. Every source has its own configuration.
- **An intentional return.** System-owned Touch ID where available, with Mac-password fallback in the macOS dialog.
- **Keep-awake while covered.** Activate from the menu bar or after inactivity. Still releases its owned request on return or suspension; explicit sleep remains available.
- **A foundation for builders.** Versioned declarative metadata and template contracts, starter resources and human/agent guides. Imported packages never execute code inside Still.

Still is a visual privacy curtain, not the macOS security lock. Desktop gestures can expose windows in the development candidate. It does not pause apps itself or guarantee progress in every task. Use the system lock when you need to secure your session. [Behavior and limitations](docs/guides/pre-release-native-checks.md)

## Run locally

Requires Node 24, pnpm and Xcode/Swift for the native app.

```sh
./scripts/build-macos.sh debug Still-polish
open "$(node scripts/native-candidate.mjs --path)"
```

Quit other Still instances before opening a candidate. This builds an ad-hoc development `.app`, not a signed/notarized beta. [Native guide](docs/guides/native-preview.md) · [Exact-candidate handoff](docs/guides/beta-handoff.md)

For the Next.js website and local design illustrations:

```sh
pnpm install
pnpm dev
```

Visit `http://127.0.0.1:3000`. The local `/preview` illustrates designs with sample data; it is noindex and unavailable in production. Native UI and the browser illustration remain distinct.

## Build on Still

Start with the [plugin developer guide](docs/guides/plugin-development.md), [native collection](docs/guides/native-plugins.md) or [public SDK](https://meet-still.app/developers). The catalog documents built-in plugins; community publishing, remote installers and automatic updates are future work.

[Contributing](CONTRIBUTING.md) · [Developer practices](docs/development/practices.md) · [Architecture](docs/architecture.md) · [Roadmap](docs/roadmap.md)

## Verify

```sh
pnpm check
pnpm typecheck
pnpm check:brand
pnpm build
```

Source targets macOS 14+; Apple Silicon runtime checks and Intel cross-compilation are separate evidence. The final support matrix is not announced. [Compatibility research](docs/research/macos-compatibility.md) · [Verification reports](docs/verification/pre-beta-refinement.md)

## License and credits

Original code and documentation are [MIT licensed](LICENSE). Bundled Instrument Serif and Inter retain their SIL Open Font Licenses; preserve [third-party notices](THIRD_PARTY_NOTICES.md).

Made by [Mateo Nunez](https://mateonunez.co). Still is distributed directly; no Mac App Store release is planned.
