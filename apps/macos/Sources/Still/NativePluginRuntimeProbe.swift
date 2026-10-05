import AppKit
import StillNativePlugins
import StillWidgets
import SwiftUI

/// Explicit opt-in live probe. Copies configuration into owned scratch; never asks for OS permission.
@MainActor
enum NativePluginRuntimeProbe {
    static func run(directory: URL, taskProducer: String?) async {
        let fm = FileManager.default
        let scratch = directory.appendingPathComponent("native-plugins")
        do {
            try fm.createDirectory(at: directory, withIntermediateDirectories: true)
            let actual = NativePluginStore(root: ClaudeBridgeInstaller.root.appendingPathComponent("native-plugins"))
            let store = NativePluginStore(root: scratch)
            for id in NativePluginID.allCases {
                guard let config = actual.configuration(id) else { continue }
                try fm.createDirectory(at: store.directory(id), withIntermediateDirectories: true)
                try store.write(config)
            }
            // Read configured quota sources without installing a status line, hooks or preferences.
            let widgets = WidgetCenter(persist: false, readOnlySources: Set(UsageProvider.allCases))
            widgets.tick(available: true)
            let center = NativePluginCenter(widgets: widgets, root: scratch)
            center.tick(available: true)
            if let taskProducer {
                _ = await NativeReadCommand.fetch("node", arguments: [taskProducer, "run", "--root", store.directory(.taskWatch).path, "--label", "Verification task", "--", "/usr/bin/true"])
                center.refresh(.taskWatch)
            }
            try await Task.sleep(for: .seconds(3))
            center.tick(available: true)
            let limit = ContinuousClock.now.advanced(by: .seconds(20))
            while ContinuousClock.now < limit && center.cards.values.contains(where: { $0.state == .refreshing }) { try await Task.sleep(for: .milliseconds(200)); center.tick(available: true) }
            var checks: [String: Bool] = ["tenPluginsLoaded": center.installed.count == 10, "allSelectedCardsRendered": center.visibleCards.count == center.visibleIDs.count, "codexAndClaudeDiscovery": center.discovered.count == 2]
            for id in [NativePluginID.buildWatch, .deployWatch, .macPulse, .worldClock, .quietTimer, .weather] { checks[id.rawValue + "LivePayload"] = center.cards[id]?.payload != nil && center.cards[id]?.state == .ready }
            checks["spotifyDoesNotFakePlayback"] = center.cards[.spotify]?.state == .ready || center.cards[.spotify]?.state == .permissionRequired || center.cards[.spotify]?.state == .unavailable
            checks["calendarNeedsExplicitSelectionOrPermission"] = [.setupRequired, .permissionRequired].contains(center.cards[.nextUp]?.state ?? .ready) || (center.cards[.nextUp]?.state == .ready && !(center.configurations[.nextUp]?.settings.calendarID ?? "").isEmpty)
            if case .work(let tasks) = center.cards[.taskWatch]?.payload { checks["realTaskReportedCompleted"] = tasks.contains { $0.label == "Verification task" && $0.state == .completed } } else { checks["realTaskReportedCompleted"] = false }
            center.startTimer(); checks["timerStarted"] = center.cards[.quietTimer]?.payload != .timer(deadline: nil)
            center.stopTimer(); checks["timerStopped"] = center.cards[.quietTimer]?.payload == .timer(deadline: nil)
            center.setVisible(.weather, true)
            checks["fifthVisiblePluginAccepted"] = center.visibleIDs.contains(.weather) && center.visibleCards.count == center.visibleIDs.count && center.issue.isEmpty
            for id in center.installed { center.setVisible(id, true) }
            checks["allEnabledPluginsVisible"] = center.visibleCards.count == center.installed.filter { center.configurations[$0]?.enabled == true }.count
            var exports = 0
            for appearance in [StillAppearance.light, .dark] {
                let palette: PorcelainPalette = appearance == .light ? .light : .dark
                let cards = NativePluginID.allCases.compactMap { center.cards[$0] }
                let view = VStack(alignment: .leading, spacing: 16) {
                    Text("Still · mateonunez native collection").font(.custom("InstrumentSerif-Regular", size: 30))
                    LazyVGrid(columns: [GridItem(.fixed(312)), GridItem(.fixed(312))], alignment: .leading, spacing: 16) { ForEach(cards) { NativePluginCardView(card: $0, palette: palette) } }
                }.padding(32).background(palette.background).foregroundStyle(palette.primary).environment(\.colorScheme, appearance == .light ? .light : .dark)
                let renderer = ImageRenderer(content: view); renderer.scale = 2
                if let image = renderer.nsImage, let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) { try png.write(to: directory.appendingPathComponent("native-plugins-\(appearance.rawValue).png")); exports += 1 }
            }
            checks["lightAndDarkCardsExported"] = exports == 2
            let presentation = CurtainPresentation()
            presentation.nativeCards = center.visibleCards
            presentation.appearance = .dark
            for preset in CanvasPreset.allCases {
                center.applyPreset(preset)
                presentation.composition = center.composition
                presentation.widgetLayout = "canvas"
                for viewport in [CGSize(width: 1512, height: 982), CGSize(width: 2560, height: 1440), CGSize(width: 1024, height: 768)] {
                    let renderer = ImageRenderer(content: CurtainView(presentation: presentation, authenticate: {}, evidenceRender: true).frame(width: viewport.width, height: viewport.height).environment(\.colorScheme, .dark))
                    renderer.scale = 1
                    if let image = renderer.nsImage, let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) { try png.write(to: directory.appendingPathComponent("canvas-\(preset.rawValue)-\(Int(viewport.width)).png")) }
                }
            }
            for composition in ["corner", "rail", "canvas"] {
                presentation.widgetLayout = composition
                let renderer = ImageRenderer(content: CurtainView(presentation: presentation, authenticate: {}, evidenceRender: true).frame(width: 1920, height: 1080).environment(\.colorScheme, .dark))
                renderer.scale = 1
                if let image = renderer.nsImage, let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) { try png.write(to: directory.appendingPathComponent("curtain-\(composition).png")) }
            }
            let editor = ImageRenderer(content: ScreenEditorView(center: center, presentation: presentation, finish: {}).frame(width: 1920, height: 1080).environment(\.colorScheme, .dark))
            editor.scale = 1
            if let image = editor.nsImage, let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) { try png.write(to: directory.appendingPathComponent("screen-editor.png")) }
            let states = NativePluginID.allCases.map { id in ["plugin": id.rawValue, "state": center.cards[id]?.state.rawValue ?? "missing", "hasPayload": center.cards[id]?.payload != nil] as [String: Any] }
            center.tick(available: false)
            checks["suspensionClearsPayloads"] = center.cards.values.allSatisfy { $0.payload == nil && $0.state == .paused }
            center.stop(); widgets.stop()
            let data = try JSONSerialization.data(withJSONObject: ["checks": checks, "states": states, "allPassed": checks.values.allSatisfy { $0 }, "boundary": "Live source reads and state ownership; not OS permission grants, native materials, authentication or beta readiness."], options: [.sortedKeys, .prettyPrinted])
            try data.write(to: directory.appendingPathComponent("native-plugins.json"))
        } catch {
            try? Data("{\"allPassed\":false,\"error\":\"Probe could not finish\"}".utf8).write(to: directory.appendingPathComponent("native-plugins.json"))
        }
    }
}
