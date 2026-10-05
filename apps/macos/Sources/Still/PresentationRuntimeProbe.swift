import AppKit
import Foundation

@MainActor
enum PresentationRuntimeProbe {
    static func run(directory: URL) {
        let original = NSApp.presentationOptions
        let policy = DesktopPresentationPolicy()
        policy.cover()
        let covered = NSApp.presentationOptions
        policy.cover()
        let repeated = NSApp.presentationOptions
        policy.restore()
        let restored = NSApp.presentationOptions
        policy.restore()
        let checks: [String: Bool] = [
            "dockHidden": covered.contains(.hideDock),
            "commandTabRestricted": covered.contains(.disableProcessSwitching),
            "menuRemainsAvailable": covered.contains(.autoHideMenuBar) && !covered.contains(.hideMenuBar),
            "recoveryNotDisabled": !covered.contains(.disableForceQuit) && !covered.contains(.disableSessionTermination),
            "repeatedCoverIsIdempotent": repeated == covered,
            "restoresExactPriorOptions": restored == original && NSApp.presentationOptions == original
        ]
        let receipt: [String: Any] = ["kind": "public-presentation-options-probe", "checks": checks, "boundary": "No trackpad, compositor-frame, authentication or recovery UI acceptance."]
        if let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys]) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try? data.write(to: directory.appendingPathComponent("presentation.json"), options: .atomic)
        }
    }
}
