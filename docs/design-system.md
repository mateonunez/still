# Still — design system

## Design question

Can the screen feel peaceful and premium while authentication, energy state, and activity remain understandable? Compare three deliberately different compositions in the disposable prototype.

| Direction | Mood and composition | Palette |
| --- | --- | --- |
| Porcelain | Warm porcelain, editorial clock at left, small wine activity panel | Porcelain #F4EFEB, ink #2D2024, burgundy #702C43 |
| Spectrum | Dark stage, luminous gradients, centered clock and bottom tray | Night #0B0C17, violet #8063EF, coral #EF9F86 |
| Meadow | Original layered landscape, soft sky, quiet centered typography | Sky #DDEBD8, hills #61785A, deep green #233D32 |

Decision, 2026-10-04: Porcelain is the initial design standard, with light and dark appearances. Preserve its layout, quiet typography, and information hierarchy in both modes. Spectrum, Meadow, and future directions remain candidates for later collections and a possible marketplace; marketplace scope and business model are not selected.

Porcelain Dark uses deep plum #20171B, soft ivory #F3E9E6, secondary text #C5B0B8, and wine surfaces #38242C. Avoid pure black and bright white. The prototype includes Light, Dark, and System controls; System follows the browser's current appearance and subsequent changes. The native equivalent should use system appearance APIs when implemented. The current working name is Still; [brand fundamentals](brand-fundamentals.md) define the color and font roles, and [tokens](../design/tokens.json) are canonical.

Apple recommends using Liquid Glass selectively for controls/navigation and standard materials for content. This supports a restrained native control layer rather than glass on every surface. [Apple HIG materials](https://developer.apple.com/design/human-interface-guidelines/materials).

The Phase 2 native candidate implements macOS 26 glass buttons, burgundy tint and material welcome/preferences surfaces. Older OS versions and Reduce Transparency use standard buttons; service surfaces become solid for Reduce Transparency or Increase Contrast. The full-screen Porcelain curtain remains opaque. Live visual/accessibility acceptance is pending; rendered prototypes are not glass evidence. Keep status understandable with symbols and text, without extra ornamental motion.

## Semantic tokens

Define background, textPrimary, textSecondary, surface, border, accent, onAccent, activitySurface, activityText, activitySecondary and focus. Theme assets never control arbitrary text color without a contrast check. Spacing: 4/8/12/16/24/32/48/64. Radius: 8 small controls, 16 cards, 24 floating surfaces. Use Instrument Serif for clock/display typography, Inter for website UI and system text fonts in the native app. Preserve font licenses and provenance. Warning/error roles need their own contrast and non-color status cues when implemented.

Avoid text over uncontrolled bright artwork. Use a local scrim or solid surface where needed. Reduced Transparency gets opaque surfaces; Increased Contrast gets explicit boundaries. Respect Reduce Motion, VoiceOver, keyboard navigation, display scaling, and long localized text. Do not rely solely on color for power or error state.

## Screens and copy

- Onboarding: “A calm screen while your Mac works.” Preview first; explain ambient curtain vs system lock, then verify auth and choose energy policy.
- Menu bar: compact session state and primary action; avoid a dashboard as the entry point.
- Covered screen: clock/date, visible mode identity, capability-aware return action, optional activity disclosure, power/session state.
- Authentication: native system sheet; the prototype button only simulates its result. Passwords never belong in our custom UI.
- Settings: Automatic cover, Energy, Appearance, Authentication, Activity privacy. Explain automatic cover and keep-awake independently.
- Auth unavailable/canceled: remain covered, show clear retry/fallback; recovery never pretends the overlay is secure.
- Awake failure/expiry: actual status and end time; theme does not hide degraded behavior.

Before native implementation, decide activity placement, theme default, clock hierarchy, and whether recent details are ever visible before authentication.

## Artwork ownership

The Meadow concept uses an original vector landscape made for this prototype. A future illustrated family can use painted skies, rolling hills, warm houses, and quiet fantasy motifs. Commission or create original artwork; do not ship Studio Ghibli frames, characters, logos, or implied affiliation. Apple and Vercel are visual references, not brands to reuse.

Every shipped asset needs provenance, usage rights, supported resolutions, thumbnail, accessible text/scrim treatment, and memory budget. Begin with static wallpapers. Animated wallpaper remains a separate battery/performance decision.
