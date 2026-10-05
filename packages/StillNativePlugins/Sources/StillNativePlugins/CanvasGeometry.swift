import Foundation
import CoreGraphics

/// Geometry belongs to a single display viewport; saved centers never use desktop coordinates.
public struct CanvasItem: Equatable, Sendable {
    public let id: String
    public let size: CGSize
    public let placement: CanvasPlacement
    public init(id: String, size: CGSize, placement: CanvasPlacement) { self.id = id; self.size = size; self.placement = placement }
}
public struct CanvasGeometry: Sendable {
    public let viewport: CGSize
    public let reservedFooter: CGFloat
    public init(viewport: CGSize, reservedFooter: CGFloat = 230) { self.viewport = viewport; self.reservedFooter = reservedFooter }
    public var contentBounds: CGRect {
        CGRect(x: 24, y: 90, width: max(1, viewport.width - 48), height: max(1, viewport.height - 90 - reservedFooter))
    }
    public func frames(for items: [CanvasItem]) -> [String: CGRect] {
        let preferred = resolve(items)
        if !Self.hasOverlap(preferred) { return preferred }
        var index = 0
        let balanced = items.map { item -> CanvasItem in
            let point: CanvasPlacement
            if item.id == "clock" { point = CanvasPlacement(x: 0.5, y: 0.4, size: item.placement.size, width: item.placement.width) }
            else {
                point = CanvasPlacement(x: index % 2 == 0 ? 0.18 : 0.82, y: index < 2 ? 0.28 : 0.62, size: item.placement.size, width: item.placement.width)
                index += 1
            }
            return CanvasItem(id: item.id, size: item.size, placement: point)
        }
        return resolve(balanced)
    }
    public static func hasOverlap(_ frames: [String: CGRect]) -> Bool {
        let values = Array(frames.values)
        for i in values.indices { for j in values.indices where j > i { if values[i].intersects(values[j]) { return true } } }
        return false
    }
    private func resolve(_ items: [CanvasItem]) -> [String: CGRect] {
        var result: [String: CGRect] = [:]
        let area = contentBounds
        for item in items {
            let size = CGSize(width: min(item.size.width, area.width), height: min(item.size.height, area.height))
            func frame(_ center: CGPoint) -> CGRect {
                CGRect(x: min(area.maxX - size.width, max(area.minX, center.x - size.width / 2)), y: min(area.maxY - size.height, max(area.minY, center.y - size.height / 2)), width: size.width, height: size.height)
            }
            let desired = CGPoint(x: viewport.width * item.placement.x, y: viewport.height * item.placement.y)
            let preferred = frame(desired)
            func vacant(_ candidate: CGRect) -> Bool { !result.values.contains { $0.insetBy(dx: -8, dy: -8).intersects(candidate) } }
            if vacant(preferred) { result[item.id] = preferred; continue }
            var candidates: [CGRect] = []
            for x in stride(from: area.minX, through: max(area.minX, area.maxX - size.width), by: 20) {
                for y in stride(from: area.minY, through: max(area.minY, area.maxY - size.height), by: 20) { candidates.append(CGRect(origin: CGPoint(x: x, y: y), size: size)) }
            }
            // Include boundaries even when a viewport dimension is not a multiple of the search step.
            for x in [area.minX, area.maxX - size.width] { for y in [area.minY, area.maxY - size.height] { candidates.append(CGRect(x: x, y: y, width: size.width, height: size.height)) } }
            candidates.sort { a, b in
                let da = pow(a.midX - desired.x, 2) + pow(a.midY - desired.y, 2)
                let db = pow(b.midX - desired.x, 2) + pow(b.midY - desired.y, 2)
                if da == db { return a.minY == b.minY ? a.minX < b.minX : a.minY < b.minY }
                return da < db
            }
            result[item.id] = candidates.first(where: vacant) ?? preferred
        }
        return result
    }
}
