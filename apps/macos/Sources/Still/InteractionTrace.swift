import AppKit
import Foundation

/// Explicit local diagnostic: bounded state only, never input, client data or window titles.
@MainActor
final class InteractionTrace {
    private let directory: URL?
    private let started = ProcessInfo.processInfo.systemUptime
    private var events: [[String: Any]] = []
    private var lastState = ""

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if let flag = arguments.firstIndex(of: "--interaction-trace"), arguments.indices.contains(flag + 1) {
            directory = URL(fileURLWithPath: arguments[flag + 1], isDirectory: true)
        } else { directory = nil }
    }

    func record(_ phase: String, covered: Bool, touchID: Bool, preparationError: Int?, authentication: String, panelCount: Int, keyPanel: Bool, attached: Bool) {
        guard let directory else { return }
        let state = "\(NSApp.isActive)|\(covered)|\(touchID)|\(authentication)|\(panelCount)|\(keyPanel)|\(attached)|\(NSApp.presentationOptions.rawValue)"
        if phase == "state", state == lastState { return }
        lastState = state
        var event: [String: Any] = [
            "phase": phase, "seconds": ProcessInfo.processInfo.systemUptime - started,
            "appActive": NSApp.isActive, "covered": covered, "touchIDPrepared": touchID,
            "authentication": authentication, "panelCount": panelCount, "keyPanel": keyPanel,
            "touchIDAttached": attached, "presentationOptions": NSApp.presentationOptions.rawValue
        ]
        if let preparationError { event["preparationErrorCode"] = preparationError }
        events.append(event); if events.count > 256 { events.removeFirst(events.count - 256) }
        let receipt: [String: Any] = ["kind": "native-interaction-state-trace", "events": events, "boundary": "State transitions only; physical gesture and authentication outcomes require owner observation."]
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            let path = directory.appendingPathComponent("interaction.json")
            try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted]).write(to: path, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
        } catch { /* Diagnostic failure must not change cover or authentication. */ }
    }
}
