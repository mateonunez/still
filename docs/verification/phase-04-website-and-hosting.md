# Phase 4 — Website and hosting evidence

2026-10-04. Private GitHub source and Vercel hosting configured for meet-still.app. Website delivery is verified; native app release remains unavailable. Brand/layout manual acceptance and search indexing remain separate.

## Delivered

- Private [mateonunez/still](https://github.com/mateonunez/still), main, meaningful README, issue/PR templates and CI.
- Personal [mmateonunez/still](https://vercel.com/mmateonunez/still), Next.js root apps/website, Node 24, pnpm 10.32.1, outside-root source access for tokens/generator, public-registry frozen-lockfile install. GitHub link verified; main is the production branch. A real main push produced a READY Git deployment.
- [meet-still.app](https://meet-still.app) is HTTPS accessible. Domain was already purchased from Vercel with correct Vercel nameservers. Apex and www are verified; www redirects 308 to apex while preserving paths. Default still-sand.vercel.app is configured to redirect to the canonical origin too.
- Six server-rendered content routes: home, how-it-works, download/availability, privacy, support, changelog. Native-in-development copy, labelled interactive light/dark Porcelain design preview, burgundy tokens and licensed local fonts. No waitlist/account/payment/analytics or fake native download.
- Typed per-page metadata, WebSite JSON-LD, one native robots/sitemap implementation, local-font original 1200x630 share card, favicon, skip link and semantic native web controls. No fake prices/reviews or OS-lock/universal-task-continuity claims. Known Mission Control/trackpad limitations are visible in support and how-it-works.

## Artifact and delivery records

The deployment and CI records below describe the original website-delivery snapshots. Source history has since been rebuilt; these records are historical evidence, not current commit references.

- Git production deployment: `dpl_78BSUvhMsWvPFHgiMXzjwwSJX6dq`, READY, still-lrican698-mmateonunez.vercel.app. This establishes the Git integration actually delivered.
- CLI production verification deployment: `dpl_ArCeb4VdZfud9iFQwSHJ6LzSanHS`, READY, aliased to meet-still.app. CLI upload was 350.4KB/60 build files; env/native build/private evidence paths were excluded.
- Preview probe: `dpl_CFbNsVG7cAxRHx288U4Z12PbjF4r`, READY, still-52z7e2lhk-mmateonunez.vercel.app. Preview metadata/header were inspected using authenticated `vercel curl` without printing or retaining credential/cookie values.
- [Bootstrap CI](https://github.com/mateonunez/still/actions/runs/37225386336) and [upload-scope CI](https://github.com/mateonunez/still/actions/runs/37225436534) completed successfully: website and native-domain jobs.

The final closeout also lets crawlers read accessible previews' noindex headers/meta rather than relying on a robots crawl block. Its delivery is checked separately after the closeout push; earlier immutable deployments remain evidence for their respective content.

## Verified checks

```sh
pnpm install --force --registry=https://registry.npmjs.org/
pnpm check
pnpm build
pnpm typecheck
node scripts/check-contrast.mjs
python3 scripts/verify-website.py http://127.0.0.1:3016
python3 scripts/verify-website.py https://meet-still.app --indexable
```

Local build, types, Biome and canonical token contrast pass. All content routes and OG/robots/sitemap routes prerender. Project-local .npmrc and the lockfile use the public npm registry.

Production HTTP verifier passed all six pages: HTTP 200, one H1, unique descriptions, correct canonical/OG URLs, OG title/description, Twitter large-image card, index/follow without noindex header. Sitemap contains exactly the six canonical routes. The share image is a real PNG with 1200x630 IHDR dimensions. www/how-it-works returned 308 with Location https://meet-still.app/how-it-works; TLS validation used the default HTTPS verifier.

The preview probe observed noindex/nofollow in both HTML meta and X-Robots-Tag, with one H1 and the canonical production origin. Local preview checks also passed. Production remains indexable; preview rules are not claimed to be access control.

Live Chrome inspection verified desktop composition, one H1, loaded local fonts, and mobile width 393px with documentWidth393 (no horizontal overflow). Changing the preview to Light updated aria-pressed and actual computed background to rgb(244,239,235). Keyboard Tab moved between preview choices and, on the production page, reached the visible Skip to content link first. No ornamental animation; CSS smooth scrolling is gated by reduced-motion preference. This is a focused accessibility check, not a full VoiceOver/WCAG certification.

Production screenshot remains ignored at out/verification/phase04/landing-desktop.png. It captures the website, not native macOS operation. The browser was returned to its normal viewport and left on the actual production site for manual review.

## Corrections and remaining acceptance

Biome identified an invalid label on a generic element; the appearance choices now use a semantic fieldset. Style warnings were resolved rather than broadly disabling rules. The token generator now emits formatter-compatible lowercase hex, avoiding a rebuild/check mismatch. The HTTP probe initially treated the root URL's optional trailing slash as a failure; it now normalizes that equivalent root URL before comparison, and the exact command passed. Original licensed font text is preserved; its source whitespace is not a product-formatting failure.

Search Console ownership verification/sitemap submission, real indexing/rankings, field Core Web Vitals, complete screen-reader/accessibility testing and design acceptance are not established. No product-market/conversion claim follows from reading modern homepages. Native authentication, Mission Control/desktop gestures, signing/notarization, installability and app compatibility stay open in their respective reports.

See [primary-source research](../research/website-seo-2026.md), [accepted hosting architecture](../adr/0005-personal-website-and-hosting.md) and [user guide](../guides/website-and-hosting.md).
