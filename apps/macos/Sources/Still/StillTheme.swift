import AppKit
import SwiftUI

/// Themes change Still-owned scenery, never the desktop underneath the curtain.
enum StillTheme: String, CaseIterable {
    case porcelain, glass
    var title: String { rawValue.capitalized }
    func palette(dark: Bool) -> PorcelainPalette {
        switch self {
        case .porcelain: dark ? .dark : .light
        case .glass: dark ? .glassDark : .glassLight
        }
    }
}

private struct StillThemeKey: EnvironmentKey { static let defaultValue = StillTheme.porcelain }
extension EnvironmentValues {
    var stillTheme: StillTheme {
        get { self[StillThemeKey.self] }
        set { self[StillThemeKey.self] = newValue }
    }
}

enum StillBackdropStyle: String, CaseIterable {
    case aurora, dusk, mist
    var title: String { rawValue.capitalized }
}

enum StillClockStyle: String, CaseIterable {
    case serif, rounded, minimal
    var title: String { rawValue.capitalized }
    func font(size: CGFloat) -> Font {
        switch self {
        case .serif: .custom("InstrumentSerif-Regular", size: size)
        case .rounded: .system(size: size * 0.8, weight: .light, design: .rounded)
        case .minimal: .system(size: size * 0.8, weight: .ultraLight)
        }
    }
}

struct StillSceneBackground: View {
    let theme: StillTheme
    let palette: PorcelainPalette
    @AppStorage("StillBackdrop") private var backdrop = StillBackdropStyle.aurora.rawValue
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        ZStack {
            palette.background
            if theme == .glass && !reduceTransparency && contrast != .increased {
                GeometryReader { geometry in
                    Ellipse().fill(palette.accent.opacity(backdrop == "mist" ? 0.05 : colorScheme == .dark ? 0.30 : 0.06))
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.85)
                        .blur(radius: 100).offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.3)
                    Ellipse().fill((backdrop == "dusk" ? Color.orange : Color.indigo).opacity(colorScheme == .dark ? 0.16 : 0.04))
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                        .blur(radius: 110).offset(x: geometry.size.width * 0.5, y: geometry.size.height * 0.55)
                }
            }
        }.clipped().ignoresSafeArea().accessibilityHidden(true)
    }
}

/// Content material stays distinct from the Liquid Glass control layer.
struct StillCardSurface: View {
    let palette: PorcelainPalette
    @Environment(\.stillTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme == .glass ? 24 : 18)
        if theme == .glass && !reduceTransparency && contrast != .increased {
            StillContentMaterial().clipShape(shape).overlay(shape.fill(palette.surface.opacity(0.35)))
                .overlay(shape.stroke(palette.primary.opacity(0.12), lineWidth: 1))
        } else { shape.fill(palette.surface).overlay(shape.stroke(palette.secondary.opacity(0.18), lineWidth: 1)) }
    }
}

/// One clock implementation keeps the editor, canvas and legacy layouts consistent.
struct StillClockFace: View {
    let palette: PorcelainPalette
    let size: CGFloat
    var messageSize: CGFloat = 24
    @AppStorage("StillClockStyle") private var style = StillClockStyle.serif.rawValue
    @AppStorage("StillShowDate") private var showDate = true
    @AppStorage("StillShowTagline") private var showMessage = true
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(spacing: 14) {
                if showDate {
                    Text(timeline.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                        .font(.system(size: 11, weight: .medium)).tracking(3).foregroundStyle(palette.secondary)
                }
                Text(timeline.date, format: .dateTime.hour().minute())
                    .font((StillClockStyle(rawValue: style) ?? .serif).font(size: size))
                    .monospacedDigit().minimumScaleFactor(0.7).lineLimit(1)
                    .accessibilityLabel("Current time").accessibilityValue(timeline.date.formatted(.dateTime.hour().minute()))
                if showMessage { Text("A little space to step away.").font(.custom("InstrumentSerif-Regular", size: messageSize)).foregroundStyle(palette.secondary) }
            }.foregroundStyle(palette.primary)
        }
    }
}

/// Explicitly sample this window's Still scenery, never behind-window desktop pixels.
private struct StillContentMaterial: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .contentBackground
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }
    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}
