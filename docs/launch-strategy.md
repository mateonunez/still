# Still — brand, website, and launch strategy

Prepared 2026-10-04; updated 2026-10-06. First-party references are listed beside claims. Positioning, channels and experiments below are proposals, not established market evidence. Use the [brand/copy contract](marketing/brand-and-copy.md) and [launch kit](marketing/launch-kit.md) for current materials.

## Positioning

Category: native Mac ambient-screen and keep-awake utility.

Brand line: “A little space to step away.”

Supporting copy: “Cover your desktop. Keep your Mac awake. Bring only the details you want into view.”

Primary audience hypothesis: people who leave their own desk while long tasks run. Lead with the visible benefit and a ten-second authentic demo. Explain the privacy-curtain boundary close to the feature, rather than burying it in legal copy. Avoid promises of uninterrupted execution, security equivalent to macOS, invented Face ID support, fabricated testimonials, or unsupported job progress.

## Competitive baseline

Amphetamine already offers manual/timed wake sessions, triggers, optional display sleep, and advanced behaviors. Our proposed differentiation is the quality and simplicity of the away screen and its return experience, not the invention of keep-awake. [Developer's App Store listing](https://apps.apple.com/us/app/amphetamine/id937984704).

Caffeine's current release notes mention adjustments for macOS Tahoe, reinforcing that power behavior needs version-specific maintenance. This is evidence about that utility, not proof that our implementation works. [Caffeine release notes](https://intelliscapesolutions.com/apps/caffeine/releasenotes).

Before positioning as a replacement, interview users and compare our actual workflows with the utility they use. Do not promise advanced closed-lid behavior in the first version.

## Website composition

1. Hero: outcome headline, actual product preview, one primary CTA.
2. Three short benefits: a calmer screen, understandable awake sessions, deliberate activity visibility.
3. Live theme preview: match the shipping app, label concept imagery until shipping exists.
4. Three-step workflow: configure → cover → authenticate and return.
5. Plain-language security, energy, hardware, and activity limitations.
6. Compatibility, privacy, support and release notes.
7. Beta CTA before release; download/buy only when an actual build and price exist.

Supporting pages: /how-it-works, /themes, /privacy, /support, /changelog, and an evidence-backed comparison page. Do not publish boilerplate security claims or comparison tables before native validation. The current prototype contains a local landing concept; its CTA collects nothing.

## Contemporary discovery and marketing

Build fast, accessible, crawlable HTML with clear headings, useful screenshots, descriptive metadata, canonical URLs and a sitemap. Keep essential explanation in readable text. Structured data must describe real visible content; no invented ratings or offers. Google says established SEO practices apply to AI Overviews/AI Mode and that special AI files or special schema are not required. Treat AI-search visibility as discoverability work, not a guaranteed growth channel. [Google Search Central](https://developers.google.com/search/docs/appearance/ai-features).

Start with founder-led demos and communities where the workflow matters: Mac utility users, developers running builds, and creators running exports. Use specific short examples once measured on real hardware. Turn actual support questions into concise documentation. Prepare an opt-in beta for end users; roll out against observed compatibility and actual support capacity rather than an arbitrary tester-count cap.

Product Hunt is a possible later launch channel. Its first-party guidance emphasizes a clear product story/demo and feedback; no ranking or sales forecast is inferred from it. [Launch preparation](https://www.producthunt.com/launch/preparing-for-launch).

Distribution and marketing are website-led. Use the actual signed release and install evidence in public assets; App Store listing tools are outside the selected route.

## Selected distribution direction

Selected a native app distributed directly, outside the Mac App Store. Prepare signed/notarized DMG or ZIP download, then evaluate an owned Homebrew tap and terminal download instructions. No usable package command or hosted artifact exists yet. The website uses Next.js App Router with typed metadata and semantic design tokens. See [distribution](distribution.md) and [website plan](website-plan.md). Apple documents Developer ID signing and notarization for direct distribution. [Developer ID](https://developer.apple.com/developer-id/), [notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

## License and commercial decisions

Original code and documentation are MIT licensed as selected on 2026-10-06. Preserve notices in SDK assets and packaged apps; font licenses remain separate. Source repository visibility stays private during development. No payment, subscription or license-enforcement flow is implemented. Any future paid distribution or original collections require a separate decision and must respect the MIT grant and third-party terms.

## Measurement

Proposed funnel: qualified visit → product exploration → beta availability → installation → first successful cover/return → repeat use → useful feedback. Beta participants are end users. Learn across actual task types and tested OS/hardware; there is no fixed small-cohort limit and no statistical conversion claim.

Track feedback on confusing controls, permission refusal, authentication failure, power-policy mismatch, missed activity expectations, and theme choice. Local activity content must never enter marketing analytics. Decide on analytics consent and retention before production instrumentation. Use real repeat usage as the adoption signal; do not optimize for launch votes alone.

## Launch gates

- Working name Still, burgundy Porcelain fundamentals, and subsequent domain/name clearance.
- Native feasibility matrix and verified representative workflows.
- Accessible final UI, artwork provenance, permission and privacy documentation.
- Signed installable beta, reliable update/recovery instructions, support contact.
- Honest screenshots/demo from the release candidate.
- MIT license notices; open decisions on price, release hosting and future update mechanisms. Repository visibility remains private.
- Publication and release approval after a concrete candidate is reviewable.
