# Still — website and discovery research

Research date: 2026-10-04. Scope: first-party documentation and current product homepages. These findings are implementation recommendations; they do not establish a deployment, search ranking or product release.

## Implementation principles

Use typed route content, centralized metadata, native Next.js robots/sitemap routes and accessible navigation. Keep editorial metadata grounded in visible product facts. Avoid fresh build timestamps for unchanged pages.

## Search in 2026

Google documents that AI Overviews and AI Mode use ordinary SEO fundamentals. Eligibility requires an indexed page eligible for a search snippet; discovery and inclusion are not guaranteed. Important information should exist as readable text, with internal links and structured data that matches visible content. Google requires no special AI file or AI-specific schema. **Recommendation:** spend effort on clear product explanations and evidence rather than adding `llms.txt` as an alleged ranking requirement. [Google AI features](https://developers.google.com/search/docs/appearance/ai-features)

Still should describe itself as a native Mac visual privacy curtain. Its purpose and limits must be visible near the product explanation: system-owned authentication, optional inactivity activation, ordinary macOS recovery and known Mission Control/Space-transition limitations. Avoid “secure lock screen replacement,” universal task-continuity promises, or hidden awake controls as an advertised feature. This positioning is a product judgment based on the current workspace, not a claim from Google.

Start with a useful home page, support/limitations, privacy and development updates. Add separate guide pages only when they answer a real question. Search-intent hypotheses include “Mac privacy screen,” “hide desktop while working” and “ambient screen for Mac”; no search-volume study has been performed.

## Metadata and structured data

Use Next.js App Router `Metadata` with a fixed production `metadataBase` of `https://meet-still.app`, a unique title/description and canonical for each real route, plus corresponding Open Graph and Twitter cards. Metadata fields are framework-supported; they are not ranking promises. Reuse licensed local fonts and keep body content server rendered. [Next.js metadata](https://nextjs.org/docs/app/api-reference/functions/generate-metadata)

Use one native `app/sitemap.ts` route, returning only existing canonical public pages. Keep last-modified values tied to actual editorial changes or omit them. Do not add a second sitemap plugin. [Next.js sitemap convention](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap)

A home-page `WebSite` JSON-LD entity can identify Still and its production URL. Google uses this markup as an input for site-name understanding; displayed naming remains Google's decision. [Google site names](https://developers.google.com/search/docs/appearance/site-names)

Google's SoftwareApplication rich result requires `name`, `offers.price` and a real rating or review. Still has no approved price, published release or collected reviews. **Recommendation:** do not fabricate any of these or claim rich-result eligibility. Minimal truthful product markup is separate from qualification for Google's app result; postponing SoftwareApplication is reasonable. [Google software-app requirements](https://developers.google.com/search/docs/appearance/structured-data/software-app)

## Vercel and domain behavior

Default Vercel preview URLs receive `X-Robots-Tag: noindex`. The documented exception is a custom domain attached to a non-production branch, where that automatic header is absent. **Recommendation:** explicitly set preview/development metadata and response headers to noindex, then inspect the live response rather than assuming Vercel covers every alias. [Vercel preview indexing](https://vercel.com/kb/guide/are-vercel-preview-deployment-indexed-by-search-engines)

Do not combine an effective noindex strategy with blocking all crawling and assume Google can read the rule: Google must access a resource to observe its noindex meta tag/header. Robots controls also do not make a private repository's deployed website private. Use deployment protection for restricted access. [Google noindex](https://developers.google.com/search/docs/crawling-indexing/block-indexing)

Use the production apex `meet-still.app` as the canonical origin; redirect `www` consistently if it is attached. Inspect Vercel's exact project/domain DNS recommendation instead of copying a generic IP/CNAME. DNS depends on the actual registrar/provider; certificate provisioning and HTTP checks are separate verification steps. Avoid transferring nameservers or replacing unrelated records merely to connect the site. [Vercel custom-domain setup](https://vercel.com/docs/domains/set-up-custom-domain)

## Contemporary first-party patterns

These are observed information-design patterns, not evidence of popularity or conversion performance:

| Reference | Observed pattern | Still adaptation |
| --- | --- | --- |
| [Raycast](https://www.raycast.com/) | Short outcome headline, explicit product category, concrete feature demonstrations, manuals and changelog | Lead with a calm outcome, then explain the native curtain in one sentence; demonstrate cover/return rather than listing infrastructure |
| [Linear](https://linear.app/) | Clear product category, illustrated workflow sections, concise benefit hierarchy and deeper feature links | Present configure → cover → return with editorial spacing; use a few purposeful sections rather than a generic card wall |
| [CleanShot](https://cleanshot.com/) | Explicit Mac-native identity, product capabilities paired with visuals, how-it-works path and feature/support depth | Make native macOS identity immediate; use verified app visuals when available, and label any design preview |

Keep Porcelain's burgundy palette, Instrument Serif and clean native-inspired composition. A restrained glass treatment on website navigation can echo the app, but it is a web aesthetic, not native macOS Liquid Glass. Avoid copying third-party artwork, quotes, ratings or customer logos.

## Concrete landing recommendation

Proposed headline: **A calmer screen for your Mac.**

Proposed description: **Still is a native Mac app that covers your desktop with a quiet, beautiful screen. Choose when it appears, then return with system authentication.**

Show **In development** beside the product identity. Before verified distribution, the primary CTA should lead to how-it-works/product exploration, not a nonexistent installer or unconnected waitlist form. Explain the OS-lock distinction and desktop-transition limitation in readable supporting copy. Awake controls and future agent/marketplace features stay outside the current feature promise.

Before declaring hosting ready, verify production HTTP status, TLS, apex/www behavior, canonical URLs, noindex differences, sitemap/robots responses and rendered social metadata. Inspect mobile/desktop layout, focus, reduced motion and readable text. Search Console verification and sitemap submission are a subsequent ownership step; indexing and rankings remain unproven.
