import Foundation

public enum NativePluginID: String, Codable, CaseIterable, Sendable, Identifiable {
    case agents, buildWatch = "build-watch", deployWatch = "deploy-watch", taskWatch = "task-watch", macPulse = "mac-pulse", nextUp = "next-up", worldClock = "world-clock", quietTimer = "quiet-timer", weather, spotify
    public var id: String { "co.mateonunez.still." + rawValue }
    public var title: String {
        switch self { case .agents: "Agents"; case .buildWatch: "Build Watch"; case .deployWatch: "Deploy Watch"; case .taskWatch: "Task Watch"; case .macPulse: "Mac Pulse"; case .nextUp: "Next Up"; case .worldClock: "World Clock"; case .quietTimer: "Quiet Timer"; case .weather: "Weather"; case .spotify: "Spotify" }
    }
    public var symbol: String {
        switch self { case .agents: "sparkles"; case .buildWatch: "checkmark.circle"; case .deployWatch: "cloud"; case .taskWatch: "terminal"; case .macPulse: "waveform.path.ecg"; case .nextUp: "calendar"; case .worldClock: "globe"; case .quietTimer: "hourglass"; case .weather: "cloud.sun"; case .spotify: "music.note" }
    }
    public var summary: String {
        switch self {
        case .agents: "Installed agents, account quota and advisory activity."
        case .buildWatch: "The latest workflow in a repository you choose."
        case .deployWatch: "Deployment status for one Vercel project."
        case .taskWatch: "Local tasks you explicitly register."
        case .macPulse: "CPU activity, memory pressure and power."
        case .nextUp: "Your next event, with titles hidden unless you choose."
        case .worldClock: "A few places that matter to you."
        case .quietTimer: "A little time to focus or take a break."
        case .weather: "Current conditions and the chance of rain."
        case .spotify: "Now playing from your local Spotify app."
        }
    }
    public var refreshSeconds: TimeInterval {
        switch self { case .worldClock, .quietTimer, .agents: 1; case .macPulse: 3; case .spotify: 15; case .taskWatch: 5; case .nextUp: 60; case .buildWatch, .deployWatch: 120; case .weather: 900 }
    }
}

public struct ClockLocation: Codable, Equatable, Sendable {
    public var name: String
    public var timeZone: String
    public init(name: String, timeZone: String) { self.name = name; self.timeZone = timeZone }
}

public struct NativePluginSettings: Codable, Equatable, Sendable {
    public var repository = ""
    public var projectID = ""
    public var teamID = ""
    public var scope = ""
    public var city = ""
    public var latitude: Double = 0
    public var longitude: Double = 0
    public var clocks: [ClockLocation] = [ClockLocation(name: "Local", timeZone: TimeZone.current.identifier)]
    public var timerMinutes = 10
    public var calendarID = ""
    public var showTitles = false
    public var showCPU = true
    public var showMemory = true
    public var showBattery = true
    public var showCompletedTasks = true
    public var spotifyAuthorized = false
    public init() {}
    private enum CodingKeys: String, CodingKey { case repository, projectID, teamID, scope, city, latitude, longitude, clocks, timerMinutes, calendarID, showTitles, showCPU, showMemory, showBattery, showCompletedTasks, spotifyAuthorized }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        repository = try container.decodeIfPresent(String.self, forKey: .repository) ?? ""
        projectID = try container.decodeIfPresent(String.self, forKey: .projectID) ?? ""
        teamID = try container.decodeIfPresent(String.self, forKey: .teamID) ?? ""
        scope = try container.decodeIfPresent(String.self, forKey: .scope) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        clocks = try container.decodeIfPresent([ClockLocation].self, forKey: .clocks) ?? [ClockLocation(name: "Local", timeZone: TimeZone.current.identifier)]
        timerMinutes = try container.decodeIfPresent(Int.self, forKey: .timerMinutes) ?? 10
        calendarID = try container.decodeIfPresent(String.self, forKey: .calendarID) ?? ""
        showTitles = try container.decodeIfPresent(Bool.self, forKey: .showTitles) ?? false
        showCPU = try container.decodeIfPresent(Bool.self, forKey: .showCPU) ?? true
        showMemory = try container.decodeIfPresent(Bool.self, forKey: .showMemory) ?? true
        showBattery = try container.decodeIfPresent(Bool.self, forKey: .showBattery) ?? true
        showCompletedTasks = try container.decodeIfPresent(Bool.self, forKey: .showCompletedTasks) ?? true
        spotifyAuthorized = try container.decodeIfPresent(Bool.self, forKey: .spotifyAuthorized) ?? false
    }
    public func valid(for id: NativePluginID) -> Bool {
        guard timerMinutes >= 1, timerMinutes <= 240, clocks.count >= 1, clocks.count <= 3,
              clocks.allSatisfy({ safeText($0.name, limit: 32) && TimeZone(identifier: $0.timeZone) != nil }),
              latitude.isFinite, longitude.isFinite, abs(latitude) <= 90, abs(longitude) <= 180,
              safeText(city, limit: 64, allowEmpty: true), safeText(calendarID, limit: 256, allowEmpty: true) else { return false }
        switch id {
        case .buildWatch: return repository.isEmpty || repository.range(of: "^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", options: .regularExpression) != nil && repository.utf8.count <= 160
        case .deployWatch: return [projectID, teamID, scope].allSatisfy { $0.isEmpty || $0.range(of: "^[A-Za-z0-9_-]{1,96}$", options: .regularExpression) != nil }
        default: return true
        }
    }
}

public struct NativePluginConfiguration: Codable, Equatable, Sendable {
    public var schemaVersion = 2
    public var plugin: NativePluginID
    public var enabled = false
    public var visible = false
    public var settings = NativePluginSettings()
    public init(plugin: NativePluginID) { self.plugin = plugin }
    public static func decode(_ data: Data, expected: NativePluginID) -> NativePluginConfiguration? {
        guard data.count <= 16384, let value = try? JSONDecoder().decode(Self.self, from: data), value.schemaVersion == 2, value.plugin == expected, value.settings.valid(for: expected) else { return nil }
        return value
    }
}

public enum NativeSourceState: String, Codable, Sendable { case ready, refreshing, unavailable, permissionRequired, setupRequired, paused }
public enum WorkState: String, Codable, Sendable { case queued, working, completed, failed, canceled, unknown }
public struct WorkFact: Codable, Equatable, Sendable {
    public let label: String
    public let state: WorkState
    public let startedAt: Date?
    public let progress: Double?
    public let expiresAt: Date?
    public init(label: String, state: WorkState, startedAt: Date? = nil, progress: Double? = nil, expiresAt: Date? = nil) { self.label = label; self.state = state; self.startedAt = startedAt; self.progress = progress; self.expiresAt = expiresAt }
}
public struct MetricFact: Codable, Equatable, Sendable {
    public let label: String
    public let value: String
    public init(_ label: String, _ value: String) { self.label = label; self.value = value }
}
public struct AgendaFact: Codable, Equatable, Sendable {
    public let title: String
    public let startsAt: Date
    public init(title: String, startsAt: Date) { self.title = title; self.startsAt = startsAt }
}
public struct WeatherFact: Codable, Equatable, Sendable {
    public let city: String
    public let temperature: Double
    public let condition: String
    public let rainChance: Double?
    public init(city: String, temperature: Double, condition: String, rainChance: Double?) { self.city = city; self.temperature = temperature; self.condition = condition; self.rainChance = rainChance }
}
public struct PlaybackFact: Codable, Equatable, Sendable {
    public let title: String
    public let artist: String
    public let playing: Bool
    public init(title: String, artist: String, playing: Bool) { self.title = title; self.artist = artist; self.playing = playing }
}
public enum NativePayload: Equatable, Sendable {
    case metrics([MetricFact]), work([WorkFact]), agenda(AgendaFact?), clocks([ClockLocation]), timer(deadline: TimeInterval?), weather(WeatherFact), playback(PlaybackFact), agents([MetricFact])
}
public struct NativePluginCard: Identifiable, Equatable, Sendable {
    public let plugin: NativePluginID
    public let payload: NativePayload?
    public let state: NativeSourceState
    public let detail: String
    public let observedAt: Date?
    public let expiresAt: Date?
    public var id: NativePluginID { plugin }
    public init(_ plugin: NativePluginID, payload: NativePayload? = nil, state: NativeSourceState, detail: String, observedAt: Date? = nil, expiresAt: Date? = nil) {
        self.plugin = plugin; self.payload = payload; self.state = state; self.detail = detail; self.observedAt = observedAt; self.expiresAt = expiresAt
    }
    public func current(now: Date) -> Self {
        guard let expiresAt, expiresAt <= now else { return self }
        return Self(plugin, state: .unavailable, detail: "Source data expired. Refresh or check its connection.")
    }
}

public struct TaskReceipt: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let connectionID: UUID
    public let revision: UInt64
    public let observedAt: Date
    public let expiresAt: Date
    public let tasks: [WorkFact]
    public static func decode(_ data: Data, connectionID: UUID, revision: UInt64, now: Date) -> Self? {
        guard data.count <= 16384, let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              Set(object.keys) == ["protocolVersion", "connectionID", "revision", "observedAt", "expiresAt", "tasks"],
              let tasks = object["tasks"] as? [[String: Any]], tasks.allSatisfy({ Set($0.keys).isSubset(of: ["label", "state", "startedAt", "progress", "expiresAt"]) }) else { return nil }
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        guard data.count <= 16384, let value = try? decoder.decode(Self.self, from: data), value.protocolVersion == 2,
              value.connectionID == connectionID, value.revision > revision, value.revision <= 9007199254740991,
              value.observedAt <= now.addingTimeInterval(5), value.expiresAt > now, value.expiresAt > value.observedAt,
              value.expiresAt.timeIntervalSince(value.observedAt) <= 300, now.timeIntervalSince(value.observedAt) <= 300,
              value.tasks.count <= 4, value.tasks.allSatisfy({ safeText($0.label, limit: 64) && ($0.progress.map { $0.isFinite && (0...100).contains($0) } ?? true) && ($0.startedAt.map { $0 <= now.addingTimeInterval(5) } ?? true) && ($0.expiresAt.map { $0 <= value.expiresAt } ?? true) }) else { return nil }
        return value
    }
}

public func safeText(_ text: String, limit: Int, allowEmpty: Bool = false) -> Bool {
    (allowEmpty || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) && text.count <= limit && !text.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) || (0x202A...0x202E).contains($0.value) || (0x2066...0x2069).contains($0.value) }
}
