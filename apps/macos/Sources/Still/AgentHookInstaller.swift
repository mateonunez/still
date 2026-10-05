import Foundation
import StillWidgets

enum AgentHookInstaller {
    static func configure(_ provider: UsageProvider, enabled: Bool) throws {
        let fm = FileManager.default, root = ClaudeBridgeInstaller.root
        let settings = provider == .claude ? ClaudeBridgeInstaller.settings : fm.homeDirectoryForCurrentUser.appendingPathComponent(".codex/hooks.json").resolvingSymlinksInPath()
        let original = fm.fileExists(atPath: settings.path) ? try Data(contentsOf: settings) : nil
        let helper = root.appendingPathComponent("bin/StillAgentBridge")
        let command = "'" + helper.path.replacingOccurrences(of: "'", with: "'\\''") + "' " + provider.rawValue
        let patched = try AgentHookPlan.patch(original, provider: provider, command: command, enable: enabled).get()
        try fm.createDirectory(at: helper.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        if enabled {
            guard let bundled = Bundle.main.url(forAuxiliaryExecutable: "StillAgentBridge") else { throw UsageFailure.missingClient }
            let staged = helper.appendingPathExtension("new")
            try? fm.removeItem(at: staged); try fm.copyItem(at: bundled, to: staged)
            try fm.setAttributes([.posixPermissions: 0o700], ofItemAtPath: staged.path)
            if fm.fileExists(atPath: helper.path) { _ = try fm.replaceItemAt(helper, withItemAt: staged) } else { try fm.moveItem(at: staged, to: helper) }
            let salt = root.appendingPathComponent("activity-salt")
            if !fm.fileExists(atPath: salt.path) { try Data(UUID().uuidString.utf8).write(to: salt, options: .atomic); try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: salt.path) }
            if let original {
                let backup = root.appendingPathComponent("hooks-\(provider.rawValue)-\(UUID().uuidString).json")
                try original.write(to: backup, options: .atomic); try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: backup.path)
            }
        }
        guard (try? Data(contentsOf: settings)) == original else { throw UsageFailure.unavailable }
        try fm.createDirectory(at: settings.deletingLastPathComponent(), withIntermediateDirectories: true)
        try patched.write(to: settings, options: .atomic)
        let marker = root.appendingPathComponent("activity-\(provider.rawValue)-enabled")
        if enabled { try Data("enabled".utf8).write(to: marker, options: .atomic); try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: marker.path) }
        else { try? fm.removeItem(at: marker) }
        try? fm.removeItem(at: root.appendingPathComponent("activity/\(provider.rawValue).json"))
        if !enabled, !UsageProvider.allCases.contains(where: { fm.fileExists(atPath: root.appendingPathComponent("activity-\($0.rawValue)-enabled").path) }) { try? fm.removeItem(at: root.appendingPathComponent("activity-salt")) }
    }
}
