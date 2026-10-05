import Foundation

public enum PluginCapability: String, Codable, CaseIterable, Sendable { case quota, agentActivity }
public enum PluginProvider: String, Codable, Sendable { case codex, claude, local }
public enum PluginLayout: String, Codable, Sendable { case corner, rail }
public enum PluginError: String, Error, Sendable {
    case invalidManifest, unsupportedVersion, oversized, unsafeFile, invalidSnapshot, permissionDenied, stale, wrongConnection, oldRevision, conflict, storageUnavailable
}

public struct PluginWidget: Codable, Equatable, Sendable {
    public let id: String
    public let kind: PluginCapability
    public let provider: PluginProvider
}

public struct PluginTemplate: Codable, Equatable, Sendable {
    public let theme: String
    public let layout: PluginLayout
}

public struct PluginManifest: Codable, Equatable, Sendable, Identifiable {
    public let schemaVersion: Int
    public let protocolVersion: Int
    public let id: String
    public let version: String
    public let name: String
    public let publisher: String
    public let license: String
    public let kind: String
    public let capabilities: [PluginCapability]
    public let widgets: [PluginWidget]
    public let template: PluginTemplate

    public static func decode(_ data: Data) -> Result<Self, PluginError> {
        guard data.count <= 32768 else { return .failure(.oversized) }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              Set(object.keys) == Set(["schemaVersion", "protocolVersion", "id", "version", "name", "publisher", "license", "kind", "capabilities", "widgets", "template"]),
              let widgets = object["widgets"] as? [[String: Any]], widgets.allSatisfy({ Set($0.keys) == Set(["id", "kind", "provider"]) }),
              let template = object["template"] as? [String: Any], Set(template.keys) == Set(["theme", "layout"]),
              let manifest = try? JSONDecoder().decode(Self.self, from: data) else { return .failure(.invalidManifest) }
        guard manifest.schemaVersion == 1, manifest.protocolVersion == 1 else { return .failure(.unsupportedVersion) }
        guard matches(manifest.id, "^[a-z][a-z0-9]*(\\.[a-z][a-z0-9-]*){2,}$", limit: 96),
              matches(manifest.version, "^[0-9]+\\.[0-9]+\\.[0-9]+$", limit: 32),
              safeLabel(manifest.name, limit: 48), safeLabel(manifest.publisher, limit: 80),
              ["MIT", "Apache-2.0", "BSD-3-Clause", "CC0-1.0"].contains(manifest.license),
              ["template", "metadata"].contains(manifest.kind), manifest.template.theme == "porcelain",
              !manifest.widgets.isEmpty, manifest.widgets.count <= 4,
              Set(manifest.widgets.map(\.id)).count == manifest.widgets.count,
              Set(manifest.capabilities).count == manifest.capabilities.count,
              manifest.widgets.allSatisfy({ matches($0.id, "^[a-z][a-z0-9-]*$", limit: 48) && manifest.capabilities.contains($0.kind) }),
              manifest.kind != "template" || manifest.widgets.allSatisfy({ $0.provider != .local }),
              manifest.kind != "metadata" || manifest.widgets.allSatisfy({ $0.provider == .local }) else { return .failure(.invalidManifest) }
        return .success(manifest)
    }
}

public enum AgentState: String, Codable, CaseIterable, Sendable { case working, attentionRequested, completed, interrupted, failed, unknown }
public struct PluginQuotaWindow: Codable, Equatable, Sendable {
    public let minutes: Int
    public let usedPercent: Double
    public let resetsAt: String?
}
public struct PluginFact: Codable, Equatable, Sendable {
    public let widgetID: String
    public let kind: PluginCapability
    public let windows: [PluginQuotaWindow]?
    public let state: AgentState?
    public let count: Int?
}
public struct PluginSnapshot: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let pluginID: String
    public let connectionID: UUID
    public let revision: UInt64
    public let observedAt: String
    public let expiresAt: String
    public let isSample: Bool
    public let facts: [PluginFact]
}
public struct PluginConnection: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let pluginID: String
    public let connectionID: UUID
    public let capabilities: [PluginCapability]
    public init(manifest: PluginManifest) {
        protocolVersion = 1; pluginID = manifest.id; connectionID = UUID(); capabilities = manifest.capabilities
    }
}

/// A full snapshot replaces all earlier facts. The host retains only validated facts.
public struct PluginSession: Sendable {
    public let manifest: PluginManifest
    public let connection: PluginConnection
    public private(set) var snapshot: PluginSnapshot?
    private var revision: UInt64 = 0
    private var deadline: TimeInterval = 0
    public init(manifest: PluginManifest, connection: PluginConnection) { self.manifest = manifest; self.connection = connection }

    public mutating func accept(_ data: Data, now: Date, uptime: TimeInterval) -> Result<PluginSnapshot, PluginError> {
        guard data.count <= 65536 else { return .failure(.oversized) }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              Set(object.keys) == Set(["protocolVersion", "pluginID", "connectionID", "revision", "observedAt", "expiresAt", "isSample", "facts"]),
              let rawFacts = object["facts"] as? [[String: Any]], rawFacts.allSatisfy({ fact in
                  let required: Set<String> = ["widgetID", "kind"]
                  let allowed: Set<String> = fact["kind"] as? String == "quota" ? ["widgetID", "kind", "windows"] : ["widgetID", "kind", "state", "count"]
                  guard required.isSubset(of: Set(fact.keys)), Set(fact.keys).isSubset(of: allowed) else { return false }
                  if let windows = fact["windows"] as? [[String: Any]] {
                      return windows.allSatisfy { Set($0.keys).isSubset(of: ["minutes", "usedPercent", "resetsAt"]) && Set(["minutes", "usedPercent"]).isSubset(of: Set($0.keys)) }
                  }
                  return fact["kind"] as? String != "quota"
              }), let value = try? JSONDecoder().decode(PluginSnapshot.self, from: data) else { return .failure(.invalidSnapshot) }
        guard value.protocolVersion == 1 else { return .failure(.unsupportedVersion) }
        guard value.pluginID == manifest.id, value.connectionID == connection.connectionID else { return .failure(.wrongConnection) }
        guard value.revision > revision, value.revision <= 9007199254740991 else { return .failure(.oldRevision) }
        guard let observed = wireDate(value.observedAt), let expires = wireDate(value.expiresAt),
              observed <= now.addingTimeInterval(5), now.timeIntervalSince(observed) <= 300,
              expires > now, expires > observed, expires.timeIntervalSince(observed) <= 300 else { return .failure(.stale) }
        guard value.facts.count <= 4, Set(value.facts.map(\.widgetID)).count == value.facts.count else { return .failure(.invalidSnapshot) }
        for fact in value.facts {
            guard let widget = manifest.widgets.first(where: { $0.id == fact.widgetID }), widget.kind == fact.kind,
                  widget.provider == .local, connection.capabilities.contains(fact.kind) else { return .failure(.permissionDenied) }
            switch fact.kind {
            case .quota:
                guard let windows = fact.windows, (1...2).contains(windows.count), windows.allSatisfy({
                    (1...44640).contains($0.minutes) && $0.usedPercent.isFinite && (0...100).contains($0.usedPercent) && ($0.resetsAt.map { wireDate($0).map { $0 > now } ?? false } ?? true)
                }) else { return .failure(.invalidSnapshot) }
            case .agentActivity:
                guard fact.state != nil, let count = fact.count, (0...64).contains(count) else { return .failure(.invalidSnapshot) }
            }
        }
        revision = value.revision; snapshot = value
        deadline = uptime + min(300, expires.timeIntervalSince(now))
        return .success(value)
    }

    public func current(uptime: TimeInterval) -> PluginSnapshot? { uptime < deadline ? snapshot : nil }
    public mutating func clear() { snapshot = nil; deadline = 0 }
}

public func wireDate(_ value: String) -> Date? {
    guard value.count <= 40 else { return nil }
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: value) { return date }
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter.date(from: value)
}

private func matches(_ value: String, _ pattern: String, limit: Int) -> Bool { value.utf8.count <= limit && value.range(of: pattern, options: .regularExpression) != nil }
private func safeLabel(_ value: String, limit: Int) -> Bool { !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value.count <= limit && !value.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) || (0x202A...0x202E).contains($0.value) || (0x2066...0x2069).contains($0.value) } }
