import StillWidgets
import StillPluginKit
import SwiftUI

struct UsageCardView: View {
    let card: NativeWidgetCard
    let palette: PorcelainPalette
    var compact = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: card.provider == .codex ? "command" : "asterisk").foregroundStyle(palette.accent).accessibilityHidden(true)
                Text(card.provider.title).font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(card.isLastReported ? "LAST REPORTED" : "ACCOUNT QUOTA").font(.system(size: 8, weight: .medium)).tracking(1).foregroundStyle(palette.secondary)
            }
            if let snapshot = card.snapshot {
                ForEach(Array(snapshot.windows.enumerated()), id: \.offset) { _, window in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(Int(window.usedPercent))%").font(.custom("InstrumentSerif-Regular", size: compact ? 22 : 34))
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
        .padding(compact ? 12 : 18).frame(width: 280, alignment: .leading)
        .foregroundStyle(palette.primary)
        .background(palette.surface.opacity(0.96), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(palette.secondary.opacity(0.18), lineWidth: 1))
    }
}

func activityTitle(_ state: String?) -> String {
    switch state {
    case "working": "Working"
    case "attentionRequested": "Attention requested"
    case "completed": "Completed"
    case "interrupted": "Interrupted"
    case "failed": "Failed"
    default: "Activity unavailable"
    }
}

struct ExtensionCardView: View {
    let card: ExtensionCard
    let palette: PorcelainPalette
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text(card.title).font(.system(size: 12, weight: .semibold)); Spacer(); if card.isSample { Text("SAMPLE").font(.system(size: 9)) } }
            if let quota = card.quota {
                ForEach(Array(quota.enumerated()), id: \.offset) { _, window in
                    Text("\(Int(window.usedPercent))% · \(window.title) used").font(.system(size: 13))
                }
            } else if card.kind == .quota {
                Text("Quota unavailable").font(.custom("InstrumentSerif-Regular", size: 24))
            } else {
                Text(activityTitle(card.state)).font(.custom("InstrumentSerif-Regular", size: 24))
                if let count = card.count, count > 0 { Text("\(count) recent signal\(count == 1 ? "" : "s")").font(.system(size: 11)) }
            }
            Text(card.detail).font(.system(size: 10)).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true)
            if let observed = card.observedAt { Text("Observed \(observed.formatted(.relative(presentation: .numeric)))").font(.system(size: 9)).foregroundStyle(palette.secondary) }
        }.padding(16).frame(width: 280, alignment: .leading).foregroundStyle(palette.primary)
            .background(palette.surface.opacity(0.96), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(palette.secondary.opacity(0.18), lineWidth: 1))
            .accessibilityElement(children: .combine)
    }
}

struct WidgetsHubView: View {
    @ObservedObject var controls: SessionControls
    @ObservedObject var widgets: WidgetCenter
    @ObservedObject var plugins: PluginCenter
    @ObservedObject var nativePlugins: NativePluginCenter
    @ObservedObject var presentation: CurtainPresentation
    let titlebarInset: CGFloat
    var editScreen: () -> Void = {}
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }
    @State private var section = "general"
    private var cardCount: Int { nativePlugins.visibleIDs.count + (nativePlugins.agentsEnabled ? 0 : widgets.enabled.count + widgets.activityEnabled.count) + plugins.manifests.filter { plugins.enabled.contains($0.id) }.reduce(0) { $0 + $1.widgets.count } }
    private var sections: [(id: String, title: String, symbol: String, detail: String)] {
        [("general", "General", "slider.horizontal.3", "A quieter rhythm for your Mac."),
         ("appearance", "Appearance", "paintpalette", "Make the screen feel like yours."),
         ("sources", "Agents", "sparkles", "Connect only the details that matter."),
         ("library", "Plugins", "square.grid.2x2", "Small windows into the things you choose.")]
    }
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Label("Still", systemImage: "circle.dotted").font(.custom("InstrumentSerif-Regular", size: 30)).padding(.horizontal, 20).padding(.top, 20)
                List(selection: $section) {
                    ForEach(sections, id: \.id) { item in
                        Label(item.title, systemImage: item.symbol).padding(.vertical, 6).tag(item.id)
                    }
                }.listStyle(.sidebar).scrollContentBackground(.hidden)
                Text("YOUR KIND OF QUIET").font(.system(size: 9, weight: .medium)).tracking(1.5).foregroundStyle(palette.secondary).padding(20)
            }.frame(width: 184)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sections.first { $0.id == section }?.title ?? "Settings").font(.system(size: 24, weight: .semibold))
                        Text(sections.first { $0.id == section }?.detail ?? "").font(.system(size: 12)).foregroundStyle(palette.secondary)
                    }
                    Spacer()
                    Button("Edit screen…", action: editScreen).stillControl(prominent: true)
                }.padding(28)
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if section == "general" { GeneralSettingsView(controls: controls) }
                        if section == "appearance" { appearanceSection }
                        if section == "sources" { sourcesSection }
                        if section == "library" { librarySection }
                        if section == "sources", !widgets.connectionIssue.isEmpty { Text(widgets.connectionIssue).font(.system(size: 12)).foregroundStyle(palette.secondary) }
                    }.padding(28).frame(maxWidth: .infinity, alignment: .leading)
                }
            }.frame(maxWidth: .infinity)
        }.padding(.top, titlebarInset).frame(minWidth: 780, minHeight: 570).foregroundStyle(palette.primary).tint(palette.accent).stillServiceSurface()
            .onAppear { if ProcessInfo.processInfo.arguments.contains("--plugins") { section = "library" } }
            .preferredColorScheme(presentation.appearance == .system ? nil : presentation.appearance == .dark ? .dark : .light)
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            TimelineView(.periodic(from: .now, by: 30)) { timeline in
                VStack(spacing: 12) {
                    Text("PORCELAIN").font(.system(size: 8, weight: .semibold)).tracking(3).foregroundStyle(palette.secondary)
                    Text(timeline.date.formatted(date: .omitted, time: .shortened)).font(.custom("InstrumentSerif-Regular", size: 64))
                    Text("A little space to step away.").font(.system(size: 11)).foregroundStyle(palette.secondary)
                    HStack(spacing: 10) { ForEach(widgets.cards) { card in Text(card.provider.title).font(.system(size: 10)).padding(8).background(palette.surface, in: Capsule()) } }
                }.frame(maxWidth: .infinity).padding(.vertical, 35).background(palette.background, in: RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(palette.secondary.opacity(0.15), lineWidth: 1))
            }
            Text("COLOR & LIGHT").font(.system(size: 10, weight: .semibold)).tracking(1.5).foregroundStyle(palette.secondary)
            Picker("Appearance", selection: $presentation.appearance) { ForEach(StillAppearance.allCases, id: \.self) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                .onChange(of: presentation.appearance) { _, value in UserDefaults.standard.set(value.rawValue, forKey: "StillAppearance") }
            Divider()
            Text("COMPOSITION").font(.system(size: 10, weight: .semibold)).tracking(1.5).foregroundStyle(palette.secondary)
            Picker("Composition", selection: $widgets.layout) { Text("Quiet corner").tag("corner"); Text("Side rail").tag("rail"); Text("Custom canvas").tag("canvas") }.disabled(plugins.template != nil)
            if widgets.layout != "canvas" { Picker("Widget position", selection: $widgets.side) { Text("Left").tag("left"); Text("Right").tag("right") }.pickerStyle(.segmented) }
            else { Text("Move and resize modules in the full-screen editor.").font(.system(size: 12)).foregroundStyle(palette.secondary) }
            if let template = plugins.template { Text("Composition from \(template.name)").font(.system(size: 11)).foregroundStyle(palette.secondary) }
            Text("Up to four optional cards. Your clock and return controls always stay visible.").font(.system(size: 12)).foregroundStyle(palette.secondary)
            Button("Reset composition") { plugins.apply(nil); widgets.layout = "corner" }.stillControl()
        }
    }

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack { Text("Agents").font(.custom("InstrumentSerif-Regular", size: 28)); Spacer(); Button("Discover installed agents") { nativePlugins.discover() }.stillControl() }
            ForEach(nativePlugins.discovered) { source in Text("\(source.provider.title) · \(source.executable == nil ? "not installed" : "installed")").font(.system(size: 11)).foregroundStyle(palette.secondary) }
            ForEach(UsageProvider.allCases, id: \.self) { provider in providerSection(provider) }
            HStack { Button("Refresh quota") { widgets.refresh() }.stillControl().disabled(!widgets.canRefresh); if widgets.fetching { ProgressView().controlSize(.small) } }
            Text("Quota is account usage. Activity is an advisory event signal; resolve requests in the original client.").font(.system(size: 11)).foregroundStyle(palette.secondary)
        }
    }

    private func providerSection(_ provider: UsageProvider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(provider.title).font(.system(size: 18, weight: .semibold))
            HStack {
                Text("Account quota").font(.system(size: 13)); Spacer()
                Button(widgets.enabled.contains(provider) ? "Disconnect \(provider.title) quota" : "Connect \(provider.title) quota") {
                    if widgets.enabled.contains(provider) { widgets.disconnect(provider) } else { widgets.connect(provider) }
                }.stillControl(prominent: !widgets.enabled.contains(provider)).disabled(!nativePlugins.agentsEnabled && !widgets.enabled.contains(provider) && cardCount >= 4)
            }
            HStack {
                Text("Activity signals").font(.system(size: 13)); Spacer()
                Button(widgets.activityEnabled.contains(provider) ? "Disable \(provider.title) activity" : "Enable \(provider.title) activity") { widgets.toggleActivity(provider) }.stillControl().disabled(!nativePlugins.agentsEnabled && !widgets.activityEnabled.contains(provider) && cardCount >= 4)
            }
            Text("Local hooks receive client input. Only anonymous states are saved; prompts and tool inputs are discarded.").font(.system(size: 11)).foregroundStyle(palette.secondary)
            DisclosureGroup("How it connects") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(provider == .codex ? "Quota uses your installed Codex client. Activity adds local hooks; review and trust them with /hooks in Codex. No approval decisions are made." : "Quota uses Claude Code’s status line. Activity adds local hooks. Existing commands and settings are preserved. Hook input is projected to anonymous states; prompts and tool content are never stored.")
                    Text("Attention signals expire. They do not establish that an approval is still pending.")
                    if provider == .codex { Button("Choose Codex executable…") { widgets.chooseCodex() }.stillControl() }
                }.font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.top, 8)
            }
            if let card = widgets.cards.first(where: { $0.provider == provider }) { UsageCardView(card: card, palette: palette, compact: true) }
            if let card = widgets.activityCards.first(where: { $0.id == provider.rawValue + "-activity" }) { ExtensionCardView(card: card, palette: palette) }
            Divider()
        }
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            NativePluginLibraryView(center: nativePlugins, palette: palette)
            Divider()
            HStack { Text("Make it yours.").font(.custom("InstrumentSerif-Regular", size: 28)); Spacer(); Button("Import package…") { plugins.importPackage() }.stillControl(prominent: true) }
            Text("Local templates and metadata. Still renders every card and runs no package code.").font(.system(size: 12)).foregroundStyle(palette.secondary)
            Text("\(cardCount) of 4 card slots connected").font(.system(size: 11)).foregroundStyle(palette.secondary)
            if cardCount > 4 { Text("More than four slots are reserved. Hide a native widget or disconnect a local source to see every selected card.").font(.system(size: 12)).foregroundStyle(palette.secondary) }
            if widgets.layout == "canvas" { Text("Imported metadata cards use Quiet corner or Side rail. The screen editor currently arranges native widgets.").font(.system(size: 12)).foregroundStyle(palette.secondary) }
            if plugins.manifests.isEmpty { Text("Your library is ready for its first .stillplugin package.").font(.system(size: 13)).padding(.vertical, 24) }
            ForEach(plugins.manifests) { manifest in
                VStack(alignment: .leading, spacing: 10) {
                    HStack { Text(manifest.name).font(.system(size: 15, weight: .semibold)); Spacer(); Text(manifest.kind == "template" ? "TEMPLATE" : "METADATA").font(.system(size: 9)).foregroundStyle(palette.secondary) }
                    Text("\(manifest.publisher) · \(manifest.version) · \(manifest.license)").font(.system(size: 11)).foregroundStyle(palette.secondary)
                    if manifest.kind == "template" { Button(plugins.selectedTemplate == manifest.id ? "Using this template" : "Apply template") { plugins.apply(manifest) }.stillControl().disabled(plugins.selectedTemplate == manifest.id) }
                    else {
                        Text("Requested facts: " + manifest.capabilities.map(\.rawValue).joined(separator: ", ")).font(.system(size: 11)).foregroundStyle(palette.secondary)
                        HStack {
                            Button(plugins.enabled.contains(manifest.id) ? "Disable local source" : "Enable local source") { if plugins.enabled.contains(manifest.id) { plugins.disconnect(manifest) } else { plugins.connect(manifest) } }.stillControl().disabled(!plugins.enabled.contains(manifest.id) && cardCount + manifest.widgets.count > 4)
                            if plugins.enabled.contains(manifest.id) { Button("Show inbox") { plugins.showInbox(manifest) }.stillControl() }
                        }
                    }
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(palette.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
            }
            ForEach(plugins.cards) { ExtensionCardView(card: $0, palette: palette) }
            if !plugins.issue.isEmpty { Text(plugins.issue).font(.system(size: 12)).foregroundStyle(palette.secondary) }
        }
    }
}
