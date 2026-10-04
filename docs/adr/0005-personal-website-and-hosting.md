# ADR 0005 — Personal website and hosting

2026-10-04. Accepted: private GitHub source, Vercel hosting and the canonical meet-still.app domain. Website deployment and native app distribution are separate deliverables.

- Repository: mateonunez/still, private, main. Bootstrap from the existing malock workspace.
- Vercel: personal mmateonunez/still; Next.js, root apps/website, Node 24, pnpm. Include source outside the root for canonical tokens and the generator. Package downloads use the public npm registry via project-local configuration.
- Website: App Router, strict TypeScript, Biome 2, Tailwind 4, Server Components and local licensed Instrument Serif/Inter. Client JavaScript is limited to the labelled Porcelain design preview.
- Domain: https://meet-still.app canonical; www redirects permanently to the apex. Preview/development metadata and response headers are noindex. Production content is indexable; visibility in search is not promised.
- Initial routes: home, how-it-works, download/availability, privacy, support, changelog. No false download, email form, account, analytics, price, review or claim that known Mission Control exposure is solved.
- CI: website lint/build/types/token contrast and Swift domain tests. Native hardware acceptance and notarized app distribution are separate.

Source references and observed product patterns are in [website research](../research/website-seo-2026.md). Deployment receipts and actual HTTP observations belong to a verification report, not this architecture decision.
