import AppKit
import StillPluginKit
import StillWidgets

struct ExtensionCard: Identifiable, Equatable {
    let id: String
    let title: String
    let kind: PluginCapability
    let quota: [UsageWindow]?
    let observedAt: Date?
    let state: String?
    let detail: String
    let count: Int?
    let isSample: Bool
}

@MainActor
final class PluginCenter: ObservableObject {
    @Published private(set) var manifests: [PluginManifest] = []
    @Published private(set) var enabled: Set<String> = []
    @Published private(set) var cards: [ExtensionCard] = []
    @Published private(set) var issue = ""
    @Published private(set) var selectedTemplate: String?
    private var sessions: [String: PluginSession] = [:]
    private let persist: Bool
    private let store = PluginStore(root: ClaudeBridgeInstaller.root.appendingPathComponent("plugins"))
    var template: PluginManifest? { manifests.first { $0.id == selectedTemplate } }

    init(persist: Bool = true) {
        self.persist = persist; manifests = store.list()
        if persist {
            selectedTemplate = UserDefaults.standard.string(forKey: "StillTemplate")
            for id in UserDefaults.standard.stringArray(forKey: "StillLocalPlugins") ?? [] {
                if let manifest = manifests.first(where: { $0.id == id && $0.kind == "metadata" }) { connect(manifest) }
            }
        }
    }

    func importPackage() {
        let panel = NSOpenPanel(); panel.canChooseFiles = false; panel.canChooseDirectories = true; panel.allowsMultipleSelection = false
        panel.title = "Import a .stillplugin package"; panel.prompt = "Import"
        if panel.runModal() == .OK, let url = panel.url {
            do { _ = try store.importPackage(url); manifests = store.list(); issue = "Package imported. No source was connected." }
            catch { issue = "Package was not imported. Check its manifest, size, files and existing ID." }
        }
    }

    func apply(_ manifest: PluginManifest?) {
        guard manifest == nil || manifest?.kind == "template" else { return }
        selectedTemplate = manifest?.id
        if persist { UserDefaults.standard.set(selectedTemplate, forKey: "StillTemplate") }
    }

    func connect(_ manifest: PluginManifest) {
        guard manifest.kind == "metadata" else { return }
        do {
            let connection = try store.connect(manifest)
            sessions[manifest.id] = PluginSession(manifest: manifest, connection: connection)
            enabled.insert(manifest.id); issue = "Local source enabled. Start your producer separately; Still runs no package code."; save()
            tick(available: true)
        } catch { issue = "Local source could not be connected." }
    }
    func disconnect(_ manifest: PluginManifest) {
        do { try store.disconnect(manifest.id); issue = "Local source disabled. Connection revoked." } catch { issue = "Source is disabled in Still; its connection files could not be removed." }
        sessions.removeValue(forKey: manifest.id); enabled.remove(manifest.id); save(); tick(available: true)
    }
    func inbox(_ manifest: PluginManifest) -> String { store.root.appendingPathComponent(manifest.id).path }
    func showInbox(_ manifest: PluginManifest) { NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: inbox(manifest)) }
    private func save() { if persist { UserDefaults.standard.set(enabled.sorted(), forKey: "StillLocalPlugins") } }

    func tick(available: Bool) {
        guard available else { sessions.keys.forEach { sessions[$0]?.clear() }; publish(\.cards, []); return }
        let now = Date(), uptime = ProcessInfo.processInfo.systemUptime
        let next = manifests.filter { enabled.contains($0.id) }.flatMap { manifest -> [ExtensionCard] in
            guard var session = sessions[manifest.id] else { return [] }
            if let data = try? store.readSnapshot(manifest.id) {
                switch session.accept(data, now: now, uptime: uptime) {
                case .success: break
                case .failure(.oldRevision): break // Same atomic file: preserve the original monotonic deadline.
                case .failure: session.clear()
                }
            } else { session.clear() }
            sessions[manifest.id] = session
            let current = session.current(uptime: uptime)
            return manifest.widgets.map { widget in
                let fact = current?.facts.first { $0.widgetID == widget.id }
                let observed = current.flatMap { wireDate($0.observedAt) }
                let quota = fact?.windows.map { windows in windows.map { UsageWindow(minutes: $0.minutes, usedPercent: $0.usedPercent, resetsAt: $0.resetsAt.flatMap(wireDate)) } }
                return ExtensionCard(id: manifest.id + "." + widget.id, title: manifest.name, kind: widget.kind, quota: quota, observedAt: observed, state: fact?.state?.rawValue, detail: fact == nil ? "Local metadata unavailable" : (current?.isSample == true ? "Sample · developer metadata" : "Local producer metadata"), count: fact?.count, isSample: current?.isSample ?? false)
            }
        }
        publish(\.cards, next)
    }
}
