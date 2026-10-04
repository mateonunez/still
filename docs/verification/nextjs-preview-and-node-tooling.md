# Next.js preview and Node tooling evidence

2026-10-04. Status: migrated and locally verified. The native trackpad coverage issue remains open.

## Delivered

- Existing Next.js app now serves `/preview` with typed React state, scoped CSS, canonical burgundy tokens and local fonts. Porcelain light/dark/system, Spectrum and Meadow remain available, with screen/settings/illustrative website views and shareable query parameters.
- Public pages moved into a route group to retain website chrome separately. Their six URLs, metadata and sitemap entries remain unchanged.
- Legacy HTML/CSS server and Python verification scripts were removed. Current tools use Node core APIs. Licensed source fonts moved to design/fonts; every manifest hash is unchanged, and the native builder packages them from that path.
- Local previews are noindex and excluded from the sitemap. Default production builds return 404; Vercel production returns 404 even if STILL_DESIGN_PREVIEW is enabled. No agent permissions or real activity sources are activated by a visual preview.

## Verification

```sh
pnpm check
pnpm build
pnpm typecheck
pnpm check:brand
node scripts/verify-website.mjs https://meet-still.app --indexable
node scripts/verify-website.mjs http://127.0.0.1:3017
./scripts/build-macos.sh debug Still
node scripts/verify-native-runtime.mjs --app Still-preview --output out/verification/nextjs-migration/native
node scripts/verify-native-energy.mjs --output out/verification/nextjs-migration/energy
```

Build, TypeScript, Biome and all 26 canonical contrast pairs pass. Both served website probes pass: six distinct descriptions, one H1 per public page, correct canonical/share metadata, six sitemap routes, expected robots behavior and a real 1200x630 PNG.

Default production `/preview` returned 404/noindex. Explicitly enabled local preview returned 200/noindex. A server with VERCEL_ENV=production and STILL_DESIGN_PREVIEW=true still returned 404/noindex.

The native builder passed with the relocated fonts. Its executable and the tested Still-preview candidate both hash to `a3de2013513d26b30982696325e012627f069221ee3b749f70395b7b9ff8dddd`. The Node structural probe passed 8 checks; synthetic work progressed 140905 → 2026814 → 2399898. The Node energy probe passed 11 checks, including owned pmset system/display requests and timeout release. Probes terminated only their own subprocesses; these are not gesture, authentication or sleep-timing acceptance.

Tool failure-path checks passed for output confinement, symlink escape, subprocess timeout, oversized stdout, missing executable and invalid UTF-8. No third-party process names were retained in normalized energy receipts.

Live Chrome verification confirmed the dark query deep link, actual background rgb(32,23,27), loaded fonts, Light/Dark selection, System matching the current media query, all three themes, preserved Meadow SVG, sample-app disclosure and simulated return/cover focus. Background controls become inert during return; its visible heading is H1. Keyboard Space changed automatic cover, the idle select updated the state label, and the website CTA announced that enrollment is unavailable. Skip to content focused main. At a 320px viewport, document width remained 320px for Porcelain, Spectrum and Meadow; the viewport override was reset. This is a focused check, not full VoiceOver/WCAG certification.

Screenshot and fresh receipts remain ignored under out/verification/nextjs-migration. The screenshot is a browser-rendered design preview, not native macOS proof.

## Corrections and limits

The first production build encountered stale .next/dev validators referring to moved routes. The owned dev server was stopped, generated .next data was cleared and the exact build passed. Next.js automatic agent-rule file generation is disabled. Original font/license bytes were preserved.

Historical verification reports retain their original Python invocations with links to the replacement Node tools. Current development requires Node/pnpm and Xcode/Swift. No native gesture-blocking behavior was added; see the [trackpad finding](native-trackpad-coverage.md) and [manual acceptance guide](../guides/desktop-coverage.md).
