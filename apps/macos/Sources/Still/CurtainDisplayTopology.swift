import AppKit

/// Dock/menu changes alter visibleFrame, not the physical coverage topology.
struct CurtainDisplay: Equatable {
    let id: UInt32
    let frame: NSRect
    let scale: CGFloat

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

    mutating func begin(_ current: [CurtainDisplay], force: Bool = false) -> Bool {
        guard !building, force || current != topology else { return false }
        building = true; topology = current
        return true
    }
    mutating func finish() { building = false }
    mutating func reset() { topology = nil }
}
