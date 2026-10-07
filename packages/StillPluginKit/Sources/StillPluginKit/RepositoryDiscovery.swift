import Foundation

public enum RepositoryDiscoveryError: String, Error, Sendable {
    case invalidIndex, unsupportedIndexVersion, unsafePath, discoveryLimit, unreadableRepository
}

public struct RepositoryCandidate: Encodable, Sendable {
    public let path: String
    public let manifest: PluginManifest?
    public let error: String?
    public var compatible: Bool { manifest != nil && error == nil }
    private enum CodingKeys: String, CodingKey { case path, manifest, error, compatible }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encodeIfPresent(manifest, forKey: .manifest)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encode(compatible, forKey: .compatible)
    }
}

public struct RepositoryInspection: Encodable, Sendable {
    public let schemaVersion: Int
    public let candidates: [RepositoryCandidate]
    public let actionsTaken: [String]
    public var compatible: Bool { !candidates.isEmpty && candidates.allSatisfy(\.compatible) }
    private enum CodingKeys: String, CodingKey { case schemaVersion, candidates, actionsTaken, compatible }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(candidates, forKey: .candidates)
        try container.encode(actionsTaken, forKey: .actionsTaken)
        try container.encode(compatible, forKey: .compatible)
    }
}

/// Bounded local discovery only. This never fetches, executes or installs a repository.
public enum RepositoryDiscovery {
    public static func inspect(_ source: URL) throws -> RepositoryInspection {
        let root = source.standardizedFileURL
        try directory(root)
        let paths: [String]
        if root.pathExtension == "stillplugin" {
            paths = ["."]
        } else {
            let index = root.appendingPathComponent("still.plugins.json")
            if exists(index) {
                let data = try readBounded(index, limit: 32768)
                guard let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                      Set(object.keys) == ["schemaVersion", "packages"],
                      let version = object["schemaVersion"] as? NSNumber,
                      String(cString: version.objCType) != "c" else {
                    throw RepositoryDiscoveryError.invalidIndex
                }
                guard version.doubleValue == 1 else { throw RepositoryDiscoveryError.unsupportedIndexVersion }
                guard let packages = object["packages"] as? [String], !packages.isEmpty,
                      packages.count <= 32, Set(packages).count == packages.count else {
                    throw RepositoryDiscoveryError.invalidIndex
                }
                for path in packages { try relativePath(path) }
                paths = packages.sorted()
            } else {
                var found = try children(root).filter { $0.hasSuffix(".stillplugin") }
                let plugins = root.appendingPathComponent("plugins")
                if exists(plugins) {
                    try directory(plugins)
                    found += try children(plugins).filter { $0.hasSuffix(".stillplugin") }.map { "plugins/\($0)" }
                }
                guard found.count <= 32 else { throw RepositoryDiscoveryError.discoveryLimit }
                paths = found.sorted()
            }
        }
        var ids = Set<String>()
        let candidates = paths.map { path -> RepositoryCandidate in
            do {
                let target = path == "." ? root : try contained(path, in: root)
                let manifest = try PluginStore.inspectPackage(target)
                guard ids.insert(manifest.id).inserted else { throw PluginError.conflict }
                return RepositoryCandidate(path: path, manifest: manifest, error: nil)
            } catch {
                return RepositoryCandidate(path: path, manifest: nil, error: code(error))
            }
        }
        return RepositoryInspection(schemaVersion: 1, candidates: candidates, actionsTaken: [])
    }

    public static func code(_ error: Error) -> String {
        (error as? RepositoryDiscoveryError)?.rawValue ?? (error as? PluginError)?.rawValue ?? "unreadableRepository"
    }

    private static func relativePath(_ path: String) throws {
        let parts = path.split(separator: "/", omittingEmptySubsequences: false)
        guard path.utf8.count <= 256, !parts.isEmpty, parts.count <= 8,
              parts.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }),
              path.hasSuffix(".stillplugin"), !path.contains("\\"),
              !path.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw RepositoryDiscoveryError.unsafePath
        }
    }

    private static func contained(_ path: String, in root: URL) throws -> URL {
        try relativePath(path)
        var target = root
        for component in path.split(separator: "/") {
            target.appendPathComponent(String(component))
            try directory(target)
        }
        return target
    }

    private static func directory(_ url: URL) throws {
        let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true,
              url.resolvingSymlinksInPath().path == url.standardizedFileURL.path else {
            throw RepositoryDiscoveryError.unsafePath
        }
    }

    private static func children(_ url: URL) throws -> [String] {
        var failure: Error?
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants], errorHandler: { _, error in
                failure = error
                return false
            }) else { throw RepositoryDiscoveryError.unreadableRepository }
        var names: [String] = []
        for case let child as URL in enumerator {
            guard names.count < 128 else { throw RepositoryDiscoveryError.discoveryLimit }
            names.append(child.lastPathComponent)
        }
        if let failure { throw failure }
        return names
    }

    private static func exists(_ url: URL) -> Bool {
        (try? FileManager.default.attributesOfItem(atPath: url.path)) != nil
    }
}
