import SwiftUI

/// Native control chrome. The privacy curtain itself always stays opaque.
private struct StillControlStyle: ViewModifier {
    let prominent: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }

    @ViewBuilder func body(content: Content) -> some View {
        if #available(macOS 26.0, *), !reduceTransparency {
            if prominent {
                content.buttonStyle(.glassProminent).tint(palette.accent)
            } else {
                content.buttonStyle(.glass).tint(palette.accent)
            }
        } else if prominent {
            content.buttonStyle(.borderedProminent).tint(palette.accent)
        } else {
            content.buttonStyle(.bordered).tint(palette.accent)
        }
    }
}

private struct StillServiceSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }

    @ViewBuilder func body(content: Content) -> some View {
        if reduceTransparency || contrast == .increased {
            content.background { palette.surface.ignoresSafeArea() }
        } else {
            content.background {
                Rectangle().fill(.regularMaterial)
                    .overlay(palette.surface.opacity(0.72))
                    .ignoresSafeArea()
            }
        }
    }
}

extension View {
    func stillControl(prominent: Bool = false) -> some View {
        modifier(StillControlStyle(prominent: prominent))
    }

    func stillServiceSurface() -> some View {
        modifier(StillServiceSurface())
    }
}
