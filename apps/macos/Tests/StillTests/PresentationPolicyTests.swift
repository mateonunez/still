import AppKit
import Testing
@testable import Still

@Test @MainActor func presentationReassertionPreservesTheOriginalRestorePoint() {
    var options: NSApplication.PresentationOptions = [.autoHideDock]
    let policy = DesktopPresentationPolicy(read: { options }, write: { options = $0 })
    policy.cover()
    options = [] // Model AppKit replacing the requested options across an activation boundary.
    policy.cover()
    #expect(options.contains(.disableProcessSwitching))
    #expect(options.contains(.hideDock))
    policy.restore()
    #expect(options == [.autoHideDock])
    policy.restore()
    #expect(options == [.autoHideDock])
}
