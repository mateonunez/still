# Website dependency security update

Verified locally on 2026-11-12, macOS arm64, Node 24.19.0 and pnpm 10.32.1. Candidate is based on `d97461b39bb669f026bcbaea43661087ae5ece7d`.

## Change

Update only the website's Next.js direct pin from 16.3.8 to 16.4.1 and its supported lockfile resolutions. React, native sources, content, styles, analytics and deployment configuration are unchanged.

## Evidence

All commands below completed with exit 0:

| Command | Meaningful result |
| --- | --- |
| `pnpm audit --prod --json` | Zero registry findings |
| `pnpm audit --json` | Zero registry findings |
| `pnpm check` | 81 files checked; no fixes |
| `pnpm typecheck` | Website TypeScript check passed |
| `pnpm check:brand` | Every existing light/dark contrast assertion passed |
| `pnpm --filter @mateonunez/still-plugins test` | 13 tests passed; zero failed/skipped |
| `pnpm build` | Next.js 16.4.1; 29 static pages generated |
| `node scripts/verify-site-server.mjs` | 20 routes, canonical metadata, single H1, preview noindex, sitemap and 1200x630 PNG verified |
| `git diff --check` | No whitespace errors |

The HTTP verifier owned its local server and terminated it after the check. Generated build outputs and runtime evidence are not committed.

## Acceptance boundary

This is local website evidence, not proof of production delivery, live provider behavior or native app release readiness. Swift/native interaction checks were not rerun because no native code changed. A clean dependency audit is not a general security certification.

After an approved merge, inspect the actual Vercel deployment and canonical alias, then run `node scripts/verify-website.mjs https://meet-still.app --indexable`. Preview/development noindex must remain explicit. No merge, production promotion, domain change or native release is part of this patch.
