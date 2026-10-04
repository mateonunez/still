# Disposable design prototype

Question: which visual direction and information hierarchy best express a calm away screen?

Run from the workspace root:

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory prototypes
```

Open http://127.0.0.1:8765. Theme and page are also URL parameters: `?theme=spectrum&view=screen` or `?theme=meadow&view=landing`.

Compare Porcelain, Spectrum, and Meadow using the bottom concept bar. Use the top controls to inspect the screen, settings, and website. Activity disclosure and settings operate in memory. “Preview return” simulates successful authentication and provides a cover-again action. No biometric request, password collection, real activity observation, persistence, network submission, power assertion, or OS lock occurs.

Porcelain is the selected initial direction. Its Light, Dark, and System controls apply to the screen, settings, website, and simulated return. A direct dark preview is `http://127.0.0.1:8765/?theme=porcelain&view=screen&appearance=dark`. Other directions remain available for future collection exploration.

The illustration is original SVG. Approved fonts are bundled locally in `assets/fonts/` with licenses and a provenance/hash manifest. No external fonts, images, or runtime network dependencies are requested. The prototype is browser-rendered and does not establish native performance, window coverage, authentication layering, or macOS accessibility acceptance.

Decision: Still selected as the working name; Porcelain selected as the initial standard, with a burgundy light/dark direction. Preserve the accepted direction and replace or remove this prototype during native implementation.
