import Foundation
import CoreGraphics
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

@Test func canvasGeometryResolvesOverlapWithinItsOwnViewport() {
    for viewport in [CGSize(width: 1512, height: 982), CGSize(width: 2560, height: 1440), CGSize(width: 1024, height: 768)] {
        let geometry = CanvasGeometry(viewport: viewport)
        let items = [CanvasItem(id: "clock", size: CGSize(width: 380, height: 200), placement: CanvasPlacement(x: 0.5, y: 0.4))] + (0..<4).map { CanvasItem(id: "widget-\($0)", size: CGSize(width: 220, height: 140), placement: CanvasPlacement(x: 0.5, y: 0.4)) }
        let frames = geometry.frames(for: items)
        #expect(frames.count == 5)
        #expect(frames["clock"]?.midX == viewport.width / 2)
        for item in items { #expect(geometry.contentBounds.contains(frames[item.id]!)) }
        for i in items.indices { for j in items.indices where j > i { #expect(!frames[items[i].id]!.intersects(frames[items[j].id]!)) } }
        #expect(geometry.frames(for: items) == frames)
    }
}

@Test func narrowFocusPresetReflowsAllCardsWithoutOverlap() {
    let ids: [NativePluginID] = [.agents, .macPulse, .worldClock, .spotify]
    let scene = ScreenComposition.preset(.focus, ids: ids)
    let sizes = [CGSize(width: 230, height: 182), CGSize(width: 230, height: 192), CGSize(width: 230, height: 192), CGSize(width: 230, height: 156)]
    let items = [CanvasItem(id: "clock", size: CGSize(width: 399, height: 224), placement: scene.placement("clock"))] + ids.enumerated().map { index, id in CanvasItem(id: id.rawValue, size: sizes[index], placement: scene.placement(id.rawValue, index: index)) }
    let frames = CanvasGeometry(viewport: CGSize(width: 1024, height: 768)).frames(for: items)
    for i in items.indices { for j in items.indices where j > i { #expect(!frames[items[i].id]!.intersects(frames[items[j].id]!)) } }
}

@Test func continuousWidthsRoundTripWithoutSnappingAndAutoRemainsAuto() throws {
    var scene = ScreenComposition()
    scene.placements["spotify"] = CanvasPlacement(x: 0.347, y: 0.413, width: 297.5).fitted()
    scene.placements["clock"] = CanvasPlacement(x: 0.5, y: 0.4)
    let restored = try #require(ScreenComposition.decode(JSONEncoder().encode(scene)))
    #expect(restored == scene)
    #expect(restored.placement("spotify").x == 0.347)
    #expect(restored.placement("spotify").resolvedWidth(viewport: 1512) == 297.5)
    #expect(restored.placement("clock").width == nil)
    let auto = CanvasPlacement(x: 0.5, y: 0.4)
    #expect(auto.resolvedWidth(viewport: 1201) > auto.resolvedWidth(viewport: 1200))
    scene.placements["spotify"]?.width = 9999
    #expect(ScreenComposition.decode(try JSONEncoder().encode(scene)) == nil)
}
@Test func legacySizesMigrateWithoutChangingSavedCenters() throws {
    let data = Data(#"{"version":1,"placements":{"clock":{"x":0.5,"y":0.4,"size":"regular"},"spotify":{"x":0.347,"y":0.6,"size":"wide"}}}"#.utf8)
    let scene = try #require(ScreenComposition.decode(data))
    #expect(scene.placement("clock").width == nil)
    #expect(scene.placement("spotify").width == 380)
    #expect(scene.placement("spotify").x == 0.347)
    #expect(ScreenComposition.decode(try JSONEncoder().encode(scene)) == scene)
}

@Test func everyPresetIncludesAllTenNativeModulesAndLargeCanvasFitsThem() {
    let ids = NativePluginID.allCases
    for preset in CanvasPreset.allCases {
        let scene = ScreenComposition.preset(preset, ids: ids)
        #expect(scene.placements.count == 11)
        for viewport in [CGSize(width: 2560, height: 1440), CGSize(width: 1920, height: 1080)] {
            let items = [CanvasItem(id: "clock", size: CGSize(width: 490, height: 270), placement: scene.placement("clock"))] + ids.enumerated().map { index, id in CanvasItem(id: id.rawValue, size: CGSize(width: 340, height: 130 + Double(index % 3) * 30), placement: scene.placement(id.rawValue, index: index)) }
            let geometry = CanvasGeometry(viewport: viewport)
            let frames = geometry.frames(for: items)
            #expect(frames.count == 11)
            #expect(!CanvasGeometry.hasOverlap(frames))
            #expect(frames.values.allSatisfy { geometry.contentBounds.contains($0) })
        }
    }
}
