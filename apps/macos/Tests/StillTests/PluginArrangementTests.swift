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
