import Foundation
import CoreGraphics
import Testing
@testable import StillNativePlugins

@Test func gridAlignsTracksAndContentRowsWithoutCollisionSearch() {
    for viewport in [CGSize(width: 1512, height: 982), CGSize(width: 1920, height: 1080), CGSize(width: 2560, height: 1440)] {
        for count in [0, 1, 4, 10] {
            let grid = CanvasGridGeometry(viewport: viewport)
            let width = grid.trackWidth(count: count)
            let cards = (0..<count).map { CanvasItem(id: "card-\($0)", size: CGSize(width: width, height: 120 + Double($0 % 3) * 20), placement: CanvasPlacement(x: 0, y: 0)) }
            let clock = CanvasItem(id: "clock", size: CGSize(width: 480, height: 160), placement: CanvasPlacement(x: 0.1, y: 0.9))
            let frames = grid.frames(for: [clock] + cards)
            #expect(frames.count == count + 1)
            #expect(frames["clock"]!.midX == grid.area.midX)
            #expect(!CanvasGeometry.hasOverlap(frames))
            #expect(frames.values.allSatisfy { grid.area.contains($0) })
            let columns = grid.columns(count: count)
            for index in cards.indices where index % columns != 0 {
                let previous = frames[cards[index - 1].id]!
                let current = frames[cards[index].id]!
                #expect(current.minY == previous.minY)
                #expect(abs(current.minX - previous.maxX - grid.gap) < 0.001)
            }
        }
    }
}
@Test func gridReflowsAndReportsInsufficientRoomInsteadOfOverlapping() {
    let narrow = CanvasGridGeometry(viewport: CGSize(width: 1024, height: 768))
    let wide = CanvasGridGeometry(viewport: CGSize(width: 2560, height: 1440))
    #expect(narrow.columns(count: 10) < wide.columns(count: 10))
    let width = narrow.trackWidth(count: 10)
    let cards = (0..<10).map { CanvasItem(id: "card-\($0)", size: CGSize(width: width, height: 220), placement: CanvasPlacement(x: 0.5, y: 0.4)) }
    let frames = narrow.frames(for: cards)
    #expect(!CanvasGeometry.hasOverlap(frames))
    #expect(frames.values.contains { !narrow.area.contains($0) })
    #expect(CanvasGridGeometry(viewport: wide.viewport, preferredWidth: 500).columns(count: 10) < wide.columns(count: 10))
}
@Test func layoutModesRoundTripAndOldLayoutsRemainFree() throws {
    let legacy = Data(#"{"version":1,"placements":{"clock":{"x":0.5,"y":0.4,"size":"regular"}}}"#.utf8)
    #expect(ScreenComposition.decode(legacy)?.effectiveLayout == .free)
    var scene = ScreenComposition()
    #expect(scene.effectiveLayout == .grid)
    scene.placements["spotify"] = CanvasPlacement(x: 0.347, y: 0.413, width: 297.5)
    scene.gridWidth = 287.5
    #expect(ScreenComposition.decode(try JSONEncoder().encode(scene)) == scene)
    scene.layout = .free
    #expect(ScreenComposition.decode(try JSONEncoder().encode(scene))?.placement("spotify").width == 297.5)
    scene.gridWidth = 0
    #expect(ScreenComposition.decode(try JSONEncoder().encode(scene)) == nil)
}

@Test func gridDropsOnlyReorderOverAnotherModule() {
    let frames = ["clock": CGRect(x: 200, y: 0, width: 300, height: 100), "agents": CGRect(x: 100, y: 150, width: 200, height: 150), "spotify": CGRect(x: 320, y: 150, width: 200, height: 150)]
    #expect(CanvasGridGeometry.insertionTarget(at: CGPoint(x: 200, y: 200), frames: frames, excluding: "agents") == nil)
    #expect(CanvasGridGeometry.insertionTarget(at: CGPoint(x: 350, y: 50), frames: frames, excluding: "agents") == nil)
    #expect(CanvasGridGeometry.insertionTarget(at: CGPoint(x: 420, y: 200), frames: frames, excluding: "agents") == "spotify")
    #expect(CanvasGridGeometry.insertionTarget(at: CGPoint(x: 700, y: 200), frames: frames, excluding: "agents") == nil)
}
