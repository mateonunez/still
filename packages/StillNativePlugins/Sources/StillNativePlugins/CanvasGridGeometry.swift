import Foundation
import CoreGraphics

/// Equal tracks, content-sized rows, centered wrapping and a dedicated clock region.
public struct CanvasGridGeometry: Sendable {
    public let viewport: CGSize
    public let reservedFooter: CGFloat
    public let preferredWidth: Double?
    public let gap: CGFloat = 20
    public init(viewport: CGSize, reservedFooter: CGFloat = 230, preferredWidth: Double? = nil) {
        self.viewport = viewport; self.reservedFooter = reservedFooter; self.preferredWidth = preferredWidth
    }
    public var area: CGRect { CanvasGeometry(viewport: viewport, reservedFooter: reservedFooter).contentBounds }
    public func columns(count: Int) -> Int {
        guard count > 0 else { return 1 }
        let ideal = preferredWidth ?? min(330, max(180, viewport.width * 0.18))
        let capacity = max(1, min(count, Int((area.width + gap) / (ideal + gap))))
        let rows = Int(ceil(Double(count) / Double(capacity)))
        return Int(ceil(Double(count) / Double(rows)))
    }
    public func trackWidth(count: Int) -> CGFloat {
        let count = columns(count: count)
        let available = (area.width - gap * CGFloat(count - 1)) / CGFloat(count)
        let ideal = preferredWidth ?? min(330, max(180, viewport.width * 0.18))
        return min(available, ideal * 1.2)
    }
    public static func insertionTarget(at point: CGPoint, frames: [String: CGRect], excluding id: String) -> String? {
        frames.filter { $0.key != id && $0.key != "clock" && $0.value.insetBy(dx: -10, dy: -10).contains(point) }.min { a, b in
            hypot(a.value.midX - point.x, a.value.midY - point.y) < hypot(b.value.midX - point.x, b.value.midY - point.y)
        }?.key
    }
    public func frames(for items: [CanvasItem]) -> [String: CGRect] {
        let clock = items.first { $0.id == "clock" }
        let cards = items.filter { $0.id != "clock" }
        let columns = columns(count: cards.count)
        let rows = stride(from: 0, to: cards.count, by: columns).map { Array(cards[$0..<min(cards.count, $0 + columns)]) }
        let rowHeights = rows.map { $0.map(\.size.height).max() ?? 0 }
        let heroHeight = clock?.size.height ?? 0
        let heroGap: CGFloat = clock != nil && !cards.isEmpty ? 24 : 0
        let totalHeight = heroHeight + heroGap + rowHeights.reduce(0, +) + gap * CGFloat(max(0, rows.count - 1))
        var y = area.minY + max(0, (area.height - totalHeight) / 2)
        var result: [String: CGRect] = [:]
        if let clock {
            result[clock.id] = CGRect(x: area.midX - clock.size.width / 2, y: y, width: clock.size.width, height: clock.size.height)
            y += heroHeight + heroGap
        }
        for (index, row) in rows.enumerated() {
            let width = row.reduce(0) { $0 + $1.size.width } + gap * CGFloat(max(0, row.count - 1))
            var x = area.midX - width / 2
            for item in row {
                result[item.id] = CGRect(x: x, y: y, width: item.size.width, height: item.size.height)
                x += item.size.width + gap
            }
            y += rowHeights[index] + gap
        }
        return result
    }
}
