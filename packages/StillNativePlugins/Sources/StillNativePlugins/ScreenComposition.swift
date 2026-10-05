import Foundation

public enum CanvasModuleSize: String, Codable, CaseIterable, Sendable { case compact, regular, wide }
public struct CanvasPlacement: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var size: CanvasModuleSize
    /// Nil follows the display; a value is a continuous width in points.
    public var width: Double?
    public init(x: Double, y: Double, size: CanvasModuleSize = .regular, width: Double? = nil) { self.x = x; self.y = y; self.size = size; self.width = width }
    private enum CodingKeys: String, CodingKey { case x, y, size, width }
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        x = try values.decode(Double.self, forKey: .x); y = try values.decode(Double.self, forKey: .y)
        size = try values.decodeIfPresent(CanvasModuleSize.self, forKey: .size) ?? .regular
        // Preserve legacy saved widths; explicit null is the new automatic mode.
        width = values.contains(.width) ? try values.decodeIfPresent(Double.self, forKey: .width) : (size == .compact ? 220 : size == .wide ? 380 : 280)
    }
    public func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(x, forKey: .x); try values.encode(y, forKey: .y); try values.encode(size, forKey: .size); try values.encode(width, forKey: .width)
    }
    public func fitted() -> Self {
        Self(x: min(0.92, max(0.08, x)), y: min(0.76, max(0.16, y)), size: size, width: width.map { min(600, max(180, $0)) })
    }
    public func resolvedWidth(viewport: Double, clock: Bool = false) -> Double {
        let automatic = clock ? min(480, viewport * 0.38) : min(330, max(210, viewport * 0.22))
        return min(width ?? automatic, max(180, viewport * (clock ? 0.55 : 0.32)))
    }
    public func snapped() -> Self {
        Self(x: min(0.92, max(0.08, (x * 12).rounded() / 12)), y: min(0.76, max(0.16, (y * 8).rounded() / 8)), size: size, width: width)
    }
}
public struct ScreenComposition: Codable, Equatable, Sendable {
    public var version = 1
    public var placements: [String: CanvasPlacement] = [:]
    public init() {}
    public func placement(_ id: String, index: Int = 0) -> CanvasPlacement {
        placements[id] ?? (id == "clock" ? CanvasPlacement(x: 0.5, y: 0.4) : CanvasPlacement(x: index % 2 == 0 ? 0.2 : 0.8, y: index < 2 ? 0.3 : 0.65))
    }
    public static func decode(_ data: Data) -> Self? {
        guard data.count <= 16384, var value = try? JSONDecoder().decode(Self.self, from: data), value.version == 1, value.placements.count <= 11,
              value.placements.allSatisfy({ key, point in (key == "clock" || NativePluginID(rawValue: key) != nil) && point.x.isFinite && point.y.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y) && (point.width == nil || (point.width!.isFinite && (180...600).contains(point.width!))) }) else { return nil }
        if let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let placements = root["placements"] as? [String: [String: Any]], let clock = placements["clock"], clock["width"] == nil { value.placements["clock"]?.width = nil }
        return value
    }
}

public enum CanvasPreset: String, CaseIterable, Sendable {
    case balanced, focus, dashboard
    public var title: String { switch self { case .balanced: "Balanced"; case .focus: "Focus"; case .dashboard: "Dashboard" } }
}
extension ScreenComposition {
    public static func preset(_ preset: CanvasPreset, ids: [NativePluginID]) -> Self {
        var scene = Self()
        scene.placements["clock"] = CanvasPlacement(x: preset == .focus ? 0.4 : 0.5, y: preset == .dashboard ? 0.27 : 0.4)
        for (index, id) in ids.prefix(4).enumerated() {
            let x: Double
            let y: Double
            switch preset {
            case .balanced: x = index % 2 == 0 ? 0.18 : 0.82; y = index < 2 ? 0.28 : 0.62
            case .focus: x = 0.82; y = 0.22 + Double(index) * 0.14
            case .dashboard: x = index % 2 == 0 ? 0.3 : 0.7; y = index < 2 ? 0.48 : 0.7
            }
            scene.placements[id.rawValue] = CanvasPlacement(x: x, y: y, size: .compact)
        }
        return scene
    }
}
