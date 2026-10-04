<p align="center">
  <img src="design/still-banner.svg" alt="Still — Step away. Keep the momentum." width="100%" />
</p>

# Still

A calm screen for your Mac, with optional inactivity activation.

**In development · Native macOS · Direct distribution · Next.js website**

[Meet Still](https://meet-still.app) · [Development field notes](https://meet-still.app/changelog)

Still creates a visual privacy curtain over the desktop. It does not replace the macOS security lock or guarantee that every third-party task continues processing. Porcelain is the initial design standard, with warm light/dark appearances and a burgundy identity. Agent awareness and future theme collections are follow-up scope.

## Try the native preview

```sh
./scripts/build-macos.sh
open out/Still.app
```

Manual curtain, Porcelain light/dark/system, a contextual menu and embedded Touch ID with system-password fallback are implemented. This is an ad-hoc signed development app; the authentication and desktop-mode acceptance checks remain open. See the [user guide](docs/guides/native-preview.md), [Phase 1 evidence](docs/verification/phase-01-native-curtain.md) and [interaction refinement](docs/verification/phase-01-interaction-refinement.md). The currently prepared candidate is `out/Still-preview.app`; quit the old running app before opening it.

The candidate includes optional inactivity activation, disabled initially. Awake/display controls are hidden while their product concept is reconsidered; the implementation and tests are retained. macOS 26 uses native Liquid Glass controls with a solid privacy curtain and accessibility fallbacks. Read the [inactivity guide](docs/guides/idle-and-energy.md) and [latest refinement](docs/verification/phase-02-deferred-awake-and-spaces.md). Mission Control and trackpad desktop transitions remain known coverage limitations.

## Explore the design

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory prototypes
```

Open [Porcelain Light](http://127.0.0.1:8765/?theme=porcelain&view=screen&appearance=light) or [Porcelain Dark](http://127.0.0.1:8765/?theme=porcelain&view=screen&appearance=dark). Switch appearance, inspect settings and preview the website. Other theme directions remain available for future collections.

This is a disposable browser prototype. Authentication, activity and energy are simulated. It never locks the Mac, changes power settings, or reads agent conversations. The production landing will use Next.js.

## Product and architecture

| Area | Direction | Current state |
| --- | --- | --- |
| Mac app | SwiftUI + AppKit, OS-owned authentication, scoped power controls | Local `.app` built; structural checks pass; native interaction acceptance pending |
| Appearance | Porcelain, burgundy, light/dark/system | Interactive design preview with local licensed fonts |
| Website | Next.js App Router, typed content/SEO, local fonts | Live on [meet-still.app](https://meet-still.app); GitHub-connected Vercel builds |
| Distribution | Signed/notarized app download; evaluate Homebrew cask | No release, hosted package or usable install command |
| Agents | Optional status, attention and usage metadata | Post-v1 plan |

## Workspace map

- [Development status](docs/development/README.md) · [developer practices](docs/development/practices.md)
- [Roadmap](docs/roadmap.md) · [Product strategy](docs/product-strategy.md) · [decisions](docs/decisions.md) · [architecture](docs/architecture.md)
- [Brand fundamentals](docs/brand-fundamentals.md) · [design contract](DESIGN.md) · [canonical tokens](design/tokens.json)
- [Native feasibility](docs/research/macos-feasibility.md) · [direct distribution](docs/distribution.md)
- [Next.js website plan](docs/website-plan.md) · [launch strategy](docs/launch-strategy.md)
- [Website/hosting guide](docs/guides/website-and-hosting.md) · [delivery evidence](docs/verification/phase-04-website-and-hosting.md)
- [Agent awareness](docs/agent-awareness.md) · [prototype notes](prototypes/NOTES.md)

## Verify the brand

```sh
node scripts/generate-brand-css.mjs
node scripts/check-contrast.mjs
```

Palette roles are checked from the source tokens. Bundled font files include licenses and [provenance hashes](prototypes/assets/fonts/manifest.json). No system-wide font installation or font CDN is needed.

## Project status

Source is private under [mateonunez/still](https://github.com/mateonunez/still). The public Next.js site is hosted by the personal [Vercel project](https://vercel.com/mmateonunez/still). Native acceptance, Developer ID signing, pricing and public app release remain separate steps. There is no App Store release planned.
