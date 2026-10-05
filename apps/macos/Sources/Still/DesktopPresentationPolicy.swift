import AppKit

/// Reversible Command-Tab/Dock restrictions; this does not veto Spaces gestures.
@MainActor
final class DesktopPresentationPolicy {
    private var previous: NSApplication.PresentationOptions?
    private let read: @MainActor () -> NSApplication.PresentationOptions
    private let write: @MainActor (NSApplication.PresentationOptions) -> Void
    init(read: @escaping @MainActor () -> NSApplication.PresentationOptions = { NSApp.presentationOptions }, write: @escaping @MainActor (NSApplication.PresentationOptions) -> Void = { NSApp.presentationOptions = $0 }) { self.read = read; self.write = write }
    func cover() {
        if previous == nil { previous = read() }
        let desired: NSApplication.PresentationOptions = [.hideDock, .autoHideMenuBar, .disableProcessSwitching]
        if read() != desired { write(desired) }
    }
    func restore() {
        guard let previous else { return }
        self.previous = nil
        write(previous)
    }
}
