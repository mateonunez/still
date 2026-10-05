import CryptoKit
import Darwin
import Foundation
import StillWidgets

// Advisory metadata only. Never persist hook prompts, tool input, paths or raw IDs.
let arguments = CommandLine.arguments
guard arguments.count == 2 || (arguments.count == 4 && arguments[2] == "--test-directory"), let provider = UsageProvider(rawValue: arguments[1]) else { exit(0) }
let fm = FileManager.default
let root = arguments.count == 4 ? URL(fileURLWithPath: arguments[3]) : fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Still")
let directory = root.appendingPathComponent("activity")
let input = FileHandle.standardInput.readData(ofLength: 65537)
let enabled = root.appendingPathComponent("activity-\(provider.rawValue)-enabled")
guard fm.fileExists(atPath: enabled.path), let event = ActivityEvent.decode(input) else { exit(0) }
let saltURL = root.appendingPathComponent("activity-salt")
guard let salt = try? String(contentsOf: saltURL, encoding: .utf8), salt.count <= 128, !salt.isEmpty else { exit(0) }
try? fm.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
let lock = open(directory.appendingPathComponent(".lock").path, O_CREAT | O_RDWR | O_NOFOLLOW, 0o600)
guard lock >= 0 else { exit(0) }
guard flock(lock, LOCK_EX | LOCK_NB) == 0 else { close(lock); exit(0) }
defer { flock(lock, LOCK_UN); close(lock) }
let destination = directory.appendingPathComponent("\(provider.rawValue).json")
let now = Date()
func digest(_ value: String) -> String {
    HMAC<SHA256>.authenticationCode(for: Data(value.utf8), using: SymmetricKey(data: Data(salt.utf8))).map { String(format: "%02x", $0) }.joined()
}
let groupDigest = digest("\(provider.rawValue)|\(event.sessionID)")
let sessionDigest = digest("\(provider.rawValue)|\(event.sessionID)|\(event.agentID ?? "main")")
var records: [ActivityRecord] = []
if let data = try? Data(contentsOf: destination), data.count <= 65536, let previous = try? JSONDecoder().decode(ActivitySnapshot.self, from: data), previous.provider == provider {
    records = previous.current(now: now).filter { event.eventName == "SessionEnd" ? $0.groupDigest != groupDigest : $0.sessionDigest != sessionDigest }
}
if event.state != .unknown {
    records.append(ActivityRecord(sessionDigest: sessionDigest, groupDigest: groupDigest, state: event.state, observedAt: now, expiresAt: now.addingTimeInterval(event.state == .attentionRequested ? 90 : event.state == .completed || event.state == .interrupted || event.state == .failed ? 30 : 120)))
}
records = Array(records.sorted { $0.observedAt > $1.observedAt }.prefix(64))
if let data = try? JSONEncoder().encode(ActivitySnapshot(provider: provider, records: records)) {
    try? data.write(to: destination, options: .atomic)
    try? fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
}
// Codex Stop accepts a no-op JSON result; never return an approval decision.
if provider == .codex { print("{}") }
