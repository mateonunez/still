import AppKit
import LocalAuthentication
import LocalAuthenticationEmbeddedUI
import Testing
@testable import Still

@Test @MainActor func detachedBiometricChildMustNotStartAuthentication() async {
    _ = NSApplication.shared
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100), styleMask: [.borderless], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    let view = LAAuthenticationView(context: LAContext(), controlSize: .regular)
    var starts = 0
    let container = EmbeddedTouchID.AuthenticationContainer(authenticationView: view, ready: { starts += 1 })
    window.contentView = container
    // Reproduce the traced split: container attached, biometric child detached before queued readiness.
    view.removeFromSuperview()
    for _ in 0..<10 { await Task.yield() }
    #expect(container.window === window)
    #expect(view.window == nil)
    #expect(starts == 0)
    container.addSubview(view)
    container.checkReadiness()
    for _ in 0..<10 { await Task.yield() }
    #expect(view.window === window)
    #expect(starts == 1)
    container.checkReadiness()
    for _ in 0..<10 { await Task.yield() }
    #expect(starts == 1)
    window.close()
}

@Test func repeatedScreenNotificationsDoNotReplaceAnAuthenticationView() {
    let display = CurtainDisplay(id: 1, frame: NSRect(x: 0, y: 0, width: 1440, height: 900), scale: 2)
    var gate = CurtainRebuildGate()
    let first = gate.begin([display], force: true)
    #expect(first)
    let reentrant = gate.begin([display], force: true)
    #expect(!reentrant)
    gate.finish()
    for _ in 0..<5 {
        let duplicate = gate.begin([display])
        #expect(!duplicate)
    }
    let moved = CurtainDisplay(id: 1, frame: NSRect(x: 100, y: 0, width: 1440, height: 900), scale: 2)
    let changed = gate.begin([moved])
    #expect(changed)
    gate.finish()
    let scaleChanged = gate.begin([CurtainDisplay(id: 1, frame: moved.frame, scale: 1)])
    #expect(scaleChanged)
    gate.finish()
    let unplugged = gate.begin([])
    #expect(unplugged)
    gate.finish()
    gate.reset()
    let newSession = gate.begin([display], force: true)
    #expect(newSession)
}

@Test func oneContentDisplayTracksTheSystemPrimaryAndFallback() {
    let displays = [CurtainDisplay(id: 1, frame: .zero, scale: 2), CurtainDisplay(id: 2, frame: .zero, scale: 1)]
    #expect(CurtainDisplay.primaryID(in: displays, mainID: 2) == 2)
    #expect(CurtainDisplay.primaryID(in: displays, mainID: 99) == 1)
    #expect(CurtainDisplay.primaryID(in: [], mainID: 2) == nil)
    var gate = CurtainRebuildGate()
    let initial = gate.begin(displays, primaryID: 1)
    #expect(initial)
    gate.finish()
    let unchanged = gate.begin(displays, primaryID: 1)
    #expect(!unchanged)
    let changedPrimary = gate.begin(displays, primaryID: 2)
    #expect(changedPrimary)
}
