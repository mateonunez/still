# Still — brand fundamentals

Working name: Still. Established 2026-10-04. Brand direction: Porcelain, shifted from olive to burgundy. Domain, trademark clearance, final app icon and bundle identity are not established.

## Character

Still is calm, deliberate and personal. The name expresses a visual pause while the computer can continue working. Use generous space, warm materials, confident serif typography and small, precise controls. Burgundy adds warmth and identity; avoid saturating the entire screen or introducing ornamental gradients into the standard theme.

Working wordmark: `Still` in Instrument Serif Regular. The two-stroke pause mark in the preview is an exploratory supporting motif, not the final app icon.

## Palette

The canonical machine-readable values live in [design/tokens.json](../design/tokens.json).

| Role | Light | Dark |
| --- | --- | --- |
| Background | Porcelain `#F4EFEB` | Deep plum `#20171B` |
| Elevated surface | Warm white `#FFFAF7` | Plum surface `#302229` |
| Primary text | Warm ink `#2D2024` | Soft ivory `#F3E9E6` |
| Secondary text | Rose taupe `#74646A` | Dusty rose `#C5B0B8` |
| Accent / action | Burgundy `#702C43` | Blush `#D9A8B8` |
| Text on action | Ivory `#FFF7F1` | Plum ink `#321E26` |
| Activity surface | Wine `#482934` | Dark wine `#38242C` |
| Divider | Rose line `#D9C6CD` | Plum line `#654B56` |

Light mode leads with porcelain and uses burgundy for actions and the activity surface. Dark mode leads with deep plum and uses a lighter blush for interactive contrast. A light-on-light burgundy tint is decorative only; never treat a subtle divider as the sole boundary of an interactive control.

The contrast script checks text, primary actions/hover, activity surfaces, focus indicators, and toggle pairs from the canonical values. Minimum measured body-text pair is 4.87:1 in light mode; dark body-text pairs exceed 7:1. This is palette evidence, not a full accessibility audit of every composited pixel.

```sh
node scripts/generate-website-tokens.mjs
node scripts/check-contrast.mjs
```

Generated CSS is a prototype artifact. The native app and Next.js site will consume the same semantic roles through platform-specific mappings.

## Typography

- **Instrument Serif Regular:** wordmark, clock, display headings, selected activity totals. Designed for large sizes; never use it for small controls. Keep tracking near normal for headings and slightly tighter for the clock. Avoid synthetic bold.
- **Instrument Serif Italic:** optional editorial emphasis, sparingly; not functional status copy.
- **Inter:** website body, captions, navigation and interactive controls. Use regular/medium weights, comfortable line height and tabular numbers for numeric metadata.
- **System font:** native macOS controls and settings. Preserve platform sizing, accessibility and conventional behavior; carry brand character through the display face and palette.

Instrument Serif and Inter are distributed under SIL Open Font License terms by their authors. Local unmodified WOFF2 files, their license texts, source URLs and SHA-256 hashes are included in [licensed font assets](../design/fonts/manifest.json). Native packaging will need the appropriate desktop font format and its included license. No system-wide font installation was performed. [Instrument's source](https://github.com/Instrument/instrument-serif), [Inter's source](https://github.com/rsms/inter).

## Language

Write natural English, with short sentences and concrete benefits. Prefer “Cover screen,” “Return to desktop,” “Keep Mac awake,” and “Needs your attention.” Avoid productivity hype, defensive legal language in the hero, invented testimonials and promises of universal task continuation.

Hero: **Step away. Keep the momentum.**

Supporting sentence: **A calm screen for your Mac, with simple keep-awake controls and optional activity at a glance.**

Security explanation: **Still covers your desktop for visual privacy. Use the macOS system lock when you need to secure your session.**

SEO descriptor: **Still — a calm screen and keep-awake app for Mac.** The brand name alone is too broad to explain the product in a search result.

## Brand applications

Use the same name, visual roles and primary message across the app, landing, README, release notes and future installer. Marketing screenshots must show the build being shipped. Keep agent-awareness and marketplace concepts clearly separate from available features.

The repository should feel edited: an original banner, concise product explanation, real preview, working instructions, architecture map and accurate status. Do not add fabricated build badges, stars, downloads, pricing, license claims, sponsor links or install commands for packages that do not exist.
