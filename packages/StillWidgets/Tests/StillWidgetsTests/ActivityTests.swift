import Foundation
import Testing
@testable import StillWidgets

@Test func hookProjectionDropsContentAndDoesNotInferPendingApprovals() throws {
    let data = Data("""
    {"hook_event_name":"PermissionRequest","session_id":"session","prompt":"PRIVATE","tool_input":{"command":"PRIVATE"},"cwd":"PRIVATE","transcript_path":"PRIVATE"}
    """.utf8)
    let event = try #require(ActivityEvent.decode(data))
    #expect(event.state == .attentionRequested)
    #expect(ActivityEvent.decode(Data(repeating: 32, count: 65537)) == nil)
    #expect(ActivityEvent.decode(Data("{\"session_id\":\"x\",\"hook_event_name\":\"Unsupported\"}".utf8)) == nil)
}
@Test func activityExpiresAndSessionEndClearsKnownState() {
    let now = Date(), digest = String(repeating: "a", count: 64)
    let record = ActivityRecord(sessionDigest: digest, state: .attentionRequested, observedAt: now, expiresAt: now.addingTimeInterval(90))
    #expect(record.isCurrent(now: now))
    #expect(!record.isCurrent(now: now.addingTimeInterval(91)))
    let end = ActivityEvent.decode(Data("{\"session_id\":\"x\",\"hook_event_name\":\"SessionEnd\"}".utf8))
    #expect(end?.state == .unknown)
}
@Test func hookInstallationPreservesOtherCommandsAndDisconnectOnlyRemovesOwnedGroup() throws {
    let original = Data("{\"theme\":\"dark\",\"hooks\":{\"Stop\":[{\"matcher\":\"*\",\"hooks\":[{\"type\":\"command\",\"command\":\"existing\",\"timeout\":5}]}]}}".utf8)
    let connected = try AgentHookPlan.patch(original, provider: .codex, command: "owned", enable: true).get()
    let repeated = try AgentHookPlan.patch(connected, provider: .codex, command: "owned", enable: true).get()
    #expect(connected == repeated)
    let restored = try AgentHookPlan.patch(connected, provider: .codex, command: "owned", enable: false).get()
    #expect(try JSONSerialization.jsonObject(with: original) as? NSDictionary == JSONSerialization.jsonObject(with: restored) as? NSDictionary)
    #expect(AgentHookPlan.events(.codex).contains("Interrupt"))
    #expect(!AgentHookPlan.events(.claude).contains("Interrupt"))
}
@Test func malformedHookSettingsAreNeverOverwritten() {
    #expect(throws: UsageFailure.self) { try AgentHookPlan.patch(Data("{\"hooks\":{\"Stop\":\"external\"}}".utf8), provider: .claude, command: "owned", enable: true).get() }
}
