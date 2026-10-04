import LocalAuthenticationEmbeddedUI
import SwiftUI

@MainActor
final class CurtainPresentation: ObservableObject {
    enum AuthenticationMode { case none, touchID, system }
    @Published var authenticationMode: AuthenticationMode = .none
    @Published var touchIDView: LAAuthenticationView?
    var authenticating: Bool { authenticationMode != .none }
    @Published var message = ""
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
    var isAuthenticationDisplay = true
    var evidenceRender = false
    @Environment(\.colorScheme) private var colorScheme

    private var palette: PorcelainPalette {
        let dark = presentation.appearance == .dark ||
            (presentation.appearance == .system && colorScheme == .dark)
        return dark ? .dark : .light
    }

    var body: some View {
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
                Spacer()
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
                }
                Spacer()
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
                    Text("Visual privacy · Not the macOS security lock")
                        .font(.system(size: 11)).foregroundStyle(palette.secondary)
                }
            }
            .foregroundStyle(palette.primary)
            .padding(.horizontal, max(32, geometry.size.width * 0.055))
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.background)
        }
        .onExitCommand(perform: cancelAuthentication)
    }
}
