import AppKit
import CoreText
import SwiftUI
import StillNativePlugins
import Testing
@testable import Still

@Test(.enabled(if: ProcessInfo.processInfo.environment["STILL_LIVE_PLUGIN_PROBE"] == "1"))
@MainActor func probeConfiguredNativeSources() async throws {
    _ = NSApplication.shared
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let output = root.appendingPathComponent("out/verification/readiness-live-sources")
    await NativePluginRuntimeProbe.run(directory: output, taskProducer: root.appendingPathComponent("packages/still-plugins/src/task.mjs").path)
    let receipt = try JSONSerialization.jsonObject(with: Data(contentsOf: output.appendingPathComponent("native-plugins.json"))) as? [String: Any]
    #expect(receipt?["allPassed"] as? Bool == true)
}

@Test(.enabled(if: ProcessInfo.processInfo.environment["STILL_EXPORT_DESIGN"] != nil))
@MainActor func exportStillOwnedDesignViews() throws {
    _ = NSApplication.shared
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    CTFontManagerRegisterFontsForURL(root.appendingPathComponent("design/fonts/InstrumentSerif-Regular.ttf") as CFURL, .process, nil)
    let marketing = ProcessInfo.processInfo.environment["STILL_EXPORT_MARKETING"] == "1"
    let output = root.appendingPathComponent(marketing ? "out/verification/marketing-native" : "out/verification/design-refinement")
    try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: scratch) }
    let store = NativePluginStore(root: scratch)
    try store.prepareMissingConfigurations()
    let sourceIDs: [NativePluginID] = marketing ? [.worldClock] : [.worldClock, .macPulse]
    for id in sourceIDs {
        var config = NativePluginConfiguration(plugin: id); config.enabled = true; config.visible = true
        try store.write(config)
    }
    let widgets = WidgetCenter(persist: false)
    let center = NativePluginCenter(widgets: widgets, root: scratch)
    center.tick(available: true)
    defer { center.stop(); widgets.stop() }
    for theme in StillTheme.allCases {
        for appearance in [StillAppearance.light, .dark] {
            let model = CurtainPresentation(); model.theme = theme; model.appearance = appearance
            let host = NSHostingView(rootView: ScreenEditorView(center: center, presentation: model, finish: {}).frame(width: 1280, height: 800))
            host.frame = CGRect(x: 0, y: 0, width: 1280, height: 800)
            let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false; window.contentView = host
            host.layoutSubtreeIfNeeded()
            let bitmap = try #require(host.bitmapImageRepForCachingDisplay(in: host.bounds))
            host.cacheDisplay(in: host.bounds, to: bitmap)
            let png = try #require(bitmap.representation(using: .png, properties: [:]))
            try png.write(to: output.appendingPathComponent("editor-\(theme.rawValue)-\(appearance.rawValue).png"))
            window.close()
        }
    }
}
