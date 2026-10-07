import CoreGraphics
import Testing
@testable import StillNativePlugins

@Test func resizingKeepsLeadingAndTopEdgesStationaryWhenContentWraps() {
    let original = CGRect(x: 100, y: 150, width: 290, height: 160)
    for width in [250.5, 290.0, 340.75] {
        let updated = CanvasResizeGeometry.frame(original: original, size: CGSize(width: width, height: 200))
        #expect(updated.minX == original.minX)
        #expect(updated.minY == original.minY)
        #expect(updated.width == width && updated.height == 200)
    }
}
