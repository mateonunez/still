import StillWidgets
import SwiftUI

struct UsageCardView: View {
    let card: NativeWidgetCard
    let palette: PorcelainPalette
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: card.provider == .codex ? "command" : "asterisk").foregroundStyle(palette.accent).accessibilityHidden(true)
                Text(card.provider.title).font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("ACCOUNT QUOTA").font(.system(size: 8, weight: .medium)).tracking(1).foregroundStyle(palette.secondary)
            }
            if let snapshot = card.snapshot {
                ForEach(Array(snapshot.windows.enumerated()), id: \.offset) { _, window in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(Int(window.usedPercent))%").font(.custom("InstrumentSerif-Regular", size: 34))
                            Text("\(window.title) used").font(.system(size: 10)).foregroundStyle(palette.secondary)
                        }
                        ProgressView(value: window.usedPercent, total: 100).tint(palette.accent).accessibilityLabel("\(window.title) used").accessibilityValue("\(Int(window.usedPercent)) percent")
                        if let reset = window.resetsAt {
                            Text("Resets \(reset.formatted(.relative(presentation: .numeric)))").font(.system(size: 10)).foregroundStyle(palette.secondary)
                        }
                    }
                }
                Text("Observed \(snapshot.observedAt.formatted(.relative(presentation: .numeric)))").font(.system(size: 9)).foregroundStyle(palette.secondary)
            }
            Text(card.status).font(.system(size: 10)).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(18).frame(width: 280, alignment: .leading)
        .foregroundStyle(palette.primary)
        .background(palette.surface.opacity(0.96), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(palette.secondary.opacity(0.18), lineWidth: 1))
    }
}

struct WidgetsHubView: View {
    @ObservedObject var widgets: WidgetCenter
    @ObservedObject var presentation: CurtainPresentation
    let titlebarInset: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your kind of quiet.").font(.custom("InstrumentSerif-Regular", size: 36))
                Text("Real account quota. Only the details you choose.").font(.system(size: 13)).foregroundStyle(palette.secondary)
                Picker("Composition", selection: $widgets.layout) { Text("Quiet corner").tag("corner"); Text("Side rail").tag("rail") }
                ForEach(UsageProvider.allCases, id: \.self) { provider in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(provider.title).font(.system(size: 16, weight: .semibold)); Spacer()
                            Button(widgets.enabled.contains(provider) ? "Disconnect \(provider.title)" : "Connect \(provider.title)") {
                                if widgets.enabled.contains(provider) { widgets.disconnect(provider) } else { widgets.connect(provider) }
                            }.stillControl(prominent: !widgets.enabled.contains(provider))
                        }
                        Text(provider == .codex ? "Read account quota through your installed Codex client. No conversations, API keys or approvals are read." : "Connect installs a quota-only status-line bridge in Claude Code settings. Your existing command and options are preserved. Disconnect restores it if it has not changed elsewhere.")
                            .font(.system(size: 12)).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true)
                        if provider == .claude {
                            Text("Requires Claude Code 2.1.80+ and supported account quota. After connecting, continue normal Claude work; missing or unchanged old data remains unavailable.")
                                .font(.system(size: 11)).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                        if let card = widgets.cards.first(where: { $0.provider == provider }) { UsageCardView(card: card, palette: palette) }
                        if provider == .codex { Button("Choose Codex executable…") { widgets.chooseCodex() }.stillControl() }
                    }
                    Divider()
                }
                HStack { Button("Refresh sources") { widgets.refresh() }.stillControl().disabled(!widgets.canRefresh); if widgets.fetching { ProgressView().controlSize(.small) } }
                if !widgets.connectionIssue.isEmpty { Text(widgets.connectionIssue).font(.system(size: 12)).foregroundStyle(palette.secondary) }
                Text("No sample data is used in the native app. Agent activity and approval requests are not connected in this version.").font(.system(size: 11)).foregroundStyle(palette.secondary)
            }.padding(32).frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.top, titlebarInset).frame(minWidth: 560, minHeight: 570).foregroundStyle(palette.primary).stillServiceSurface()
            .preferredColorScheme(presentation.appearance == .system ? nil : presentation.appearance == .dark ? .dark : .light)
    }
}
