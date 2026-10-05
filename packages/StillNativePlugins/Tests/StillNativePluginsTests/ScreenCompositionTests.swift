import Foundation
import Testing
@testable import StillNativePlugins

@Test func canvasPlacementSnapsAndKeepsReturnAreaReserved() {
    let result = CanvasPlacement(x: 0.34, y: 0.99, size: .wide).snapped()
    #expect(abs(result.x - 4.0 / 12) < 0.001)
    #expect(result.y == 0.76 && result.size == .wide)
    #expect(CanvasPlacement(x: -10, y: -10).snapped().x == 0.08)
}
@Test func canvasRoundTripRejectsUnsupportedOrInvalidPositions() throws {
    var layout = ScreenComposition()
    layout.placements["clock"] = CanvasPlacement(x: 0.5, y: 0.4)
    layout.placements["spotify"] = CanvasPlacement(x: 0.75, y: 0.6, size: .compact)
    let encoder = JSONEncoder()
    #expect(ScreenComposition.decode(try encoder.encode(layout)) == layout)
    layout.placements["unknown"] = CanvasPlacement(x: 0.2, y: 0.2)
    #expect(ScreenComposition.decode(try encoder.encode(layout)) == nil)
    layout.placements.removeValue(forKey: "unknown")
    layout.placements["clock"] = CanvasPlacement(x: 2, y: 0.4)
    #expect(ScreenComposition.decode(try encoder.encode(layout)) == nil)
}
