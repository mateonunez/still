import AppKit
import SwiftUI

/// Explicit developer export of our own view and non-sensitive window geometry.
/// Never captures the desktop, other applications, credentials or activity.
@MainActor
enum NativeEvidence {
    static func exportIfRequested(panels: [NSPanel]) {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "--evidence-directory"),
              arguments.indices.contains(flag + 1) else { return }
        let directory = URL(fileURLWithPath: arguments[flag + 1], isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let screens = NSScreen.screens
            let geometry: [[String: Any]] = panels.enumerated().map { index, panel in
                [
                    "displayIndex": index,
                    "panelFrame": NSStringFromRect(panel.frame),
                    "screenFrame": index < screens.count ? NSStringFromRect(screens[index].frame) : "missing",
                    "matchesScreenFrame": index < screens.count && panel.frame == screens[index].frame,
                    "visible": panel.isVisible,
                    "level": panel.level.rawValue,
                    "collectionBehavior": panel.collectionBehavior.rawValue,
                    "stationary": panel.collectionBehavior.contains(.stationary),
                    "joinsAllSpaces": panel.collectionBehavior.contains(.canJoinAllSpaces),
                    "managed": panel.collectionBehavior.contains(.managed),
                    "transient": panel.collectionBehavior.contains(.transient),
                    "joinsAllApplications": panel.collectionBehavior.contains(.canJoinAllApplications),
                ]
            }
            let receipt: [String: Any] = [
                "kind": panels.isEmpty ? "native-view-render-only" : "native-runtime-structural-receipt",
                "timestamp": Date().ISO8601Format(),
                "os": ProcessInfo.processInfo.operatingSystemVersionString,
                "bundleIdentifier": Bundle.main.bundleIdentifier ?? "unset",
                "displayCount": screens.count,
                "panelCount": panels.count,
                "expectedCurtainLevel": NSWindow.Level.screenSaver.rawValue,
                "displayFontRegistered": NSFont(name: "InstrumentSerif-Regular", size: 32) != nil,
                "windows": geometry,
                "boundary": "Geometry and isVisible do not prove visual coverage, authentication or background work.",
            ]
            let data = try JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: directory.appendingPathComponent("runtime.json"), options: .atomic)
            for appearance in [StillAppearance.light, .dark] {
                let model = CurtainPresentation()
                model.appearance = appearance
                try save(
                    CurtainView(presentation: model, authenticate: {}, evidenceRender: true)
                        .frame(width: 1440, height: 900),
                    to: directory.appendingPathComponent("porcelain-\(appearance.rawValue).png")
                )
            }
            try save(PreferencesView(controls: SessionControls(persist: false)), to: directory.appendingPathComponent("preferences.png"))
            try save(WelcomeView(showStill: {}), to: directory.appendingPathComponent("welcome.png"))
            if let tiff = StillMark.menuImage(covered: false).tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiff),
               let png = bitmap.representation(using: .png, properties: [:]) {
                try png.write(to: directory.appendingPathComponent("menu-mark.png"), options: .atomic)

            }
        } catch {
            // Diagnostic exports never change curtain/authentication state.
            FileHandle.standardError.write(Data("Still evidence export failed: \(error)\n".utf8))
        }
    }

    private static func save<Content: View>(_ content: Content, to url: URL) throws {
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            throw EvidenceError.renderFailed
        }
        try png.write(to: url, options: .atomic)
    }

    private enum EvidenceError: Error { case renderFailed }
}
