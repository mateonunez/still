import LocalAuthenticationEmbeddedUI
import SwiftUI
import StillNativePlugins

private struct ReturnRegionHeight: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

@MainActor
final class CurtainPresentation: ObservableObject {
    enum AuthenticationMode { case none, touchID, system }
    @Published var authenticationMode: AuthenticationMode = .none
    @Published var touchIDView: LAAuthenticationView?
    var authenticating: Bool { authenticationMode != .none }
    @Published var message = ""
    @Published var energyWarning = ""
    @Published var widgetCards: [NativeWidgetCard] = []
    @Published var extensionCards: [ExtensionCard] = []
    @Published var nativeCards: [NativePluginCard] = []
    @Published var widgetLayout = "corner"
    @Published var widgetSide = "right"
    @Published var composition = ScreenComposition()
    @Published var appearance: StillAppearance = .system
}

enum StillAppearance: String, CaseIterable {
    case system, light, dark
    var title: String { rawValue.capitalized }
}

struct CurtainView: View {
    @ObservedObject var presentation: CurtainPresentation
    let authenticate: () -> Void
    var useSystemAuthentication: () -> Void = {}
    var cancelAuthentication: () -> Void = {}
    var touchIDReady: @MainActor @Sendable (LAAuthenticationView) -> Void = { _ in }
    var isPrimaryDisplay = true
    var focusPrimaryDisplay: () -> Void = {}
    var isAuthenticationDisplay = true
    var evidenceRender = false
    @State private var reservedFooter: CGFloat = 230
    @Environment(\.colorScheme) private var colorScheme

    private var palette: PorcelainPalette {
        let dark = presentation.appearance == .dark ||
            (presentation.appearance == .system && colorScheme == .dark)
        return dark ? .dark : .light
    }

    var body: some View {
        Group {
            if isPrimaryDisplay { primaryBody }
            else {
                VStack(spacing: 16) {
                    StillMarkView().frame(width: 26, height: 26).foregroundStyle(palette.accent).accessibilityHidden(true)
                    Text("Still is on your main display.").font(.system(size: 13)).foregroundStyle(palette.secondary)
                    Button("Go to main display", action: focusPrimaryDisplay).stillControl().keyboardShortcut(.defaultAction)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).background(palette.background).ignoresSafeArea()
            }
        }.onExitCommand(perform: cancelAuthentication)
    }

    private var primaryBody: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    StillMarkView()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(palette.accent)
                        .accessibilityHidden(true)
                    Text("Still").font(.custom("InstrumentSerif-Regular", size: 32))
                    Spacer()
                    Text("PORCELAIN").font(.system(size: 11, weight: .semibold))
                        .tracking(3).foregroundStyle(palette.secondary)
                }
                if presentation.widgetLayout != "canvas", geometry.size.width < 1250 || geometry.size.height < 700 {
                    ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 12) {
                        ForEach(presentation.nativeCards) { card in NativePluginCardView(card: card, palette: palette) }
                        ForEach(presentation.widgetCards) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.provider.title).font(.system(size: 12, weight: .semibold))
                                if let window = card.snapshot?.windows.first {
                                    Text("\(window.title) · \(Int(window.usedPercent))% used").font(.system(size: 11))
                                } else { Text(card.status).font(.system(size: 10)).lineLimit(3) }
                            }.foregroundStyle(palette.secondary)
                        }
                        ForEach(presentation.extensionCards) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.title).font(.system(size: 12, weight: .semibold))
                                if let window = card.quota?.first { Text("\(window.title) · \(Int(window.usedPercent))% used").font(.system(size: 10)) }
                                else { Text(activityTitle(card.state)).font(.system(size: 10)).lineLimit(2) }
                            }.foregroundStyle(palette.secondary)
                        }
                    } }.frame(height: 250).padding(.top, 20)
                }
                Spacer()
                if presentation.widgetLayout != "canvas" {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    VStack(spacing: 18) {
                        Text(timeline.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                            .font(.system(size: 12, weight: .medium)).tracking(3)
                            .foregroundStyle(palette.secondary)
                        Text(timeline.date, format: .dateTime.hour().minute())
                            .font(.custom("InstrumentSerif-Regular", size: min(geometry.size.width * 0.18, 204)))
                            .monospacedDigit()
                            .accessibilityLabel("Current time")
                            .accessibilityValue(timeline.date.formatted(.dateTime.hour().minute()))
                        Text("A little space to step away.")
                            .font(.custom("InstrumentSerif-Regular", size: 32))
                            .foregroundStyle(palette.secondary)
                    }
                    .padding(.leading, presentation.widgetLayout == "rail" && presentation.widgetSide == "left" && geometry.size.width >= 1250 ? 340 : 0)
                    .padding(.trailing, presentation.widgetLayout == "rail" && presentation.widgetSide == "right" && geometry.size.width >= 1250 ? 340 : 0)
                }
                }
                Spacer()
                if geometry.size.width >= 1250, geometry.size.height >= 700, presentation.widgetLayout == "corner", hasModules {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 14) { moduleCards }
                        ScrollView(.horizontal, showsIndicators: true) { HStack(alignment: .top, spacing: 14) { moduleCards } }
                    }.frame(width: min(1320, geometry.size.width - 100), height: min(300, geometry.size.height * 0.28))
                        .frame(maxWidth: .infinity, alignment: presentation.widgetSide == "left" ? .leading : .trailing).padding(.bottom, 24)
                }
                VStack(spacing: 14) {
                    if let view = presentation.touchIDView, isAuthenticationDisplay {
                        EmbeddedTouchID(authenticationView: view, ready: { touchIDReady(view) })
                            .id(ObjectIdentifier(view))
                            .frame(width: 64, height: 64)
                        Text("Touch ID to return")
                            .font(.system(size: 14, weight: .medium))
                        Button("Use Mac password…", action: useSystemAuthentication)
                            .stillControl()
                            .font(.system(size: 13))
                            .foregroundStyle(palette.accent)
                            .disabled(presentation.authenticationMode == .system)
                    } else if evidenceRender {
                        Image(systemName: "touchid")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundStyle(palette.accent)
                            .accessibilityHidden(true)
                        Text("Touch ID to return").font(.system(size: 14, weight: .medium))
                        Button("Use Mac password…", action: useSystemAuthentication)
                            .stillControl()
                            .font(.system(size: 13)).foregroundStyle(palette.accent)
                    } else {
                        Button(action: authenticate) {
                            HStack(spacing: 10) {
                                Image(systemName: presentation.authenticationMode == .system ? "ellipsis" : "lock.open")
                                    .accessibilityHidden(true)
                                Text(presentation.authenticationMode == .system ? "Waiting for macOS…" : "Return to desktop")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16).padding(.vertical, 6)
                        }
                        .stillControl(prominent: true)
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                        .disabled(presentation.authenticationMode == .system)
                    }
                    Text(presentation.message.isEmpty ? "Your desktop can wait." : presentation.message)
                        .font(.system(size: 12)).foregroundStyle(palette.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500)
                    if !presentation.energyWarning.isEmpty {
                        Text(presentation.energyWarning)
                            .font(.system(size: 12)).foregroundStyle(palette.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 500)
                    }
                    Text("Visual privacy · Not the macOS security lock")
                        .font(.system(size: 11)).foregroundStyle(palette.secondary)
                }.background { GeometryReader { proxy in Color.clear.preference(key: ReturnRegionHeight.self, value: proxy.size.height) } }
            }
            .foregroundStyle(palette.primary)
            .padding(.horizontal, max(32, geometry.size.width * 0.055))
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.background)
            .overlay {
                if presentation.widgetLayout == "canvas" {
                    ScreenCanvasView(cards: presentation.nativeCards, composition: presentation.composition, palette: palette, selection: .constant(""), reservedFooter: reservedFooter)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: presentation.widgetSide == "left" ? .leading : .trailing) {
                if geometry.size.width >= 1250, geometry.size.height >= 700, presentation.widgetLayout == "rail", hasModules {
                    ViewThatFits(in: .vertical) {
                        VStack(spacing: 14) { moduleCards }.fixedSize(horizontal: false, vertical: true)
                        ScrollView(.vertical, showsIndicators: true) { VStack(spacing: 14) { moduleCards } }
                    }.frame(width: 312).frame(maxHeight: max(200, geometry.size.height - 180))
                        .padding(.horizontal, max(32, geometry.size.width * 0.055))
                }
            }
            .onPreferenceChange(ReturnRegionHeight.self) { reservedFooter = max(230, $0 + 56) }
        }
    }
    private var hasModules: Bool { !presentation.nativeCards.isEmpty || !presentation.widgetCards.isEmpty || !presentation.extensionCards.isEmpty }
    @ViewBuilder private var moduleCards: some View {
        ForEach(presentation.nativeCards) { card in NativePluginCardView(card: card, palette: palette).fixedSize(horizontal: false, vertical: true) }
        ForEach(presentation.widgetCards) { card in UsageCardView(card: card, palette: palette, compact: true).fixedSize(horizontal: false, vertical: true) }
        ForEach(presentation.extensionCards) { card in ExtensionCardView(card: card, palette: palette).fixedSize(horizontal: false, vertical: true) }
    }
}
