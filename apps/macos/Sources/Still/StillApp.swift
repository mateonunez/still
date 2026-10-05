import AppKit
import CoreText
import SwiftUI

@main
struct StillApp: App {
    @NSApplicationDelegateAdaptor(StillDelegate.self) private var delegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
final class StillDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: CurtainCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let fontURL = Bundle.main.url(forResource: "InstrumentSerif-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        NSApp.setActivationPolicy(.accessory)
        let arguments = ProcessInfo.processInfo.arguments
        if let flag = arguments.firstIndex(of: "--native-plugins-probe"), arguments.indices.contains(flag + 1) {
            let directory = URL(fileURLWithPath: arguments[flag + 1], isDirectory: true)
            let producer = arguments.firstIndex(of: "--task-producer").flatMap { arguments.indices.contains($0 + 1) ? arguments[$0 + 1] : nil }
            Task { @MainActor in await NativePluginRuntimeProbe.run(directory: directory, taskProducer: producer); NSApp.terminate(nil) }; return
        }
        if let flag = arguments.firstIndex(of: "--presentation-probe"), arguments.indices.contains(flag + 1) {
            PresentationRuntimeProbe.run(directory: URL(fileURLWithPath: arguments[flag + 1]))
            NSApp.terminate(nil); return
        }
        if let flag = arguments.firstIndex(of: "--widget-probe"), arguments.indices.contains(flag + 1) {
            let directory = URL(fileURLWithPath: arguments[flag + 1], isDirectory: true)
            Task { @MainActor in await WidgetRuntimeProbe.run(directory: directory); NSApp.terminate(nil) }
            return
        }
        if let flag = arguments.firstIndex(of: "--energy-probe"), arguments.indices.contains(flag + 1) {
            let directory = URL(fileURLWithPath: arguments[flag + 1], isDirectory: true)
            Task { @MainActor in
                await EnergyRuntimeProbe.run(directory: directory)
                NSApp.terminate(nil)
            }
            return
        }
        if ProcessInfo.processInfo.arguments.contains("--render-only") {
            NativeEvidence.exportIfRequested(panels: [])
            NSApp.terminate(nil)
            return
        }
        coordinator = CurtainCoordinator()
        coordinator?.installMenu()
        if arguments.contains("--configure-native-plugins") { coordinator?.configureNativePlugins() }
        if arguments.contains("--editor") {
            coordinator?.showScreenEditor()
        } else if ProcessInfo.processInfo.arguments.contains("--cover") {
            coordinator?.cover()
        } else if arguments.contains("--widgets") || arguments.contains("--plugins") {
            coordinator?.showWidgets()
        } else {
            coordinator?.showWelcomeIfNeeded()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { coordinator?.showWelcome() }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        coordinator?.tearDown()
    }
}
