import Combine
import Foundation
import StillNativePlugins
import StillWidgets
import Testing
@testable import Still

@Test @MainActor func unchangedSourceTicksDoNotInvalidateObservers() throws {
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: scratch) }
    let widgets = WidgetCenter(persist: false, readOnlySources: [.claude], sourceRoot: scratch)
    let plugins = PluginCenter(persist: false, root: scratch.appendingPathComponent("plugins"))
    widgets.tick(available: true); plugins.tick(available: true)
    var widgetUpdates = 0, pluginUpdates = 0
    let widgetObserver = widgets.objectWillChange.sink { widgetUpdates += 1 }
    let pluginObserver = plugins.objectWillChange.sink { pluginUpdates += 1 }
    for _ in 0..<100 { widgets.tick(available: true); plugins.tick(available: true) }
    withExtendedLifetime((widgetObserver, pluginObserver)) {
        #expect(widgetUpdates == 0)
        #expect(pluginUpdates == 0)
    }
    widgets.stop()
}

@Test @MainActor func changedQuotaAndSuspensionStillInvalidateObservers() throws {
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: scratch) }
    let source = scratch.appendingPathComponent("usage/claude.json")
    try FileManager.default.createDirectory(at: source.deletingLastPathComponent(), withIntermediateDirectories: true)
    let widgets = WidgetCenter(persist: false, readOnlySources: [.claude], sourceRoot: scratch)
    var updates = 0
    let observer = widgets.objectWillChange.sink { updates += 1 }
    let quota = UsageSnapshot(provider: .claude, observedAt: Date(), windows: [UsageWindow(minutes: 300, usedPercent: 42, resetsAt: nil)])
    try JSONEncoder().encode(quota).write(to: source)
    widgets.tick(available: true)
    #expect(updates == 1)
    #expect(widgets.cards.first?.snapshot?.windows.first?.usedPercent == 42)
    updates = 0
    widgets.tick(available: true)
    #expect(updates == 0)
    widgets.tick(available: false)
    #expect(updates == 1)
    #expect(widgets.cards.first?.snapshot == nil)
    updates = 0
    for _ in 0..<100 { widgets.tick(available: false) }
    withExtendedLifetime(observer) { #expect(updates == 0) }
    widgets.stop()
}

@Test @MainActor func unchangedNativeCardAndPauseDoNotInvalidateObservers() throws {
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: scratch) }
    let store = NativePluginStore(root: scratch)
    try store.prepareMissingConfigurations()
    var config = NativePluginConfiguration(plugin: .worldClock)
    config.enabled = true; config.visible = true
    try store.write(config)
    let widgets = WidgetCenter(persist: false)
    let center = NativePluginCenter(widgets: widgets, root: scratch)
    center.tick(available: true)
    var updates = 0
    let observer = center.objectWillChange.sink { updates += 1 }
    for _ in 0..<100 { center.tick(available: true) }
    #expect(updates == 0)
    center.tick(available: false)
    #expect(center.cards[.worldClock]?.state == .paused)
    updates = 0
    for _ in 0..<100 { center.tick(available: false) }
    withExtendedLifetime(observer) { #expect(updates == 0) }
    center.stop(); widgets.stop()
}

@Test @MainActor func unchangedSessionTickDoesNotInvalidateObservers() {
    let controls = SessionControls(persist: false)
    _ = controls.tick(alreadyCovered: false, sessionAvailable: true)
    var updates = 0
    let observer = controls.objectWillChange.sink { updates += 1 }
    for _ in 0..<100 { _ = controls.tick(alreadyCovered: false, sessionAvailable: true) }
    withExtendedLifetime(observer) { #expect(updates == 0) }
    #expect(controls.energyStatus == "Normal sleep behavior")
}
