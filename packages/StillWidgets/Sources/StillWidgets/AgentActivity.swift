import Foundation

public enum ActivityState: String, Codable, Sendable { case working, attentionRequested, completed, interrupted, failed, unknown }
public struct ActivityRecord: Codable, Equatable, Sendable {
    public let sessionDigest: String
    public let groupDigest: String?
    public let state: ActivityState
    public let observedAt: Date
    public let expiresAt: Date
    public init(sessionDigest: String, groupDigest: String? = nil, state: ActivityState, observedAt: Date, expiresAt: Date) {
        self.sessionDigest = sessionDigest; self.groupDigest = groupDigest; self.state = state; self.observedAt = observedAt; self.expiresAt = expiresAt
    }
    public func isCurrent(now: Date) -> Bool {
        sessionDigest.count == 64 && sessionDigest.allSatisfy { $0.isHexDigit && !$0.isUppercase } && observedAt <= now.addingTimeInterval(5) && now < expiresAt && expiresAt.timeIntervalSince(observedAt) <= 120 && expiresAt > observedAt
    }
}
public struct ActivitySnapshot: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let provider: UsageProvider
    public let records: [ActivityRecord]
    public init(provider: UsageProvider, records: [ActivityRecord]) { protocolVersion = 1; self.provider = provider; self.records = records }
    public func current(now: Date) -> [ActivityRecord] { protocolVersion == 1 && records.count <= 64 ? records.filter { $0.isCurrent(now: now) } : [] }
}
public struct ActivityEvent: Sendable {
    public let sessionID: String
    public let agentID: String?
    public let state: ActivityState
    public let eventName: String
    public static func decode(_ data: Data) -> ActivityEvent? {
        struct Input: Decodable { let session_id: String; let hook_event_name: String; let agent_id: String? }
        guard data.count <= 65536, let input = try? JSONDecoder().decode(Input.self, from: data), !input.session_id.isEmpty, input.session_id.utf8.count <= 256, (input.agent_id?.utf8.count ?? 0) <= 256 else { return nil }
        let state: ActivityState
        switch input.hook_event_name {
        case "UserPromptSubmit", "PreToolUse", "PostToolUse": state = .working
        case "PermissionRequest": state = .attentionRequested
        case "Stop": state = .completed
        case "Interrupt": state = .interrupted
        case "PostToolUseFailure", "StopFailure": state = .failed
        case "SessionStart", "SessionEnd": state = .unknown
        default: return nil
        }
        return ActivityEvent(sessionID: input.session_id, agentID: input.agent_id, state: state, eventName: input.hook_event_name)
    }
}

/// Append/remove only exact owned hook groups; preserve unrelated settings and hooks.
public enum AgentHookPlan {
    public static func events(_ provider: UsageProvider) -> [String] { ["SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PermissionRequest", "Stop"] + (provider == .codex ? ["Interrupt"] : ["PostToolUseFailure", "StopFailure"]) }
    public static func patch(_ data: Data?, provider: UsageProvider, command: String, enable: Bool) -> Result<Data, UsageFailure> {
        guard (data?.count ?? 0) <= 1048576 else { return .failure(.invalidPayload) }
        var settings: [String: Any]
        if let data { guard let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return .failure(.invalidPayload) }; settings = value } else { settings = [:] }
        guard settings["hooks"] == nil || settings["hooks"] is [String: Any] else { return .failure(.invalidPayload) }
        var hooks = settings["hooks"] as? [String: Any] ?? [:]
        let own: [String: Any] = ["hooks": [["type": "command", "command": command, "timeout": 1]]]
        for event in events(provider) {
            guard hooks[event] == nil || hooks[event] is [[String: Any]] else { return .failure(.invalidPayload) }
            var groups = hooks[event] as? [[String: Any]] ?? []
            groups.removeAll { NSDictionary(dictionary: $0).isEqual(to: own) }
            if enable { groups.append(own) }
            if groups.isEmpty { hooks.removeValue(forKey: event) } else { hooks[event] = groups }
        }
        if hooks.isEmpty { settings.removeValue(forKey: "hooks") } else { settings["hooks"] = hooks }
        guard let output = try? JSONSerialization.data(withJSONObject: settings, options: [.sortedKeys, .prettyPrinted]) else { return .failure(.invalidPayload) }
        return .success(output)
    }
}
