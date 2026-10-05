import Foundation

public enum UsageProvider: String, CaseIterable, Codable, Sendable {
    case codex, claude
    public var title: String { self == .codex ? "Codex" : "Claude" }
}

public struct UsageWindow: Codable, Equatable, Sendable {
    public let minutes: Int
    public let usedPercent: Double
    public let resetsAt: Date?
    public init(minutes: Int, usedPercent: Double, resetsAt: Date?) {
        self.minutes = minutes; self.usedPercent = usedPercent; self.resetsAt = resetsAt
    }
    public var title: String { minutes == 300 ? "5-hour quota" : minutes == 10080 ? "Weekly quota" : "\(minutes)-minute quota" }
}

public struct UsageSnapshot: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let provider: UsageProvider
    public let observedAt: Date
    public let windows: [UsageWindow]
    public init(provider: UsageProvider, observedAt: Date, windows: [UsageWindow]) {
        protocolVersion = 1; self.provider = provider; self.observedAt = observedAt; self.windows = windows
    }
    public func isUsable(now: Date) -> Bool {
        protocolVersion == 1 && observedAt <= now.addingTimeInterval(5) && now.timeIntervalSince(observedAt) <= 300 &&
        !windows.isEmpty && windows.count <= 2 && windows.allSatisfy {
            $0.usedPercent.isFinite && (0...100).contains($0.usedPercent) && (1...44640).contains($0.minutes) &&
            ($0.resetsAt.map { $0 > now } ?? true)
        }
    }
}

public enum UsageFailure: String, Error, Codable, Sendable {
    case missingClient, unavailable, authenticationRequired, timeout, invalidPayload, unsupportedVersion, cancelled
    public var message: String {
        switch self {
        case .missingClient: "Client not found. Choose its executable in the Hub."
        case .authenticationRequired: "Sign in using the original client."
        case .timeout: "The source did not respond in time."
        case .invalidPayload: "The source returned unsupported quota data."
        case .unsupportedVersion: "This source version is not supported."
        case .cancelled: "The source is disconnected."
        case .unavailable: "Quota is unavailable. No usage is inferred."
        }
    }
}

/// Vendor data is projected into quota-only entities. No identity, credits or transcript fields survive.
public enum UsageProjection {
    public static func codex(_ data: Data, now: Date) -> Result<UsageSnapshot, UsageFailure> {
        struct Response: Decodable { let rateLimits: Bucket? }
        struct Bucket: Decodable { let primary: Window?; let secondary: Window? }
        struct Window: Decodable { let usedPercent: Double; let windowDurationMins: Int?; let resetsAt: Double? }
        guard data.count <= 65536, let response = try? JSONDecoder().decode(Response.self, from: data), let bucket = response.rateLimits else { return .failure(.invalidPayload) }
        let windows = [bucket.primary, bucket.secondary].compactMap { value -> UsageWindow? in
            guard let value, let minutes = value.windowDurationMins else { return nil }
            return UsageWindow(minutes: minutes, usedPercent: value.usedPercent, resetsAt: value.resetsAt.map { Date(timeIntervalSince1970: $0) })
        }
        let snapshot = UsageSnapshot(provider: .codex, observedAt: now, windows: windows)
        return snapshot.isUsable(now: now) ? .success(snapshot) : .failure(.unavailable)
    }

    public static func claudeStatusline(_ data: Data, now: Date) -> Result<UsageSnapshot, UsageFailure> {
        struct Input: Decodable { let rate_limits: Limits? }
        struct Limits: Decodable { let five_hour: Window?; let seven_day: Window? }
        struct Window: Decodable { let used_percentage: Double; let resets_at: Double }
        guard data.count <= 131072, let input = try? JSONDecoder().decode(Input.self, from: data) else { return .failure(.invalidPayload) }
        let windows = [(300, input.rate_limits?.five_hour), (10080, input.rate_limits?.seven_day)].compactMap { minutes, value -> UsageWindow? in
            guard let value, value.resets_at > now.timeIntervalSince1970 else { return nil }
            return UsageWindow(minutes: minutes, usedPercent: value.used_percentage, resetsAt: Date(timeIntervalSince1970: value.resets_at))
        }
        let snapshot = UsageSnapshot(provider: .claude, observedAt: now, windows: windows)
        return snapshot.isUsable(now: now) ? .success(snapshot) : .failure(.unavailable)
    }
}
