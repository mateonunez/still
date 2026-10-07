# Landing and analytics verification

Date: 2026-10-07. Implementation commit: `3bdb40c169d16f1b41b38e7bfc55514292013f24`.

## Passing evidence

- Personal Vercel project API: `still`, owner `team_8jJ87DQISczBkRL145ER3Fc0`, Web Analytics has `enabledAt`. No employer service or identifier reused.
- Production deployment `dpl_GSk1zRSeKDYsakDiRsoUPgPJAhNb` Ready, aliased to https://meet-still.app.
- Biome 76 files, TypeScript, full Next.js production build and 46 token contrast checks passed. [CI run](https://github.com/mateonunez/still/actions/runs/37600159776) succeeded.
- Public HTTP/SEO verifier passed all 19 canonical sitemap pages, one H1 each and indexable production metadata; the local design route stays excluded.
- Live browser DOM confirms Vercel Analytics SDK 2.0.1 script with generated script/intake paths, and all four native gallery images load. Captured console errors were empty.
- Desktop screenshot inspected. At 390×844 mobile, client width and scroll width are both 390; gallery is one column and images have descriptive alt text. Temporary viewport reset after checking.
- Existing captions/transcript and no autoplay retained. Gallery uses native links, figures and headings, no new custom keyboard interactions. Full VoiceOver acceptance was not performed.

Local screenshots: `out/verification/marketing/native-gallery-desktop.png` and `native-gallery-mobile.png`.

## Open evidence

Production home and download were visited normally in the browser. Script presence is verified; accepted event delivery and dashboard reporting are not. The connected browser reached Vercel login, so dashboard data requires the owner's personal session. Do not claim visitors or conversions until observed. Existing content blockers were not changed.

No native hardware, authentication, prolonged awake or clean-install acceptance inferred from website checks. No automatic updates or community marketplace implemented in this phase.
