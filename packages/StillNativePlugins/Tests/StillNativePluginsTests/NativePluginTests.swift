import Foundation
import Testing
@testable import StillNativePlugins

@Test func catalogIsTenDistinctOwnedPlugins() {
    #expect(NativePluginID.allCases.count == 10)
    #expect(Set(NativePluginID.allCases.map(\.id)).count == 10)
    #expect(NativePluginID.allCases.allSatisfy { $0.id.hasPrefix("co.mateonunez.still.") })
}
@Test func configurationsRejectIdentityVersionAndUnsafeSource() throws {
    var config = NativePluginConfiguration(plugin: .buildWatch)
    config.settings.repository = "mateonunez/still"
    let encoder = JSONEncoder()
    #expect(NativePluginConfiguration.decode(try encoder.encode(config), expected: .buildWatch) != nil)
    #expect(NativePluginConfiguration.decode(try encoder.encode(config), expected: .deployWatch) == nil)
    config.settings.repository = "--hostname/other"
    // A leading option cannot be mistaken for a CLI flag; repository is embedded in a fixed API path.
    #expect(config.settings.valid(for: .buildWatch))
    config.settings.repository = "mateonunez/still?per_page=100"
    #expect(NativePluginConfiguration.decode(try encoder.encode(config), expected: .buildWatch) == nil)
    config.settings.repository = "mateonunez/still"; config.schemaVersion = 3
    #expect(NativePluginConfiguration.decode(try encoder.encode(config), expected: .buildWatch) == nil)
}
@Test func settingsValidateCoordinatesTimeZonesAndDuration() {
    var settings = NativePluginSettings()
    settings.latitude = .nan; #expect(!settings.valid(for: .weather))
    settings.latitude = 91; #expect(!settings.valid(for: .weather))
    settings.latitude = 45; settings.timerMinutes = 0; #expect(!settings.valid(for: .quietTimer))
    settings.timerMinutes = 10; settings.clocks = [ClockLocation(name: "Home", timeZone: "not/a/zone")]; #expect(!settings.valid(for: .worldClock))
    settings.clocks = [ClockLocation(name: "Milan", timeZone: "Europe/Rome")]; #expect(settings.valid(for: .worldClock))
}
@Test func workflowProjectionDoesNotInventSuccess() {
    #expect(SourceProjection.github(Data(#"{"workflow_runs":[{"status":"completed","conclusion":"neutral"}]}"#.utf8))?.state == .unknown)
    #expect(SourceProjection.github(Data(#"{"workflow_runs":[{"status":"completed","conclusion":"failure"}]}"#.utf8))?.state == .failed)
    #expect(SourceProjection.github(Data(#"{"workflow_runs":[{"status":"in_progress"}]}"#.utf8))?.state == .working)
    #expect(SourceProjection.github(Data(#"{"workflow_runs":[]}"#.utf8)) == nil)
}
@Test func deploymentProjectionHandlesUnknownAndCanceled() {
    #expect(SourceProjection.vercel(Data(#"{"deployments":[{"state":"CANCELED"}]}"#.utf8))?.state == .canceled)
    #expect(SourceProjection.vercel(Data(#"{"deployments":[{"state":"READY"}]}"#.utf8))?.state == .completed)
    #expect(SourceProjection.vercel(Data(#"{"deployments":[{"state":"new-status"}]}"#.utf8))?.state == .unknown)
}
@Test func weatherUsesObservationAndRejectsStaleOrMalformed() throws {
    let now = Date(timeIntervalSince1970: 10000)
    var object: [String: Any] = ["current": ["temperature_2m": 20, "weather_code": 0, "time": 9900], "hourly": ["time": [9000, 11000], "precipitation_probability": [5, 20]]]
    let result = SourceProjection.weather(try JSONSerialization.data(withJSONObject: object), city: "Milan", now: now)
    #expect(result?.0.rainChance == 20 && result?.1 == Date(timeIntervalSince1970: 9900))
    object["current"] = ["temperature_2m": 20, "weather_code": 0, "time": 7000]
    #expect(SourceProjection.weather(try JSONSerialization.data(withJSONObject: object), city: "Milan", now: now) == nil)
    object["hourly"] = ["time": [9000, 11000], "precipitation_probability": [5]]
    #expect(SourceProjection.weather(try JSONSerialization.data(withJSONObject: object), city: "Milan", now: now) == nil)
}
@Test func cardExpiryRemovesPayload() {
    let now = Date(), card = NativePluginCard(.buildWatch, payload: .work([WorkFact(label: "Build", state: .completed)]), state: .ready, detail: "Live", observedAt: now, expiresAt: now.addingTimeInterval(30))
    #expect(card.current(now: now).payload != nil)
    #expect(card.current(now: now.addingTimeInterval(30)).payload == nil)
    #expect(card.current(now: now.addingTimeInterval(30)).state == .unavailable)
}
@Test func taskConnectionRevisionExpiryAndBounds() throws {
    let id = UUID(), now = Date(timeIntervalSince1970: 10000)
    var object: [String: Any] = ["protocolVersion": 2, "connectionID": id.uuidString, "revision": 2, "observedAt": "1970-01-01T02:46:40Z", "expiresAt": "1970-01-01T02:48:40Z", "tasks": [["label": "Build", "state": "working", "progress": 50]]]
    func data() throws -> Data { try JSONSerialization.data(withJSONObject: object) }
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now) != nil)
    #expect(TaskReceipt.decode(try data(), connectionID: UUID(), revision: 1, now: now) == nil)
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 2, now: now) == nil)
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now.addingTimeInterval(120)) == nil)
    object["tasks"] = [["label": "Build", "state": "working", "expiresAt": "1970-01-01T02:49:40Z"]]
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now) == nil)
    object["tasks"] = [["label": "Build", "state": "working", "progress": 101]]
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now) == nil)
    object["tasks"] = Array(repeating: ["label": "Build", "state": "working"], count: 5)
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now) == nil)
    object["tasks"] = [["label": "Build", "state": "working", "prompt": "must not cross this boundary"]]
    #expect(TaskReceipt.decode(try data(), connectionID: id, revision: 1, now: now) == nil)
}
@Test func storeRejectsSymlinkAndPreservesConfiguration() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), directory = root.appendingPathComponent("world-clock")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let store = NativePluginStore(root: root), config = NativePluginConfiguration(plugin: .worldClock)
    try store.write(config); #expect(store.configuration(.worldClock) == config)
    let path = directory.appendingPathComponent("configuration.json")
    try FileManager.default.removeItem(at: path)
    try FileManager.default.createSymbolicLink(at: path, withDestinationURL: root.appendingPathComponent("elsewhere"))
    #expect(store.configuration(.worldClock) == nil)
    #expect(throws: (any Error).self) { try store.write(config) }
}

@Test func freshConfigurationPreparationRejectsSymlinkRootWithoutWriting() throws {
    let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: base) }
    let target = base.appendingPathComponent("target"), link = base.appendingPathComponent("link")
    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
    #expect(throws: NativeStoreError.self) { try NativePluginStore(root: link).prepareMissingConfigurations() }
    #expect(try FileManager.default.contentsOfDirectory(atPath: target.path).isEmpty)
}
