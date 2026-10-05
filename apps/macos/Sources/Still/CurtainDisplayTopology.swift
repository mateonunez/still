import AppKit
import SwiftUI

/// Dock/menu changes alter visibleFrame, not the physical coverage topology.
struct CurtainDisplay: Equatable {
    let id: UInt32
    let frame: NSRect
    let scale: CGFloat

    static func primaryID(in displays: [Self], mainID: UInt32) -> UInt32? {
        displays.first(where: { $0.id == mainID })?.id ?? displays.first?.id
    }

    @MainActor static var mainScreen: NSScreen? {
        NSScreen.screens.first { ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value == CGMainDisplayID() } ?? NSScreen.screens.first
    }
    @MainActor static func hostingView<Content: View>(_ content: Content, viewport: CGSize) -> NSHostingView<Content> {
        let host = NSHostingView(rootView: content)
        host.sizingOptions = []
        host.frame = NSRect(origin: .zero, size: viewport)
        host.autoresizingMask = [.width, .height]
        return host
    }

    static func current() -> [Self] {
        NSScreen.screens.map {
            Self(id: ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0,
                 frame: $0.frame, scale: $0.backingScaleFactor)
        }.sorted { $0.id < $1.id }
    }
}

struct CurtainRebuildGate {
    private var topology: [CurtainDisplay]?
    private var building = false
    private var primaryID: UInt32?

    mutating func begin(_ current: [CurtainDisplay], primaryID: UInt32? = nil, force: Bool = false) -> Bool {
        guard !building, force || current != topology || primaryID != self.primaryID else { return false }
        building = true; topology = current; self.primaryID = primaryID
        return true
    }
    mutating func finish() { building = false }
    mutating func reset() { topology = nil; primaryID = nil }
}
