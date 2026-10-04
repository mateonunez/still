# Still — Next.js website plan

Decision: the landing uses Next.js. The current HTML prototype remains a disposable visual exploration; it is not the production website.

Delivery update, 2026-10-04: private GitHub source and Vercel hosting are configured for meet-still.app. The Next.js target is implemented, with six product content routes and a labelled design preview. See [ADR 0005](adr/0005-personal-website-and-hosting.md), [hosting guide](guides/website-and-hosting.md) and [actual delivery evidence](verification/phase-04-website-and-hosting.md). The proposal below records the foundation; no public app installer is available.

## Proposed implementation

Location: `apps/website/`, alongside `apps/macos/`. Use Next.js App Router with TypeScript and Server Components for content. Keep client code restricted to appearance selection, a theme preview and genuine interaction. Use pnpm, Node 24, Biome as the single formatter/linter, and Tailwind 4 with named semantic tokens. Pin compatible versions from the package registry when scaffolding; local reference versions are not an instruction to copy stale dependency pins.

Load approved local fonts through `next/font/local`. No browser request to a font CDN. Fonts and artwork keep their attribution/license records. Map `design/tokens.json` into the website's token layer; the design contract is independent of either framework.

```text
apps/website/src/
  app/                 # layout, routes, metadata, robots, sitemap, OG image
  features/home/       # hero, benefit sections, product preview, content
  features/download/   # verified release metadata and download options
  features/support/    # compatibility and installation guidance
  features/legal/      # approved privacy and terms copy
  content/             # brand facts, navigation, typed SEO entries
```

Do not install a CMS, auth system, payment provider, animation framework or analytics merely because the reference sites contain them. Select hosting later; Next.js does not imply a specific deployment provider.

## Information architecture and copy

Initial pages: `/`, `/how-it-works`, `/download`, `/privacy`, `/support`, `/changelog`. Keep themes within the home/product experience until a real collection justifies a separate page. Marketplace remains post-v1.

Home sequence: strong wordmark → outcome headline → honest product preview → three benefits → configure/cover/return loop → compatibility and limits → appropriate CTA.

Before a release, the site says “In development” and exposes a preview; no fake download or unconnected email form. After a verified release, the primary CTA downloads the current signed package, with version, OS requirement, architecture, file size and release notes available nearby. A Homebrew command appears only after the cask is actually installable.

## SEO and sharing contract

- One descriptive H1 per page, meaningful heading order and accessible landmarks.
- Unique title/description per route from a typed metadata helper; root `metadataBase` and canonical URLs use the actual owned production origin.
- Correct Open Graph/Twitter title, description, URL, image and alt text for the shared page. Prepare an original 1200 × 630 Still card.
- Native `app/robots.ts` and `app/sitemap.ts`; one sitemap implementation, no duplicate plugin. Include only canonical public routes; use honest last-modified dates.
- Preview environments get `noindex`; indexing is enabled only for the approved production site. Robots directives are not access control.
- Structured data describes visible, real facts. SoftwareApplication/WebSite may describe the product when appropriate; no invented offers, reviews, ratings, hardware support or published version.
- Important explanations remain server-rendered readable text. Avoid screenshot-only descriptions and unnecessary keyword repetition.
- No language alternates until real localized pages exist. Initial produced content is English.
- Optimized screenshots, stable layout, local fonts and minimal client JavaScript. Measure performance on the production build.

Next.js documents metadata and file-based OG/robots/sitemap conventions. [Metadata and OG](https://nextjs.org/docs/app/getting-started/metadata-and-og-images), [robots](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots), [sitemap](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap).

## Acceptance

Production build and type/lint gates pass. Inspect generated metadata/JSON-LD, HTTP robots and sitemap responses, share-image dimensions, canonical URLs, mobile layout, keyboard/focus and reduced motion. Validate real download targets and the install commands before showing them. Domain, public hosting and analytics/privacy choices remain separate decisions.
