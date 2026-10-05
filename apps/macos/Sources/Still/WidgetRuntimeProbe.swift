import Foundation
import StillWidgets

@MainActor
enum WidgetRuntimeProbe {
    static func run(directory: URL) async {
        var receipt: [String: Any] = ["kind": "native-live-usage", "observedAt": Date().ISO8601Format()]
        if let executable = CodexUsageAdapter.locate() {
            switch await CodexUsageAdapter.fetch(executable: executable) {
            case .success(let snapshot):
                receipt["codex"] = ["connected": true, "windows": snapshot.windows.map { ["minutes": $0.minutes, "usedPercent": $0.usedPercent, "resetsAt": $0.resetsAt?.ISO8601Format() ?? "unavailable"] as [String: Any] }]
            case .failure(let error): receipt["codex"] = ["connected": false, "error": error.rawValue]
            }
        } else { receipt["codex"] = ["connected": false, "error": "missingClient"] }
        receipt["boundary"] = "Real account quotas only; no conversation or approval observation. Claude awaits an explicitly enabled statusline bridge."
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys]) { try? data.write(to: directory.appendingPathComponent("live-usage.json"), options: .atomic) }
    }
}
