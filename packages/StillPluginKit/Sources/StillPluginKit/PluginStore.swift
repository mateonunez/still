import Foundation
import Darwin

/// Imports one bounded declarative manifest, never package code or symlinks.
public struct PluginStore: Sendable {
    public let root: URL
    public init(root: URL) { self.root = root }

    public func list() -> [PluginManifest] {
        guard (try? safeDirectory(root)) != nil else { return [] }
        let urls = (try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
        return urls.compactMap { url in
            guard (try? safeDirectory(url)) != nil,
                  let data = try? readBounded(url.appendingPathComponent("manifest.json"), limit: 32768),
                  case .success(let manifest) = PluginManifest.decode(data), manifest.id == url.lastPathComponent else { return nil }
            return manifest
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    public func importPackage(_ source: URL) throws -> PluginManifest {
        let fm = FileManager.default
        guard list().count < 32 else { throw PluginError.conflict }
        let values = try source.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true, source.pathExtension == "stillplugin" else { throw PluginError.unsafeFile }
        let files = try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard !files.isEmpty, files.allSatisfy({ ["manifest.json", "README.md", "LICENSE"].contains($0.lastPathComponent) }) else { throw PluginError.unsafeFile }
        for file in files { _ = try readBounded(file, limit: file.lastPathComponent == "manifest.json" ? 32768 : 65536) }
        let data = try readBounded(source.appendingPathComponent("manifest.json"), limit: 32768)
        let manifest = try PluginManifest.decode(data).get()
        let destination = root.appendingPathComponent(manifest.id)
        guard !fm.fileExists(atPath: destination.path) else { throw PluginError.conflict }
        try fm.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try safeDirectory(root)
        let staging = root.appendingPathComponent(".import-\(UUID().uuidString)")
        defer { try? fm.removeItem(at: staging) }
        try fm.createDirectory(at: staging, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        try data.write(to: staging.appendingPathComponent("manifest.json"), options: .atomic)
        try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: staging.appendingPathComponent("manifest.json").path)
        try fm.moveItem(at: staging, to: destination)
        return manifest
    }

    public func connect(_ manifest: PluginManifest) throws -> PluginConnection {
        let connection = PluginConnection(manifest: manifest)
        let directory = root.appendingPathComponent(manifest.id)
        guard list().contains(manifest) else { throw PluginError.invalidManifest }
        try safeDirectory(directory)
        try? FileManager.default.removeItem(at: directory.appendingPathComponent("snapshot.json"))
        try JSONEncoder().encode(connection).write(to: directory.appendingPathComponent("connection.json"), options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: directory.appendingPathComponent("connection.json").path)
        return connection
    }

    public func disconnect(_ id: String) throws {
        guard list().contains(where: { $0.id == id }) else { throw PluginError.invalidManifest }
        for name in ["connection.json", "snapshot.json"] {
            let path = root.appendingPathComponent(id).appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: path.path) { try FileManager.default.removeItem(at: path) }
        }
    }

    public func readSnapshot(_ id: String) throws -> Data {
        guard list().contains(where: { $0.id == id }) else { throw PluginError.invalidManifest }
        return try readBounded(root.appendingPathComponent(id).appendingPathComponent("snapshot.json"), limit: 65536)
    }
}

private func safeDirectory(_ url: URL) throws {
    let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
    guard values.isDirectory == true, values.isSymbolicLink != true else { throw PluginError.unsafeFile }
}

public func readBounded(_ url: URL, limit: Int) throws -> Data {
    let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
    guard values.isRegularFile == true, values.isSymbolicLink != true else { throw PluginError.unsafeFile }
    guard let size = values.fileSize, size <= limit else { throw PluginError.oversized }
    let descriptor = open(url.path, O_RDONLY | O_NOFOLLOW)
    guard descriptor >= 0 else { throw PluginError.unsafeFile }
    let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    defer { try? handle.close() }
    var attributes = stat()
    guard fstat(descriptor, &attributes) == 0, (attributes.st_mode & S_IFMT) == S_IFREG else { throw PluginError.unsafeFile }
    let data = try handle.read(upToCount: limit + 1) ?? Data()
    guard data.count <= limit else { throw PluginError.oversized }
    return data
}
