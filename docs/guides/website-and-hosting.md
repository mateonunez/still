# Website and hosting

The code repository is public: https://github.com/mateonunez/still. The intended public website is https://meet-still.app. Vercel project: https://vercel.com/mmateonunez/still, root apps/website, Node 24. The production site and preview downloads are public; Vercel preview environments remain noindex.

From the workspace root:

```sh
pnpm install --frozen-lockfile
pnpm dev
pnpm check
pnpm build
pnpm typecheck
```

The project-local .npmrc uses the public npm registry. Local Vercel link/environment files, build outputs, screenshots and app binaries stay ignored.

## Content and SEO

Route copy lives in apps/website/src/app and presentation in features/home or features/support. Metadata is composed in src/content/site.ts. The canonical origin is meet-still.app; update visible text, metadata and the sitemap's editorial date together when content changes. Use one H1 per page. Keep custom domains for preview deployments noindex as well as default Vercel preview URLs. Never add fake ratings, offers or availability to structured data.

Generate tokens from design/tokens.json with node scripts/generate-website-tokens.mjs. The website build runs this too. Keep font licenses under public/fonts and the original provenance records. No font CDN is used.

The home preview is an interactive illustration, not a screenshot or a security lock. Keep the native Mission Control/desktop-transition limitation visible in support/how-it-works until verified fixed. Awake controls remain hidden; do not advertise their retained implementation as a current feature.

## Delivery and ownership

Pushes to main should create production builds after the Git integration is verified; pull requests create previews. Check Vercel/CI status and live HTTP before calling delivery successful. Domain/TLS, www redirect, canonical tags, social card, robots and sitemap require actual checks.

Search Console setup was reported complete on 2026-10-04. Inspect sitemap processing and page indexing in Search Console; production HTTP checks alone do not prove search inclusion. Indexing and ranking can take time and are not established by a passing build. Experimental ad-hoc preview downloads are public through GitHub Releases. Developer ID/notarized distribution, clean-Mac installation and the support matrix remain pending.

## Catalog and SDK build inputs

The website prebuild generates public metadata from `plugins/mateonunez`, copies schemas from `schemas` and starters from `examples/plugins`. Include these canonical sources in Vercel uploads; generated public copies alone do not satisfy prebuild. `node scripts/verify-site-server.mjs` checks an owned local production server. Production requires `node scripts/verify-website.mjs https://meet-still.app --indexable`; omit the indexable flag for previews.
