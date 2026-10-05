import Foundation
import Testing
@testable import StillWidgets

private let now = Date(timeIntervalSince1970: 1000)
@Test func codexKeepsActualWindowAndDropsPrivateFields() throws {
    let data = Data(#"{"accountId":"secret-identity","credits":{"balance":"private"},"rateLimits":{"primary":{"usedPercent":39,"windowDurationMins":10080,"resetsAt":2000},"secondary":null}}"#.utf8)
    let snapshot = try UsageProjection.codex(data, now: now).get()
    #expect(snapshot.windows.count == 1 && snapshot.windows[0].minutes == 10080)
    let encoded = String(decoding: try JSONEncoder().encode(snapshot), as: UTF8.self)
    #expect(!encoded.contains("secret-identity") && !encoded.contains("credits"))
}
@Test func absentWindowsAreUnavailableInsteadOfZero() {
    let result = UsageProjection.codex(Data(#"{"rateLimits":{"primary":null,"secondary":null}}"#.utf8), now: now)
    if case .success = result { Issue.record("Missing quota must not be healthy zero") }
}
@Test func claudeDropsExpiredWindowsAndIgnoresPrivateContext() throws {
    let data = Data(#"{"cwd":"private-path","transcript_path":"private-file","rate_limits":{"five_hour":{"used_percentage":42,"resets_at":2000},"seven_day":{"used_percentage":18,"resets_at":999}}}"#.utf8)
    let snapshot = try UsageProjection.claudeStatusline(data, now: now).get()
    #expect(snapshot.windows.count == 1 && snapshot.windows[0].minutes == 300)
    #expect(!String(decoding: try JSONEncoder().encode(snapshot), as: UTF8.self).contains("private"))
}
@Test(arguments: [-1.0, 101.0]) func invalidPercentIsRejected(percent: Double) {
    let input = "{\"rateLimits\":{\"primary\":{\"usedPercent\":\(percent),\"windowDurationMins\":300,\"resetsAt\":2000}}}"
    if case .success = UsageProjection.codex(Data(input.utf8), now: now) { Issue.record("Invalid quota accepted") }
}
@Test func sourceFreshnessCannotBeExtendedByFutureTimestamps() {
    let window = UsageWindow(minutes: 300, usedPercent: 42, resetsAt: now.addingTimeInterval(500))
    #expect(!UsageSnapshot(provider: .claude, observedAt: now.addingTimeInterval(10), windows: [window]).isUsable(now: now))
    #expect(!UsageSnapshot(provider: .claude, observedAt: now.addingTimeInterval(-301), windows: [window]).isUsable(now: now))
}
@Test func oversizedSourceIsRejected() {
    if case .success = UsageProjection.claudeStatusline(Data(repeating: 32, count: 131073), now: now) { Issue.record("Oversized source accepted") }
}
@Test func bridgePreservesOptionsAndUnrelatedChangesOnRestore() throws {
    let current = Data(#"{"theme":"dark","statusLine":{"type":"command","command":"original-command","padding":2}}"#.utf8)
    let plan = try ClaudeBridgePlan.connect(current: current, command: "still-helper").get()
    var object = try #require(JSONSerialization.jsonObject(with: plan.settings) as? [String: Any])
    #expect((object["statusLine"] as? [String: Any])?["padding"] as? Int == 2)
    object["theme"] = "light"
    let updated = try JSONSerialization.data(withJSONObject: object)
    let restored = try ClaudeBridgePlan.disconnect(current: updated, record: plan.record, command: "still-helper").get()
    let result = try #require(JSONSerialization.jsonObject(with: restored) as? [String: Any])
    #expect(result["theme"] as? String == "light")
    #expect((result["statusLine"] as? [String: Any])?["command"] as? String == "original-command")
    let same = try ClaudeBridgePlan.connect(current: plan.settings, command: "still-helper").get()
    #expect(!same.changed)
}
@Test func bridgeRefusesToOverwriteAnExternalStatuslineEdit() throws {
    let plan = try ClaudeBridgePlan.connect(current: nil, command: "still-helper").get()
    let external = Data(#"{"statusLine":{"type":"command","command":"new-user-command"}}"#.utf8)
    if case .success = ClaudeBridgePlan.disconnect(current: external, record: plan.record, command: "still-helper") { Issue.record("External edit overwritten") }
}
@Test func bridgeRejectsInvalidSettingsWithoutAPlan() {
    if case .success = ClaudeBridgePlan.connect(current: Data("broken-json".utf8), command: "still-helper") { Issue.record("Invalid settings replaced") }
}
