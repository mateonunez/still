import SwiftUI
import UniformTypeIdentifiers

private let canvasModuleType = UTType(exportedAs: "co.mateonunez.still.canvas-module")

/// A system drag session supplies lift, cursor tracking and the drop preview.
/// The payload is process-local; unrelated external text cannot rearrange the scene.
struct CanvasGridDrag: ViewModifier {
    let id: String
    let enabled: Bool
    @Binding var source: String?
    @Binding var lastTarget: String?
    var select: () -> Void
    var reorder: (String, String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder func body(content: Content) -> some View {
        if enabled {
            content.onDrag {
                source = id; lastTarget = nil; select()
                let provider = NSItemProvider()
                provider.registerDataRepresentation(forTypeIdentifier: canvasModuleType.identifier, visibility: .ownProcess) { completion in
                    completion(Data(id.utf8), nil); return nil
                }
                return provider
            }
            .onDrop(of: [canvasModuleType], delegate: CanvasInsertionDrop(target: id, source: $source, lastTarget: $lastTarget, reduceMotion: reduceMotion, reorder: reorder))
        } else { content }
    }
}

private struct CanvasInsertionDrop: DropDelegate {
    let target: String
    @Binding var source: String?
    @Binding var lastTarget: String?
    let reduceMotion: Bool
    let reorder: (String, String) -> Void
    func validateDrop(info: DropInfo) -> Bool { source != nil && info.hasItemsConforming(to: [canvasModuleType]) }
    func dropEntered(info: DropInfo) {
        guard validateDrop(info: info), let source, source != target, lastTarget != target else { return }
        lastTarget = target
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.25, extraBounce: 0)) { reorder(source, target) }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func performDrop(info: DropInfo) -> Bool {
        guard validateDrop(info: info) else { return false }
        source = nil; lastTarget = nil; return true
    }
}
