import Foundation

public enum BridgePlanFailure: Error, Equatable { case invalidSettings, conflict }
public struct ClaudeBridgePlan: Sendable {
    public let settings: Data
    public let record: Data
    public let changed: Bool

    public static func connect(current: Data?, command: String) -> Result<ClaudeBridgePlan, BridgePlanFailure> {
        do {
            guard current?.count ?? 0 <= 1048576 else { return .failure(.invalidSettings) }
            guard var object = try current.map({ try JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:] else { return .failure(.invalidSettings) }
            let previous = object["statusLine"] as? [String: Any]
            if object["statusLine"] != nil, previous == nil { return .failure(.invalidSettings) }
            if previous?["command"] as? String == command { return .success(ClaudeBridgePlan(settings: current ?? Data(), record: Data(), changed: false)) }
            if let previous, previous["type"] as? String != "command" || !(previous["command"] is String) { return .failure(.invalidSettings) }
            let backup: [String: Any] = ["originalStatusLine": previous ?? NSNull(), "originalCommand": previous?["command"] ?? NSNull()]
            var line = previous ?? ["type": "command"]
            line["command"] = command; object["statusLine"] = line
            return .success(ClaudeBridgePlan(settings: try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]), record: try JSONSerialization.data(withJSONObject: backup, options: [.sortedKeys]), changed: true))
        } catch { return .failure(.invalidSettings) }
    }

    public static func disconnect(current: Data, record: Data, command: String) -> Result<Data, BridgePlanFailure> {
        do {
            guard current.count <= 1048576, record.count <= 65536,
                  var object = try JSONSerialization.jsonObject(with: current) as? [String: Any],
                  let backup = try JSONSerialization.jsonObject(with: record) as? [String: Any], backup.keys.contains("originalStatusLine") else { return .failure(.invalidSettings) }
            guard let line = object["statusLine"] as? [String: Any], line["command"] as? String == command else { return .failure(.conflict) }
            if let previous = backup["originalStatusLine"] as? [String: Any] { object["statusLine"] = previous } else { object.removeValue(forKey: "statusLine") }
            return .success(try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]))
        } catch { return .failure(.invalidSettings) }
    }
}
