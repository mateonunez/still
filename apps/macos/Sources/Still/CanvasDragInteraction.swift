import SwiftUI
import UniformTypeIdentifiers

private let canvasModuleType = UTType(exportedAs: "co.mateonunez.still.canvas-module")

/// A system drag session supplies lift, cursor tracking and the drop preview.
/// The payload is process-local; unrelated external text cannot rearrange the scene.
struct CanvasGridDrag: ViewModifier {
    let id: String
    let enabled: Bool
    let accent: Color
    @Binding var source: String?
    @Binding var lastTarget: String?
    var select: () -> Void
    var reorder: (String, String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder func body(content: Content) -> some View {
        Group {
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
                .overlay {
                    if source != nil && source != id && lastTarget == id {
                        RoundedRectangle(cornerRadius: 22).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .allowsHitTesting(false).accessibilityHidden(true)
                    }
                }
            } else { content }
        }.onChange(of: enabled) { _, enabled in if !enabled { source = nil; lastTarget = nil } }
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
    }
    func dropExited(info: DropInfo) { if lastTarget == target { lastTarget = nil } }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func performDrop(info: DropInfo) -> Bool {
        guard validateDrop(info: info) else { return false }
        if let source, source != target {
            withAnimation(reduceMotion ? nil : .smooth(duration: 0.24)) { reorder(source, target) }
        }
        source = nil; lastTarget = nil; return true
    }
}
