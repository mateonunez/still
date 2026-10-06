import Foundation
import StillNativePlugins
import StillWidgets
import Testing
@testable import Still

@Test @MainActor func themeAndAppearancePersistAcrossSceneRecreation() throws {
    let name = "still-scene-test-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: name))
    defer { defaults.removePersistentDomain(forName: name) }
    let scene = CurtainPresentation(appearanceDefaults: defaults)
    #expect(scene.theme == .porcelain && scene.appearance == .system)
    scene.theme = .glass; scene.appearance = .light
    let restarted = CurtainPresentation(appearanceDefaults: defaults)
    #expect(restarted.theme == .glass && restarted.appearance == .light)
    defaults.set("unsupported", forKey: "StillTheme")
    #expect(CurtainPresentation(appearanceDefaults: defaults).theme == .porcelain)
}

@Test @MainActor func receivedActivityReachesCombinedWidgetAndExpiryStaysVisible() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let sources = root.appendingPathComponent("sources")
    try FileManager.default.createDirectory(at: sources.appendingPathComponent("activity"), withIntermediateDirectories: true)
    let store = NativePluginStore(root: root.appendingPathComponent("plugins"))
    try store.prepareMissingConfigurations()
    var config = NativePluginConfiguration(plugin: .agents)
    config.enabled = true; config.visible = true
    try store.write(config)
    let widgets = WidgetCenter(persist: false, readOnlyActivitySources: [.codex, .claude], sourceRoot: sources)
    let center = NativePluginCenter(widgets: widgets, root: root.appendingPathComponent("plugins"))
    defer { center.stop(); widgets.stop() }
    func write(_ provider: UsageProvider, expired: Bool) throws {
        let now = Date()
        let receipt = ActivitySnapshot(provider: provider, records: [ActivityRecord(sessionDigest: String(repeating: "a", count: 64), state: .working, observedAt: now.addingTimeInterval(expired ? -150 : 0), expiresAt: now.addingTimeInterval(expired ? -30 : 119))])
        try JSONEncoder().encode(receipt).write(to: sources.appendingPathComponent("activity/\(provider.rawValue).json"))
    }
    func values() throws -> [String] {
        widgets.tick(available: true); center.tick(available: true); center.refresh(.agents)
        guard case .agents(let metrics) = center.cards[.agents]?.payload else { throw CocoaError(.fileReadCorruptFile) }
        return metrics.map(\.value)
    }
    for provider in UsageProvider.allCases { try write(provider, expired: false) }
    #expect(try values().allSatisfy { $0.contains("Activity observed") })
    for provider in UsageProvider.allCases { try write(provider, expired: true) }
    #expect(try values().allSatisfy { $0.contains("no recent signal") && !$0.contains("Activity observed") })
    widgets.tick(available: false); center.tick(available: false)
    #expect(center.cards[.agents]?.state == .paused)
    for provider in UsageProvider.allCases { try write(provider, expired: false) }
    #expect(try values().allSatisfy { $0.contains("Activity observed") })
}
