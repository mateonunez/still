# Liquid Glass for Still

Reviewed 2026-10-06 against Apple documentation and Human Interface Guidelines. This is API/design research, not native runtime or release acceptance.

## Layer and variant selection

Apple places Liquid Glass in the functional layer: navigation and selected controls floating over content. Content surfaces use standard materials instead. Avoid extensive custom glass, glass nested inside glass, and glass applied indiscriminately to every card. Standard framework controls adopt the system appearance automatically when built with the current SDK. [HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials), [Liquid Glass overview](https://developer.apple.com/documentation/technologyoverviews/liquid-glass)

`regular` is the adaptive general-purpose variant and the appropriate starting point for Still controls. `clear` is intended for media-rich backgrounds, requires dimming for readable foregrounds, and suits bold, bright content above it. Apple advises against mixing the variants. Still's quiet Porcelain background does not justify `clear`. [Meet Liquid Glass, principles](https://developer.apple.com/videos/play/wwdc2025/219/?time=631)

## SwiftUI implementation guidance

Use the macOS 26 API path behind `if #available(macOS 26.0, *)`, retaining older-system controls. Prefer `.buttonStyle(.glass)` or `.buttonStyle(.glassProminent)` for actual buttons; the prominent style expresses the primary action. Avoid adding another glass layer around controls that already supply one. Apple's adoption guide identifies these button styles as the minimal-code route to the material. [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), [glassProminent](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/glassprominent)

For a genuinely custom functional surface, use `glassEffect(_:in:)`; its defaults are regular glass and a capsule. Set an appropriate shape, apply the effect after appearance/layout modifiers, and use `.interactive()` only when the component needs responsive material behavior. Tint selectively to express prominence. `glassEffectID(_:in:)`, `glassEffectUnion(id:namespace:)` and `glassEffectTransition(_:)` support coordinated shapes and transitions; Still does not need ornamental morphing to adopt the material. [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)

`GlassEffectContainer` combines related custom glass shapes into a shared rendering operation. Its spacing determines when neighboring shapes blend; excessive spacing can merge controls even at rest. Keep grouping local to related controls. A container spanning distant elements can cause unnecessary updates across its intervening region, so a full-screen container is not an automatic optimization. [GlassEffectContainer](https://developer.apple.com/documentation/swiftui/glasseffectcontainer), [Rendering efficiency](https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency)

## Accessibility and privacy boundary

The system material adapts to Reduce Transparency, Increase Contrast and Reduce Motion. Preserve these preferences and verify custom colors, labels, focus indicators and control boundaries in both appearances; a material effect alone does not establish readable contrast. [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/), [HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

**Still-specific inference:** keep the desktop-covering curtain fully opaque beneath every control and content surface. Native glass may decorate controls over Still-owned pixels; neither glass nor blurred desktop content should implement the privacy boundary. Service-window vibrancy remains separate from curtain coverage. This follows Still's design contract and Apple's separation of functional and content layers; Apple does not certify privacy coverage through these material APIs. [Still design contract](../../DESIGN.md), [HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

## Acceptance still required

- Compile the exact candidate with the selected SDK and verify the macOS 26 path and older-system fallback separately.
- Inspect light/dark appearance, Reduce Transparency, Increase Contrast, Reduce Motion, keyboard focus and VoiceOver on the native candidate.
- Place visually distinctive private desktop content behind the curtain and verify no bleed-through at control edges or during appearance changes.
- Check container blending at rest and profile updates when surrounding content changes. Research, source inspection and screenshots do not prove physical interaction, gesture coverage or release readiness.
