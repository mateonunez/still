import Foundation
import StillWidgets

// Statusline-only helper. Never opens conversations or credential stores.
let fm = FileManager.default
let arguments = CommandLine.arguments
let testRoot = arguments.count == 3 && arguments[1] == "--test-directory" ? URL(fileURLWithPath: arguments[2]) : nil
let directory = (testRoot ?? fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Still")).appendingPathComponent("usage")
let input = FileHandle.standardInput.readData(ofLength: 131073)
let now = Date()
let destination = directory.appendingPathComponent("claude.json")
if case .success(var snapshot) = UsageProjection.claudeStatusline(input, now: now) {
    // Re-rendered unchanged metadata cannot silently extend source freshness.
    if let previousData = try? Data(contentsOf: destination), previousData.count <= 65536,
       let previous = try? JSONDecoder().decode(UsageSnapshot.self, from: previousData),
       previous.provider == .claude, previous.windows == snapshot.windows {
        snapshot = UsageSnapshot(provider: .claude, observedAt: previous.observedAt, windows: snapshot.windows)
    }
    if let data = try? JSONEncoder().encode(snapshot) {
        try? fm.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try? data.write(to: destination, options: .atomic)
        try? fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
    }
} else {
    // Missing quota must not leave an older healthy snapshot behind.
    try? fm.removeItem(at: destination)
}

struct PriorStatusline: Decodable { let originalCommand: String? }
let configURL = directory.deletingLastPathComponent().appendingPathComponent("claude-bridge.json")
if let config = try? Data(contentsOf: configURL), config.count <= 65536,
   let previous = try? JSONDecoder().decode(PriorStatusline.self, from: config), let command = previous.originalCommand {
    // Forward the existing user-owned command unchanged, including its output.
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", command]
    let pipe = Pipe(); process.standardInput = pipe
    process.standardOutput = FileHandle.standardOutput; process.standardError = FileHandle.standardError
    do {
        try process.run()
        try? pipe.fileHandleForWriting.write(contentsOf: input)
        try? pipe.fileHandleForWriting.close()
        process.waitUntilExit()
        exit(process.terminationStatus)
    } catch { exit(1) }
} else {
    print("Still · Claude quota")
}
