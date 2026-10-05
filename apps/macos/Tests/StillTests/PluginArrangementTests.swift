import Foundation
import StillNativePlugins
import Testing
@testable import Still

@Test @MainActor func movingModulesRetainsEveryPluginExactlyOnce() {
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), persist: false)
    center.move(.spotify, before: .agents)
    #expect(center.order.first == .spotify)
    #expect(Set(center.order).count == 10 && center.order.count == 10)
    center.move(.spotify, before: .spotify)
    #expect(center.order.first == .spotify)
    center.move(.agents, before: .spotify)
    #expect(center.order.first == .agents)
}

@Test func spotifyReadTimeoutEndsOwnedProcess() async {
    let started = ContinuousClock.now
    let result = await NativeReadCommand.fetch(executable: URL(fileURLWithPath: "/bin/sleep"), arguments: ["30"], timeoutSeconds: 0.1)
    if case .failure(.timeout) = result {} else { Issue.record("A stalled source must become timeout") }
    #expect(ContinuousClock.now - started < .seconds(2))
}

@Test @MainActor func gridSwitchPreservesFreePlacementsAndColumnPreference() {
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), persist: false)
    center.setLayout(.free)
    let placement = CanvasPlacement(x: 0.347, y: 0.413, width: 297.5)
    center.place("spotify", placement)
    center.setLayout(.grid)
    center.setGridWidth(287.5)
    #expect(center.composition.effectiveLayout == .grid)
    #expect(center.composition.gridWidth == 287.5)
    center.setLayout(.free)
    #expect(center.composition.placement("spotify") == placement)
    center.setGridWidth(0)
    #expect(center.composition.gridWidth == 287.5)
}

@Test @MainActor func gridRowMovementAndDropReachTheSelectedDestination() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let store = NativePluginStore(root: root)
    try store.prepareMissingConfigurations()
    for id in NativePluginID.allCases {
        var configuration = NativePluginConfiguration(plugin: id)
        configuration.enabled = true; configuration.visible = true
        try store.write(configuration)
    }
    let center = NativePluginCenter(widgets: WidgetCenter(persist: false), root: root)
    defer { center.stop() }
    center.tick(available: false)
    center.move(.agents, by: 5)
    #expect(center.visibleIDs[5] == .agents)
    center.reorderVisible(.spotify, over: center.visibleIDs[0])
    #expect(center.visibleIDs.first == .spotify)
    center.reorderVisible(.spotify, over: center.visibleIDs[9])
    #expect(center.visibleIDs.last == .spotify)
    #expect(center.visibleIDs.count == 10 && Set(center.visibleIDs).count == 10)
}
