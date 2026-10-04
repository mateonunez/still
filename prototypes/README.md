# Design preview archive

The HTML prototype has been migrated to the existing Next.js app. This directory retains design-review notes only; there is no standalone server or Python dependency.

```sh
pnpm dev
```

Open http://127.0.0.1:3000/preview. Deep links preserve the existing selections:

- `/preview?theme=porcelain&view=screen&appearance=light`
- `/preview?theme=porcelain&view=screen&appearance=dark`
- `/preview?theme=spectrum&view=screen`
- `/preview?theme=meadow&view=settings`

Porcelain, Spectrum and Meadow remain available. Screen, settings and illustrative website views use React state. Return/cover, sample app disclosure and inactivity controls are simulations. Awake controls remain hidden pending concept refinement, matching current native availability.

The route is noindex, excluded from the sitemap and disabled in production. It runs in development; a local production build can expose it with `STILL_DESIGN_PREVIEW=true`. It never performs authentication, reads activities, changes energy preferences or collects passwords. It does not prove native coverage or compatibility.

Fonts and licenses now live in [design/fonts](../design/fonts/manifest.json). The original Meadow illustration is preserved as a local SVG asset. See the [preview guide](../docs/guides/design-preview.md).
