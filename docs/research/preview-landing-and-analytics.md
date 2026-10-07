# Preview landing and analytics research

Reviewed 2026-10-07 against primary sources.

- [Vercel quickstart](https://vercel.com/docs/analytics/quickstart): Next.js integration belongs in the root layout; enable the project, deploy, then verify delivery. Still uses `@vercel/analytics/next` only when `VERCEL_ENV` is production.
- [Vercel privacy guidance](https://vercel.com/docs/analytics/privacy-policy) and [configuration](https://vercel.com/docs/analytics/package): aggregate visit measurement, temporary visitor hashing and URL redaction. Still's `beforeSend` removes URL search/hash. No custom events or native telemetry are introduced. The privacy page describes provider processing without claiming visits are invisible to the host.
- [Raycast's own landing page](https://www.raycast.com/): concrete tool use cases, an extension collection and product visuals make an extensible native product easier to understand. Inference for Still: show each official appearance and link to the existing native catalog/SDK. Do not copy testimonials or imply equivalent community adoption.
- [Apple's system-lock guide](https://support.apple.com/guide/mac-help/lock-the-screen-of-your-mac-mchl8e8b6a34/mac): system security belongs to macOS. Retain Still's visual-curtain boundary near installation and in the FAQ; don't position it as a replacement lock.

Applied: four-image responsive native gallery, clear export provenance, an evidence-based Now/Next/Then section and a link to the introduction article. Keep decorative concept art separate from product views. Next visual evidence should be real editor interaction and source setup, with privacy-safe data, rather than more variants of the same export.

Measurement plan: compare production landing, download and plugin-page visits and referring sites. These are browsing signals, not completed downloads, installs or native feature adoption. Use observed issue reports for those outcomes. Custom conversion events need a separate minimal data contract before adding them.
