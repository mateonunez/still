import Foundation

public enum SourceProjection {
    public static func github(_ data: Data) -> WorkFact? {
        guard let root = object(data), let runs = root["workflow_runs"] as? [[String: Any]], let run = runs.first,
              let status = run["status"] as? String else { return nil }
        let conclusion = run["conclusion"] as? String
        let state: WorkState = status == "completed" ? (conclusion == "success" ? .completed : conclusion == "cancelled" ? .canceled : ["failure", "timed_out", "action_required", "startup_failure"].contains(conclusion ?? "") ? .failed : .unknown) : status == "in_progress" ? .working : ["queued", "waiting", "pending", "requested"].contains(status) ? .queued : .unknown
        return WorkFact(label: "Latest workflow", state: state, startedAt: (run["run_started_at"] as? String).flatMap(date))
    }
    public static func vercel(_ data: Data) -> WorkFact? {
        guard let root = object(data), let rows = root["deployments"] as? [[String: Any]], let row = rows.first,
              let status = row["state"] as? String else { return nil }
        let state: WorkState = switch status { case "READY": .completed; case "BUILDING", "INITIALIZING": .working; case "QUEUED": .queued; case "ERROR": .failed; case "CANCELED": .canceled; default: .unknown }
        return WorkFact(label: "Latest deployment", state: state, startedAt: (row["created"] as? Double).map { Date(timeIntervalSince1970: $0 / 1000) })
    }
    public static func weather(_ data: Data, city: String, now: Date) -> (WeatherFact, Date)? {
        guard let root = object(data), let current = root["current"] as? [String: Any], let temperature = current["temperature_2m"] as? Double,
              temperature.isFinite, (-100...70).contains(temperature), let code = current["weather_code"] as? Int,
              let timestamp = current["time"] as? Double, timestamp <= now.timeIntervalSince1970 + 300, now.timeIntervalSince1970 - timestamp <= 1800,
              let hourly = root["hourly"] as? [String: Any], let times = hourly["time"] as? [Double], let chances = hourly["precipitation_probability"] as? [Double], times.count == chances.count else { return nil }
        let index = times.firstIndex { $0 >= now.timeIntervalSince1970 }
        let chance = index.flatMap { chances[$0].isFinite && (0...100).contains(chances[$0]) ? chances[$0] : nil }
        let condition = switch code { case 0: "Clear"; case 1, 2: "Partly cloudy"; case 3: "Cloudy"; case 45, 48: "Fog"; case 51...67, 80...82: "Rain"; case 71...77, 85, 86: "Snow"; case 95...99: "Thunderstorms"; default: "Conditions unavailable" }
        return (WeatherFact(city: city, temperature: temperature, condition: condition, rainChance: chance), Date(timeIntervalSince1970: timestamp))
    }
    private static func object(_ data: Data) -> [String: Any]? { guard data.count <= 1048576 else { return nil }; return try? JSONSerialization.jsonObject(with: data) as? [String: Any] }
    private static func date(_ value: String) -> Date? { ISO8601DateFormatter().date(from: value) }
}
