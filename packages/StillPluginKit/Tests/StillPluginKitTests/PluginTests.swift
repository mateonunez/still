import Foundation
import Testing
@testable import StillPluginKit

private func manifestData(kind: String = "metadata", provider: String = "local") -> Data {
    Data("""
    {"schemaVersion":1,"protocolVersion":1,"id":"app.meet-still.example","version":"1.0.0","name":"Example","publisher":"Example author","license":"MIT","kind":"\(kind)","capabilities":["quota","agentActivity"],"widgets":[{"id":"quota","kind":"quota","provider":"\(provider)"},{"id":"agent","kind":"agentActivity","provider":"\(provider)"}],"template":{"theme":"porcelain","layout":"corner"}}
    """.utf8)
}
private let now = Date(timeIntervalSince1970: 1800000000)
private func envelope(_ connection: PluginConnection, revision: Int = 1, facts: String = "[]", observed: Date = now, expires: Date = now.addingTimeInterval(120)) -> Data {
    Data("""
    {"protocolVersion":1,"pluginID":"\(connection.pluginID)","connectionID":"\(connection.connectionID)","revision":\(revision),"observedAt":"\(observed.ISO8601Format())","expiresAt":"\(expires.ISO8601Format())","isSample":true,"facts":\(facts)}
    """.utf8)
}
@Test func strictManifestRejectsUnknownExecutableAndTraversal() throws {
    let text = String(decoding: manifestData(), as: UTF8.self)
    for bad in [text.replacingOccurrences(of: "app.meet-still.example", with: "../../evil"), text.replacingOccurrences(of: "\"schemaVersion\":1", with: "\"schemaVersion\":1,\"command\":\"sh\""), text.replacingOccurrences(of: "\"schemaVersion\":1", with: "\"schemaVersion\":2")] {
        #expect(throws: PluginError.self) { try PluginManifest.decode(Data(bad.utf8)).get() }
    }
}
@Test func templateCannotGrantLocalSourceOrUnsupportedTheme() {
    if case .success = PluginManifest.decode(manifestData(kind: "template")) { Issue.record("Template accepted local source") }
    #expect(throws: PluginError.self) { try PluginManifest.decode(Data(String(decoding: manifestData(), as: UTF8.self).replacingOccurrences(of: "porcelain", with: "script").utf8)).get() }
}
@Test func snapshotValidatesPermissionsAndRejectsPrivateFields() throws {
    let manifest = try PluginManifest.decode(manifestData()).get(), connection = PluginConnection(manifest: manifest)
    var session = PluginSession(manifest: manifest, connection: connection)
    let fact = "{\"widgetID\":\"agent\",\"kind\":\"agentActivity\",\"state\":\"attentionRequested\",\"count\":1}"
    #expect(try session.accept(envelope(connection, facts: "[\(fact)]"), now: now, uptime: 10).get().facts.count == 1)
    #expect(throws: PluginError.self) { try session.accept(envelope(connection, revision: 2, facts: "[\(fact.dropLast()),\"prompt\":\"private\"}]"), now: now, uptime: 11).get() }
    let wrongWidget = fact.replacingOccurrences(of: "\"agent\"", with: "\"undeclared\"")
    #expect(throws: PluginError.self) { try session.accept(envelope(connection, revision: 2, facts: "[\(wrongWidget)]"), now: now, uptime: 11).get() }
}
@Test func reconnectRejectsOldConnectionAndRevision() throws {
    let manifest = try PluginManifest.decode(manifestData()).get(), first = PluginConnection(manifest: manifest)
    var session = PluginSession(manifest: manifest, connection: first)
    _ = try session.accept(envelope(first), now: now, uptime: 10).get()
    #expect(throws: PluginError.self) { try session.accept(envelope(first), now: now, uptime: 11).get() }
    let next = PluginConnection(manifest: manifest)
    session = PluginSession(manifest: manifest, connection: next)
    #expect(throws: PluginError.self) { try session.accept(envelope(first, revision: 2), now: now, uptime: 11).get() }
    _ = try session.accept(envelope(next), now: now, uptime: 11).get()
}
@Test func freshnessUsesMonotonicDeadlineAndEmptySnapshotRemovesAttention() throws {
    let manifest = try PluginManifest.decode(manifestData()).get(), connection = PluginConnection(manifest: manifest)
    var session = PluginSession(manifest: manifest, connection: connection)
    let fact = "[{\"widgetID\":\"agent\",\"kind\":\"agentActivity\",\"state\":\"attentionRequested\",\"count\":1}]"
    _ = try session.accept(envelope(connection, facts: fact), now: now, uptime: 20).get()
    #expect(session.current(uptime: 139) != nil)
    #expect(session.current(uptime: 140) == nil)
    _ = try session.accept(envelope(connection, revision: 2), now: now, uptime: 141).get()
    #expect(session.current(uptime: 142)?.facts.isEmpty == true)
    #expect(throws: PluginError.self) { try session.accept(envelope(connection, revision: 3, observed: now.addingTimeInterval(60)), now: now, uptime: 142).get() }
}
@Test func missingQuotaCannotBecomeZeroAndInputIsBounded() throws {
    let manifest = try PluginManifest.decode(manifestData()).get(), connection = PluginConnection(manifest: manifest)
    var session = PluginSession(manifest: manifest, connection: connection)
    for facts in ["[{\"widgetID\":\"quota\",\"kind\":\"quota\",\"windows\":[]}]", "[{\"widgetID\":\"quota\",\"kind\":\"quota\",\"windows\":[{\"minutes\":300,\"usedPercent\":101}]}]"] {
        #expect(throws: PluginError.self) { try session.accept(envelope(connection, facts: facts), now: now, uptime: 10).get() }
    }
    #expect(throws: PluginError.self) { try session.accept(Data(repeating: 32, count: 65537), now: now, uptime: 10).get() }
}
@Test func importDoesNotExecuteOrEnableAndDisconnectRevokes() throws {
    let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: temporary) }
    let source = temporary.appendingPathComponent("Example.stillplugin"), root = temporary.appendingPathComponent("installed")
    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try manifestData().write(to: source.appendingPathComponent("manifest.json"))
    let store = PluginStore(root: root), manifest = try store.importPackage(source)
    #expect(store.list() == [manifest])
    let config = root.appendingPathComponent(manifest.id).appendingPathComponent("connection.json")
    #expect(!FileManager.default.fileExists(atPath: config.path))
    let first = try store.connect(manifest)
    try store.disconnect(manifest.id)
    #expect(!FileManager.default.fileExists(atPath: config.path))
    #expect(try store.connect(manifest).connectionID != first.connectionID)
    #expect(throws: PluginError.self) { try store.importPackage(source) }
}
@Test func importRejectsSymlinksAndExecutablePackageContent() throws {
    let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: temporary) }
    let source = temporary.appendingPathComponent("Example.stillplugin")
    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    let data = temporary.appendingPathComponent("manifest.json")
    try manifestData().write(to: data)
    try FileManager.default.createSymbolicLink(at: source.appendingPathComponent("manifest.json"), withDestinationURL: data)
    let store = PluginStore(root: temporary.appendingPathComponent("installed"))
    #expect(throws: PluginError.self) { try store.importPackage(source) }
    try FileManager.default.removeItem(at: source.appendingPathComponent("manifest.json"))
    try manifestData().write(to: source.appendingPathComponent("manifest.json"))
    try Data("echo bad".utf8).write(to: source.appendingPathComponent("run.sh"))
    #expect(throws: PluginError.self) { try store.importPackage(source) }
}
