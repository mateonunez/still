import Foundation

public enum NativeStoreError: Error { case unsafePath, invalidConfiguration }
public struct NativePluginStore: Sendable {
    public let root: URL
    public init(root: URL) { self.root = root }
    public func directory(_ plugin: NativePluginID) -> URL { root.appendingPathComponent(plugin.rawValue, isDirectory: true) }
    /// Prepare compiled modules without connecting sources or replacing existing settings.
    public func prepareMissingConfigurations() throws {
        let fm = FileManager.default
        func ensureDirectory(_ path: URL) throws {
            if let attributes = try? fm.attributesOfItem(atPath: path.path) {
                guard attributes[.type] as? FileAttributeType == .typeDirectory else { throw NativeStoreError.unsafePath }
            } else {
                try fm.createDirectory(at: path, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            }
        }
        try ensureDirectory(root)
        for id in NativePluginID.allCases {
            try ensureDirectory(directory(id))
            let path = directory(id).appendingPathComponent("configuration.json")
            if (try? fm.attributesOfItem(atPath: path.path)) != nil {
                _ = try boundedRead(path, limit: 16384)
                continue
            }
            try write(NativePluginConfiguration(plugin: id))
        }
    }

    public func configuration(_ plugin: NativePluginID) -> NativePluginConfiguration? {
        guard (try? checkDirectory(plugin)) != nil, let data = try? boundedRead(directory(plugin).appendingPathComponent("configuration.json"), limit: 16384) else { return nil }
        return NativePluginConfiguration.decode(data, expected: plugin)
    }
    public func write(_ config: NativePluginConfiguration) throws {
        guard config.settings.valid(for: config.plugin), config.schemaVersion == 2 else { throw NativeStoreError.invalidConfiguration }
        try checkDirectory(config.plugin)
        let path = directory(config.plugin).appendingPathComponent("configuration.json")
        try rejectSymbolicLink(path)
        if FileManager.default.fileExists(atPath: path.path) { _ = try boundedRead(path, limit: 16384) }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        try encoder.encode(config).write(to: path, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
    }
    public func readTasks() throws -> Data { try checkDirectory(.taskWatch); return try boundedRead(directory(.taskWatch).appendingPathComponent("snapshot.json"), limit: 16384) }
    public func rotateTaskConnection() throws -> UUID {
        try checkDirectory(.taskWatch)
        let id = UUID(), path = directory(.taskWatch).appendingPathComponent("connection.json")
        try rejectSymbolicLink(path)
        if FileManager.default.fileExists(atPath: path.path) { _ = try boundedRead(path, limit: 16384) }
        let data = try JSONSerialization.data(withJSONObject: ["protocolVersion": 2, "connectionID": id.uuidString], options: [.sortedKeys])
        try data.write(to: path, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
        return id
    }
    private func checkDirectory(_ plugin: NativePluginID) throws {
        for path in [root, directory(plugin)] {
            let values = try path.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            guard values.isDirectory == true, values.isSymbolicLink != true else { throw NativeStoreError.unsafePath }
        }
    }
    private func boundedRead(_ path: URL, limit: Int) throws -> Data {
        let values = try path.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true, let size = values.fileSize, size <= limit else { throw NativeStoreError.unsafePath }
        let data = try Data(contentsOf: path)
        guard data.count <= limit else { throw NativeStoreError.unsafePath }
        return data
    }
    private func rejectSymbolicLink(_ path: URL) throws {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path.path), attributes[.type] as? FileAttributeType == .typeSymbolicLink { throw NativeStoreError.unsafePath }
    }
}
