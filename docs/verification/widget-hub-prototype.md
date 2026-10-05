# Customization Hub and Codex card — UI prototype evidence

Date: 2026-10-05. Status: local interactive browser prototype; design review pending.

## Deliverable

Porcelain Light/Dark/System, a compact Hub with a live miniature composition, and a larger curtain example. Two reviewable layouts: Quiet corner and Side rail. The default remains clock only; adding/removing Codex updates the preview. Source examples include quota/reset/freshness, stale, disconnected and illustrative approval attention. Account labels are fictional and opt-in. Return to Hub is simulated and restores keyboard focus to the surface selector. No data source, native widget, credentials, import flow or marketplace is implemented.

The prototype lives alongside the existing design preview in apps/website/src/features/design-preview/widget-prototype.tsx and widget-prototype.css. No dependency or runtime was added. Widget/source/disclosure choices are in memory; layout/surface are URL parameters. Development preview is available on loopback port 3018.

## Verification

- Biome check and TypeScript pass. The Next.js production build succeeds.
- Browser interaction confirms add/remove, both layouts, Light/Dark, sample source states, label disclosure, reset to clock only, and Hub/curtain return.
- Enter activates Add widget. Tab moves to the source selector with a solid visible focus outline. Surface changes move focus to the corresponding Hub/Curtain button.
- A 390 × 844 viewport reports document width 390 with one h1; no horizontal overflow was observed. Browser viewport override was reset afterward.
- All 26 canonical palette contrast pairs pass; this is palette evidence, not a full contrast audit of every composited browser surface.
- Local production-mode /preview?view=widgets returns 404 with X-Robots-Tag: noindex, nofollow. The six public route/metadata/sitemap/share-image verifier passes against that local build. No remote deployment was performed.
- A clean browser reload followed by add/curtain/return produced no new captured error logs. Earlier Fast Refresh during a ref-shape change produced a transient null-ref error; clean-mount interaction was checked separately. The final source uses a keyed ref map.

Screenshots are ignored local artifacts under out/verification/widget-prototype: hub-light.png, hub-dark.png, curtain-light-corner.png, curtain-dark-corner.png, curtain-dark-rail.png, curtain-dark-attention.png and hub-narrow.png. production-guard.json records the local production boundary check.

## Design recommendation and next proof

Quiet corner keeps the clock centered and gives metadata less visual weight. Side rail remains an alternative, especially for larger displays. Neither direction is accepted yet. Review the interaction and hierarchy before implementing the versioned fixture-to-native-card path.

Native glass/VoiceOver, multiple displays, Touch ID, actual Codex usage and approval awareness remain unverified. No native source changed during this UI phase. Trackpad coverage remains an independent open issue. The protocol proposal is still a proposal, not a validated community SDK.

See [the preview guide](../guides/widgets-and-plugins.md) and [the architecture proposal](../plugins-and-widgets.md).

## Subsequent checkpoint

The preview now has independent Codex and Claude demonstration cards. Real native adapters were implemented separately afterward; the limitations above describe this original UI-only checkpoint. See [native live evidence](native-live-widgets.md) for current source, installation and window-polish results.
