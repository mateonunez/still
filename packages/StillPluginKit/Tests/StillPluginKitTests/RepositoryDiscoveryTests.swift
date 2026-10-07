import Foundation
import Testing
@testable import StillPluginKit

private func fixture(_ body: (URL) throws -> Void) throws {
    let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    try body(root)
}
private func package(_ root: URL, _ path: String, id: String = "app.still.example", protocolVersion: Int = 1) throws {
    let directory = root.appendingPathComponent(path)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let manifest = """
    {"schemaVersion":1,"protocolVersion":\(protocolVersion),"id":"\(id)","version":"1.0.0","name":"Example","publisher":"Example","license":"MIT","kind":"metadata","capabilities":["quota"],"widgets":[{"id":"quota","kind":"quota","provider":"local"}],"template":{"theme":"porcelain","layout":"corner"}}
    """
    try Data(manifest.utf8).write(to: directory.appendingPathComponent("manifest.json"))
}
private func index(_ root: URL, _ paths: [String]) throws {
    try JSONSerialization.data(withJSONObject: ["schemaVersion": 1, "packages": paths]).write(to: root.appendingPathComponent("still.plugins.json"))
}
@Test func discoveryReportsCompatibilityWithoutModifyingRepository() throws {
    try fixture { root in
        try package(root, "plugins/Good.stillplugin")
        try package(root, "Bad.stillplugin", protocolVersion: 99)
        let report = try RepositoryDiscovery.inspect(root)
        #expect(report.candidates.map(\.path) == ["Bad.stillplugin", "plugins/Good.stillplugin"])
        #expect(report.candidates[0].error == "unsupportedVersion")
        #expect(report.candidates[1].compatible)
        #expect(!report.compatible && report.actionsTaken.isEmpty)
        let json = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(report)) as? [String: Any])
        #expect(json["compatible"] as? Bool == false)
        let candidates = try #require(json["candidates"] as? [[String: Any]])
        #expect(candidates[1]["compatible"] as? Bool == true)
        #expect(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent("plugins/Good.stillplugin").path) == ["manifest.json"])
    }
}
@Test func indexSelectsNestedPackagesAndRejectsDuplicateIDs() throws {
    try fixture { root in
        try package(root, "nested/A.stillplugin")
        try package(root, "nested/B.stillplugin")
        try index(root, ["nested/B.stillplugin", "nested/A.stillplugin"])
        let report = try RepositoryDiscovery.inspect(root)
        #expect(report.candidates.count == 2)
        #expect(report.candidates[0].compatible)
        #expect(report.candidates[1].error == "conflict")
        #expect(!report.compatible)
    }
}
@Test func indexRejectsTraversalDuplicatesAndLinkedAncestors() throws {
    try fixture { root in
        for paths in [["../Escape.stillplugin"], ["A.stillplugin", "A.stillplugin"], ["/A.stillplugin"], ["nested//A.stillplugin"]] {
            try index(root, paths)
            #expect(throws: (any Error).self) { try RepositoryDiscovery.inspect(root) }
        }
        try package(root, "real/A.stillplugin")
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("linked"), withDestinationURL: root.appendingPathComponent("real"))
        try index(root, ["linked/A.stillplugin"])
        #expect(try RepositoryDiscovery.inspect(root).candidates[0].error == "unsafePath")
    }
}
@Test func executableAndOversizedPackagesAreIncompatibleAndEmptyIsNotCompatible() throws {
    try fixture { root in
        #expect(try !RepositoryDiscovery.inspect(root).compatible)
        try package(root, "Executable.stillplugin")
        try Data("do not run".utf8).write(to: root.appendingPathComponent("Executable.stillplugin/run.sh"))
        #expect(try RepositoryDiscovery.inspect(root).candidates[0].error == "unsafeFile")
        try FileManager.default.removeItem(at: root.appendingPathComponent("Executable.stillplugin/run.sh"))
        try Data(repeating: 32, count: 32769).write(to: root.appendingPathComponent("Executable.stillplugin/manifest.json"))
        #expect(try RepositoryDiscovery.inspect(root).candidates[0].error == "oversized")
    }
}
@Test func discoveryBoundsCandidatesAndIndexSize() throws {
    try fixture { root in
        for number in 0..<33 { try package(root, "A\(number).stillplugin", id: "app.still.a\(number)") }
        #expect(throws: RepositoryDiscoveryError.discoveryLimit) { try RepositoryDiscovery.inspect(root) }
        try Data(repeating: 32, count: 32769).write(to: root.appendingPathComponent("still.plugins.json"))
        #expect(throws: PluginError.oversized) { try RepositoryDiscovery.inspect(root) }
    }
}

@Test func indexVersionAndUnknownFieldsFailExplicitly() throws {
    try fixture { root in
        for (text, error) in [
            ("{\"schemaVersion\":2,\"packages\":[\"A.stillplugin\"]}", RepositoryDiscoveryError.unsupportedIndexVersion),
            ("{\"schemaVersion\":true,\"packages\":[\"A.stillplugin\"]}", .invalidIndex),
            ("{\"schemaVersion\":1,\"packages\":[\"A.stillplugin\"],\"command\":\"sh\"}", .invalidIndex),
            ("not json", .invalidIndex)
        ] {
            try Data(text.utf8).write(to: root.appendingPathComponent("still.plugins.json"))
            #expect(throws: error) { try RepositoryDiscovery.inspect(root) }
        }
    }
}

@Test func discoveryRejectsLinkedPackagesAndBoundsImmediateScan() throws {
    try fixture { root in
        try package(root, "real/A.stillplugin")
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("Linked.stillplugin"),
            withDestinationURL: root.appendingPathComponent("real/A.stillplugin"))
        #expect(try RepositoryDiscovery.inspect(root).candidates[0].error == "unsafePath")
        try FileManager.default.removeItem(at: root.appendingPathComponent("Linked.stillplugin"))
        for number in 0..<128 {
            try Data().write(to: root.appendingPathComponent("unrelated-\(number)"))
        }
        #expect(throws: RepositoryDiscoveryError.discoveryLimit) { try RepositoryDiscovery.inspect(root) }
    }
}
