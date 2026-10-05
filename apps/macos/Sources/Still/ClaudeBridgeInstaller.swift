import Foundation
import StillWidgets

enum ClaudeBridgeInstaller {
    static var root: URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Still") }
    static var settings: URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/settings.json").resolvingSymlinksInPath() }
    private static var record: URL { root.appendingPathComponent("claude-bridge.json") }
    private static var helper: URL { root.appendingPathComponent("bin/StillClaudeBridge") }
    private static var command: String { "'" + helper.path.replacingOccurrences(of: "'", with: "'\\''") + "'" }
    private enum InstallError: Error { case missingHelper, conflict }

    static func install() throws {
        let fm = FileManager.default
        guard let bundled = Bundle.main.url(forAuxiliaryExecutable: "StillClaudeBridge") else { throw InstallError.missingHelper }
        let original = fm.fileExists(atPath: settings.path) ? try Data(contentsOf: settings) : nil
        let plan = try ClaudeBridgePlan.connect(current: original, command: command).get()
        if !plan.changed, !fm.fileExists(atPath: record.path) { throw InstallError.conflict }
        try fm.createDirectory(at: helper.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let staged = helper.appendingPathExtension("new")
        try? fm.removeItem(at: staged)
        try fm.copyItem(at: bundled, to: staged)
        try fm.setAttributes([.posixPermissions: 0o700], ofItemAtPath: staged.path)
        if fm.fileExists(atPath: helper.path) { _ = try fm.replaceItemAt(helper, withItemAt: staged) } else { try fm.moveItem(at: staged, to: helper) }
        guard plan.changed else { return }
        try plan.record.write(to: record, options: .atomic)
        try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: record.path)
        if let original {
            let backup = root.appendingPathComponent("claude-settings-before-bridge.json")
            try original.write(to: backup, options: .atomic)
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: backup.path)
        }
        guard (try? Data(contentsOf: settings)) == original else { throw InstallError.conflict }
        try fm.createDirectory(at: settings.deletingLastPathComponent(), withIntermediateDirectories: true)
        try plan.settings.write(to: settings, options: .atomic)
        try? fm.removeItem(at: root.appendingPathComponent("usage/claude.json"))
    }

    static func uninstall() throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: record.path) else { return }
        let data = try Data(contentsOf: record), original = try Data(contentsOf: settings)
        let restored = try ClaudeBridgePlan.disconnect(current: original, record: data, command: command).get()
        guard (try? Data(contentsOf: settings)) == original else { throw InstallError.conflict }
        try restored.write(to: settings, options: .atomic)
        try? fm.removeItem(at: root.appendingPathComponent("usage/claude.json"))
    }
}
