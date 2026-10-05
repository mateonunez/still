import Foundation

public enum CanvasModuleSize: String, Codable, CaseIterable, Sendable { case compact, regular, wide }
public struct CanvasPlacement: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var size: CanvasModuleSize
    public init(x: Double, y: Double, size: CanvasModuleSize = .regular) { self.x = x; self.y = y; self.size = size }
    public func snapped() -> Self {
        Self(x: min(0.92, max(0.08, (x * 12).rounded() / 12)), y: min(0.76, max(0.16, (y * 8).rounded() / 8)), size: size)
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
        guard data.count <= 16384, let value = try? JSONDecoder().decode(Self.self, from: data), value.version == 1, value.placements.count <= 11,
              value.placements.allSatisfy({ key, point in (key == "clock" || NativePluginID(rawValue: key) != nil) && point.x.isFinite && point.y.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y) }) else { return nil }
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
