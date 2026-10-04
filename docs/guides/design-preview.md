# Next.js design preview

Requirements: Node 24 and pnpm. The preview uses the same workspace and Next.js app as the website.

```sh
pnpm dev
```

Open http://127.0.0.1:3000/preview. Choose Porcelain, Spectrum or Meadow; Screen, Settings or Website; and Porcelain Light, Dark or System. Selections are shareable through query parameters. Unknown values fall back to Porcelain/Screen/Light.

Preview return/cover is simulated. It moves focus to the next action without collecting credentials. Sample activity sharing starts off. Changing inactivity never changes real system settings. Awake controls are hidden while their product model is refined.

For a local production-build check:

```sh
pnpm build
STILL_DESIGN_PREVIEW=true pnpm --filter @still/website start
```

Without that flag, production builds return 404 for `/preview`; Vercel production always returns 404 even if the flag is enabled. Preview metadata/headers are noindex and it is never in the public sitemap. Public page URLs remain unchanged.

## Verification

```sh
pnpm check
pnpm build
pnpm typecheck
pnpm check:brand
node scripts/verify-website.mjs https://meet-still.app --indexable
```

Native structural and IOKit verifiers also use Node:

```sh
node scripts/verify-native-runtime.mjs --app Still-preview
node scripts/verify-native-energy.mjs
```

These native probes own their subprocesses and never obtain passwords or prove trackpad/desktop coverage. Prior reports contain historical Python invocations; current verification commands above replace that tooling without changing those historical receipts.
