import AppKit
import SwiftUI
import Testing
@testable import Still

@Test @MainActor func curtainHostingUsesEachPanelViewport() {
    _ = NSApplication.shared
    let model = CurtainPresentation()
    model.widgetLayout = "canvas"
    for frame in [NSRect(x: -2560, y: 900, width: 1512, height: 982), NSRect(x: 0, y: 0, width: 2560, height: 1440)] {
        let panel = NSPanel(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        panel.isReleasedWhenClosed = false
        let host = CurtainDisplay.hostingView(CurtainView(presentation: model, authenticate: {}, evidenceRender: true), viewport: frame.size)
        panel.contentView = host
        host.layoutSubtreeIfNeeded()
        #expect(host.bounds.size == frame.size)
        #expect(panel.frame == frame)
        #expect(host.frame.origin == .zero)
        #expect(host.sizingOptions == [])
        panel.close()
    }
}
