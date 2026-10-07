# Delivery and channel audit

2026-10-07. Checked source `0dd956dd46b65581cf3ae263746a7f8e0cacc6e6`. This is a source/delivery/channel audit, not complete native acceptance.

## Verified delivery

| Area | Observation | Evidence |
| --- | --- | --- |
| CI | Website and native-domain jobs passed, including lint, CLI tests, contrast, type/build, website verifier, four Swift packages, starter validation and native app build/tests | [CI run](https://github.com/mateonunez/still/actions/runs/37606590603) |
| Repository | Public, MIT, personal ownership, canonical homepage and accurate topics | [Repository](https://github.com/mateonunez/still) |
| Website | Production Ready; all 20 canonical routes, index/follow, sitemap and share-image checks passed again | `out/verification/delivery-channel-audit/website.json`; Vercel production `still-mhdujw4xa-mmateonunez.vercel.app` |
| Public preview | Non-draft prerelease; fresh ZIP downloaded and SHA-256 matched the website/release digest | [Preview.2](https://github.com/mateonunez/still/releases/tag/v0.1.0-preview.2) |
| Archive | Main app and three helpers contain arm64 and x86_64; deep/strict signature verification passed; ad-hoc, no Team ID | Ignored downloaded archive under `out/verification/delivery-channel-audit/` |
| Current local candidate | Manifest hash verified for Still-review, built from `203c0a7`; native sources unchanged between that commit and audited main | Candidate resolver and native-path diff |
| Blog | Public article returned successfully on a fresh HTTP request | [Article](https://mateonunez.co/blog/still-a-little-space-to-step-away/) |
| X | Main post and limitation/blog follow-up visible in logged-in Chrome; artwork ALT and AI disclosure present; one positive public reply visible | [Thread](https://x.com/mmateonunez/status/2107754726720761864); ignored `x-thread.png` |

Downloaded preview SHA-256: `fc97c7dd674fdbe39bca3c5cb9b419a064af2e29a85673aca9a0036b1e62f002`. The native release source is `5927a19cd73dea120e4521fc4464f1222574b3c1`; local candidate executable SHA-256 is `4eee2da374398b47777364754a4c703a58a3603e9be9789b7a3d017e5ea4383e`.

## Material gap: public artifact versus current editor

The published preview does not contain the new continuous-guide, anchored-resize and drop-only Grid changes. There are 16 commits between its source and audited main; most are documentation/website work, but the native-path diff confirms the editor changes. A broad demo should pair actual behavior with an updated semantic preview rather than suggest that source-only improvements are already in the public ZIP.

No release tag, source version or owner app was changed by this audit. The downloaded archive was not launched. A clean-Mac installation, Gatekeeper/recovery, native permission flows, keyboard/VoiceOver, gestures during activation/password, multi-display transitions and awake endurance remain open. The owner's improved-editor feedback is not a pass for all of them.

The repository marketplace is a researched/proposed contract and an implementation issue. Remote discovery/install, published npx, upgrades and richer imported configuration are not delivered. The existing local v1 SDK and compiled native collection remain separate. No platform listing/submission is claimed.

## Communication checks

The existing 16-second showcase is an offscreen-view sequence, not a live interaction recording. Keep that provenance in campaign copy. X observations demonstrate publication and a public reaction; they do not establish conversions or a successful installation. Search structure checks do not establish Google indexing or ranking. Analytics dashboard delivery was previously owner-reported; no live traffic/conversion report was accessed in this audit.

The live home page retained the canonical `https://meet-still.app`, current planned-roadmap wording and the production Analytics script. Script presence does not prove accepted intake or dashboard reporting. The X thread showed 65 views, one like and two replies at observation, including its own follow-up; these transient counts are not installation evidence.

Current r/macapps rules and its approval instructions were inspected in Chrome while logged out. The rules require local community karma, appropriate developer promotion eligibility/template, affiliation disclosure, approved post access, official distribution links, no shortened/referral links and limited promotion frequency. Account eligibility/approval remains unknown; no account was accessed or post submitted. [Rules](https://www.reddit.com/r/macapps/about/rules/), [approval instructions](https://www.reddit.com/r/macapps/comments/1smg62t/how_to_gain_post_approval_in_rmacapps_with_read/).

[Additional channel research](../research/additional-launch-channels.md) and [collaboration guide](../guides/launch-collaboration.md) distinguish platform requirements, recommendations and joint actions. No new campaign messages, comments, listings or registrations were sent.

## Documentation corrections

The hosting guide now distinguishes available experimental downloads from pending signed distribution. The launch kit no longer says no social messages have been sent: blog/X publication is documented separately, while HN/PH/hub submissions remain pending. Historical website-plan foundations are retained with a current-state note rather than presented as present availability.
