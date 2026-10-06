import CoreGraphics

public struct CanvasAlignment: Sendable {
    public let center: CGPoint
    public let verticalGuide: CGFloat?
    public let horizontalGuide: CGFloat?

    /// Align measured centers/edges without quantizing pointer movement to a grid.
    public static func resolve(frame: CGRect, translation: CGSize, others: [CGRect], bounds: CGRect, tolerance: CGFloat = 6) -> Self {
        let size = CGSize(width: min(frame.width, bounds.width), height: min(frame.height, bounds.height))
        var x = min(bounds.maxX - size.width / 2, max(bounds.minX + size.width / 2, frame.midX + translation.width))
        var y = min(bounds.maxY - size.height / 2, max(bounds.minY + size.height / 2, frame.midY + translation.height))
        func closest(_ center: CGFloat, candidates: [(CGFloat, CGFloat)], range: ClosedRange<CGFloat>) -> (CGFloat, CGFloat?) {
            let values = candidates.filter { range.contains($0.0) && abs($0.0 - center) <= tolerance }
            guard let match = values.min(by: { abs($0.0 - center) < abs($1.0 - center) }) else { return (center, nil) }
            return (match.0, match.1)
        }
        var xs: [(CGFloat, CGFloat)] = [(bounds.midX, bounds.midX)]
        var ys: [(CGFloat, CGFloat)] = [(bounds.midY, bounds.midY)]
        for other in others {
            xs += [(other.midX, other.midX), (other.minX + size.width / 2, other.minX), (other.maxX - size.width / 2, other.maxX)]
            ys += [(other.midY, other.midY), (other.minY + size.height / 2, other.minY), (other.maxY - size.height / 2, other.maxY)]
        }
        let alignedX = closest(x, candidates: xs, range: (bounds.minX + size.width / 2)...(bounds.maxX - size.width / 2))
        let alignedY = closest(y, candidates: ys, range: (bounds.minY + size.height / 2)...(bounds.maxY - size.height / 2))
        x = alignedX.0; y = alignedY.0
        return Self(center: CGPoint(x: x, y: y), verticalGuide: alignedX.1, horizontalGuide: alignedY.1)
    }
}
