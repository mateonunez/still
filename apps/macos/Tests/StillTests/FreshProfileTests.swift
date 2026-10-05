import Foundation
import StillNativePlugins
import Testing
@testable import Still

@MainActor @Test func freshProfileOffersEveryPluginWithoutConnectingSources() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root)
    #expect(center.installed.count == NativePluginID.allCases.count)
    #expect(center.configurations.values.allSatisfy { !$0.enabled && !$0.visible && !$0.settings.spotifyAuthorized })
    #expect(center.visibleCards.isEmpty)
    #expect(center.cards.isEmpty)
    #expect(!FileManager.default.fileExists(atPath: root.appendingPathComponent("task-watch/connection.json").path))
}

@MainActor @Test func preparingMissingPluginsPreservesConfiguredSource() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    try FileManager.default.createDirectory(at: root.appendingPathComponent("world-clock"), withIntermediateDirectories: true)
    let store = NativePluginStore(root: root)
    var config = NativePluginConfiguration(plugin: .worldClock)
    config.enabled = true; config.visible = true
    config.settings.clocks = [ClockLocation(name: "Home", timeZone: "Europe/Rome")]
    try store.write(config)
    let before = try Data(contentsOf: root.appendingPathComponent("world-clock/configuration.json"))
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root)
    #expect(center.installed.count == 10)
    #expect(center.configurations[.worldClock] == config)
    #expect(try Data(contentsOf: root.appendingPathComponent("world-clock/configuration.json")) == before)
}

@MainActor @Test func hiddenDisabledSourcesDoNotConsumeVisibleSlots() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let store = NativePluginStore(root: root)
    try store.prepareMissingConfigurations()
    for id in [NativePluginID.agents, .buildWatch, .deployWatch, .spotify] {
        var config = NativePluginConfiguration(plugin: id)
        config.enabled = false; config.visible = true
        try store.write(config)
    }
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root)
    defer { center.stop() }
    center.setEnabled(.worldClock, true)
    center.setVisible(.worldClock, true)
    #expect(center.visibleIDs == [.worldClock])
    #expect(center.issue.isEmpty)
}

@MainActor @Test func reenablingRememberedVisibilityCannotHideAnotherModule() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let store = NativePluginStore(root: root)
    try store.prepareMissingConfigurations()
    for id in [NativePluginID.buildWatch, .deployWatch, .nextUp, .weather, .spotify] {
        var config = NativePluginConfiguration(plugin: id)
        config.enabled = id != .spotify; config.visible = true
        try store.write(config)
    }
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root)
    defer { center.stop() }
    center.setEnabled(.spotify, true)
    #expect(center.configurations[.spotify]?.enabled == false)
    #expect(center.visibleIDs.count == 4)
    #expect(!center.issue.isEmpty)
}

@MainActor @Test func externalMetadataReservationsApplyBeforePayloadsArrive() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root, externalSlots: { _ in 4 })
    defer { center.stop() }
    center.setEnabled(.worldClock, true)
    center.setVisible(.worldClock, true)
    #expect(center.visibleIDs.isEmpty)
    #expect(center.configurations[.worldClock]?.enabled == true)
    #expect(!center.issue.isEmpty)
}
