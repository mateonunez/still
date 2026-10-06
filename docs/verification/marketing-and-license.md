# Marketing and MIT evidence

2026-10-06. Local source changes; no native release or remote website delivery in this phase.

## Delivered locally

Canonical brand line, edited README/banner, CONTRIBUTING, MIT LICENSE, third-party notices and package metadata. Product-led landing with a three-step workflow and native HTML FAQ disclosures. Availability/support copy, social/search descriptors, public `/license`, SDK license copies and human/agent resources updated. The source repository remains private; no fake install, signup or purchase action exists.

## Checks

| Area | Result | Boundary |
| --- | --- | --- |
| Biome | 71 files passed, no warnings after refinement | Source formatting/static lint |
| TypeScript | Passed | Type consistency only |
| Next.js | Webpack production build passed, 28 generated routes | No deployment; local development build remains noindex |
| SEO/SDK inspection | 19 content pages passed: unique H1/title, canonical, noindex, sitemap, catalog, agent guide and license copies | Offline built HTML, not served headers or crawler indexing |
| Share image | PNG 1200×630 check passed | No platform share-card cache acceptance |
| Palette | 46 flat role pairs passed | Composite/material contrast not established |
| License | Public text and SDK/LICENSE match root LICENSE | Font notices retained separately |
| Native builder | Syntax checked; root license copy added | Existing Still-polish app not rebuilt or replaced |

The normal workspace checks and generated SDK assets were used. No new lint/test framework or runtime dependency was introduced. The extra license route is included in the single existing sitemap; preview remains excluded.

## Accessibility and visual limits

Source review retains visible focus, skip navigation, native buttons/links, pressed-state labels for preview controls, reduced-motion handling and one H1 per route. The illustrative clock tagline is text rather than a redundant section heading. New workflow content is a semantic ordered list, and FAQ disclosures use native `details`/`summary`, without custom keyboard handling. Licensing text wraps at small widths.

The owned HTTP server could not start in this execution environment. The in-app browser was unavailable; Chrome then explicitly rejected navigation to the local `file://` review artifact. No alternate browser route was used to bypass that rejection. Keyboard, responsive layout, actual preview hydration and screen-reader behavior have not been accepted in a served browser session.

`out/verification/marketing/home-review.html` contains the actual generated home markup with embedded styles/fonts and disabled theme buttons. It is an ignored static review artifact, not a live site or native screenshot. It can be reviewed manually; interactions require the served Next.js app.

## Remote delivery

The initial local verification was completed before remote delivery was available. Repository delivery is a separate operation; it does not publish a native release or certify browser interaction. Signing/account setup remains final-phase work. See the [GitHub Releases guide](../guides/github-releases.md) for experimental hosting and the Developer ID boundary. Repository visibility remains private.
