# Still — brand and copy

Updated 2026-10-06. Product story and implementation reference, not evidence of released software or market demand.

## Message hierarchy

| Surface | Copy |
| --- | --- |
| Brand line | A little space to step away. |
| Product descriptor | A calm screen for a working Mac. |
| Search descriptor | A calm screen and keep-awake app for Mac. |
| Product explanation | Cover your desktop. Keep your Mac awake. Bring only the details you want into view. |
| Development status | Native macOS · MIT licensed · In development |
| Primary website action | Explore Still |
| Availability action | Beta status |

Lead with the screen and everyday use. Explain wake behavior and configurable widgets next. Agent integrations add useful context; Still's identity is broader than an agent dashboard. Primary audience hypotheses are people running builds/exports, listening to music or stepping away from their own desks. These are use cases to validate, not measured segments.

## Voice

Use concrete verbs: choose, cover, arrange, connect, return. Keep benefit copy short, then explain the behavior in plain English. Let Porcelain, burgundy, generous spacing and Instrument Serif carry the character. Native controls retain system typography; web controls use local Inter.

Prefer “optional widgets,” “system authentication” and “recent activity signals.” Avoid vague privacy superlatives, “uninterrupted work,” “secure lock,” “always running,” fake urgency, testimonials, usage totals and invented community adoption. Do not promise closed-lid operation or authoritative agent approvals. Examples and web illustrations must retain their sample labels.

## Visual system

The open-ring-and-dot mark used by the app and website is the supporting symbol. Remove the earlier pause-bars motif from repository materials. Porcelain remains the leading brand palette; Glass is the second native theme, not a competing identity. Use one calm focal point and readable content hierarchy. No decorative motion is required to communicate a modern product.

Color/font roles remain in [canonical tokens](../../design/tokens.json) and [font provenance](../../design/fonts/manifest.json). New logo/image variants need the same provenance discipline. Do not alter font files or relicense them under MIT.

## Discovery and trust

Publish readable product text, a clear workflow, descriptive titles, canonical URLs and one sitemap. Keep availability and tested compatibility easy to find. Structured data describes visible facts; no ratings, offers or release claims without evidence. Existing SEO practices apply to Google's AI features; an agent guide supports SDK consumption rather than guaranteeing search discovery. [Google Search Central](https://developers.google.com/search/docs/appearance/ai-features)

Raycast's first-party site is a reference for a clear utility proposition and direct product exploration. This informs hierarchy only; its copy, artwork, growth claims and business model are not reused. [Raycast](https://www.raycast.com/)

The personal website's readable introduction, project links and Open Graph-first repository presentation inform content hierarchy; the Villa Incanto code's central factual site configuration informs source discipline. These are references, not copied product copy. Do not import unrelated credentials, services, contact details or analytics. [Personal website source](https://github.com/mateonunez/website), [personal website](https://mateonunez.co)

## Availability and license

The beta audience is opt-in end users. No arbitrary tester-count cap. Developer ID setup remains a final release phase. Current CTAs explore the product or explain beta status; no fake download, signup collector or purchase flow exists.

Original code and documentation are MIT licensed. Source remains private during development. Public SDK assets carry the license notice; bundled fonts retain their original licenses. Do not describe private source as publicly available open source. Pricing or paid original collections would require a separate product decision; MIT does not create a payment flow.

Compatibility target: macOS 14+ and both architectures. Only tested combinations may be advertised as supported. Preserve the current development coverage warning in product help and the website FAQ.
