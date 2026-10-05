import AppKit

/// Reversible Command-Tab/Dock restrictions; this does not veto Spaces gestures.
@MainActor
final class DesktopPresentationPolicy {
    private var previous: NSApplication.PresentationOptions?
    func cover() {
        guard previous == nil else { return }
        previous = NSApp.presentationOptions
        NSApp.presentationOptions = [.hideDock, .autoHideMenuBar, .disableProcessSwitching]
    }
    func restore() {
        guard let previous else { return }
        self.previous = nil
        NSApp.presentationOptions = previous
    }
}
