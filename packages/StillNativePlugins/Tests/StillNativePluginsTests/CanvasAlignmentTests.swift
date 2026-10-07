import CoreGraphics
import Testing
@testable import StillNativePlugins

@Test func continuousDragShowsNearbyGuidesAndKeepsMovementExact() {
    let bounds = CGRect(x: 24, y: 90, width: 952, height: 600)
    let frame = CGRect(x: 100, y: 150, width: 200, height: 100)
    let other = CGRect(x: 500, y: 300, width: 250, height: 150)
    let snapped = CanvasAlignment.resolve(frame: frame, translation: CGSize(width: 397, height: 153), others: [other], bounds: bounds)
    #expect(snapped.center.x == 597 && snapped.verticalGuide == 500)
    #expect(snapped.center.y == 353 && snapped.horizontalGuide == 300)
    let free = CanvasAlignment.resolve(frame: frame, translation: CGSize(width: 123.4, height: 37.8), others: [], bounds: bounds)
    #expect(abs(free.center.x - 323.4) < 0.001 && free.verticalGuide == nil)
    let constrained = CanvasAlignment.resolve(frame: frame, translation: CGSize(width: -1000, height: 1000), others: [], bounds: bounds)
    #expect(constrained.center.x == 124 && constrained.center.y == 640)
}

@Test func alignmentGuidesDoNotJumpAsPointerCrossesTheirThreshold() {
    let bounds = CGRect(x: 24, y: 90, width: 952, height: 600)
    let frame = CGRect(x: 100, y: 150, width: 200, height: 100)
    var previous: CGPoint?
    for delta in stride(from: 287.0, through: 313.0, by: 0.5) {
        let result = CanvasAlignment.resolve(frame: frame, translation: CGSize(width: delta, height: 0), others: [], bounds: bounds)
        #expect(abs(result.center.x - (frame.midX + delta)) < 0.001)
        if let previous { #expect(abs(result.center.x - previous.x) <= 0.501) }
        previous = result.center
    }
}
