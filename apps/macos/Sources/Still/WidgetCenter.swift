import AppKit
import OSLog
import StillWidgets

struct NativeWidgetCard: Identifiable {
    let provider: UsageProvider
    let snapshot: UsageSnapshot?
    let status: String
    var id: UsageProvider { provider }
}

@MainActor
final class WidgetCenter: ObservableObject {
    @Published private(set) var enabled: Set<UsageProvider> = []
    @Published private(set) var cards: [NativeWidgetCard] = []
    @Published private(set) var fetching = false
    @Published private(set) var connectionIssue = ""
    @Published var layout = "corner" { didSet { if persist { UserDefaults.standard.set(layout, forKey: "StillWidgetLayout") } } }
    private var snapshot: UsageSnapshot?
    private var codexIssue: UsageFailure?
    private var lastFetch = Date.distantPast
    private var task: Task<Void, Never>?
    private var generation = UUID()
    private let persist: Bool
    private var suspended = false
    private let logger = Logger(subsystem: "co.mateonunez.still.development", category: "usage")
    private var codexURL: URL?

    init(persist: Bool = true) {
        self.persist = persist
        codexURL = CodexUsageAdapter.locate()
        if persist {
            enabled = Set((UserDefaults.standard.stringArray(forKey: "StillWidgets") ?? []).compactMap(UsageProvider.init(rawValue:)))
            let saved = UserDefaults.standard.string(forKey: "StillWidgetLayout")
            layout = saved == "rail" ? "rail" : "corner"
            if let path = UserDefaults.standard.string(forKey: "StillCodexExecutable") { codexURL = URL(fileURLWithPath: path) }
        }
        rebuild()
    }

    func connect(_ provider: UsageProvider) {
        guard !enabled.contains(provider) else { return }
        if provider == .claude {
            do { try ClaudeBridgeInstaller.install() } catch { connectionIssue = "Claude connection was not changed. Check access to its settings, or restore a conflicting status line first."; return }
        }
        enabled.insert(provider); connectionIssue = ""; save(); if provider == .codex { lastFetch = .distantPast }; tick(available: true)
    }

    func disconnect(_ provider: UsageProvider) {
        if provider == .claude {
            do { try ClaudeBridgeInstaller.uninstall() } catch { connectionIssue = "Claude’s status line changed outside Still. Restore it manually; Still will not overwrite it." }
        }
        enabled.remove(provider)
        if provider == .codex { cancel(); snapshot = nil; codexIssue = nil }
        save(); rebuild()
    }

    func chooseCodex() {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.title = "Choose the installed Codex executable"
        if panel.runModal() == .OK, let url = panel.url, FileManager.default.isExecutableFile(atPath: url.path) {
            cancel(); codexURL = url; snapshot = nil; lastFetch = .distantPast
            if persist { UserDefaults.standard.set(url.path, forKey: "StillCodexExecutable") }
            tick(available: !suspended)
        }
    }

    var canRefresh: Bool { !fetching && Date().timeIntervalSince(lastFetch) >= 60 }
    func refresh() { guard canRefresh else { return }; tick(available: !suspended) }

    func tick(available: Bool) {
        suspended = !available
        if !available { cancel(); snapshot = nil; rebuild(); return }
        if enabled.contains(.codex), !fetching, Date().timeIntervalSince(lastFetch) >= 60 {
            lastFetch = Date()
            guard let executable = codexURL else { codexIssue = .missingClient; rebuild(); return }
            fetching = true
            let attempt = UUID(); generation = attempt
            task = Task { [weak self] in
                let result = await CodexUsageAdapter.fetch(executable: executable)
                guard let self, !Task.isCancelled, self.generation == attempt, self.enabled.contains(.codex), !self.suspended else { return }
                self.fetching = false; self.task = nil
                switch result {
                case .success(let value): self.snapshot = value; self.codexIssue = nil
                case .failure(let error):
                    self.snapshot = nil; self.codexIssue = error
                    self.logger.info("usage_failed provider=codex code=\(error.rawValue, privacy: .public)")
                }
                self.rebuild()
            }
        }
        rebuild()
    }

    func stop() { cancel(); snapshot = nil; cards = [] }
    private func cancel() { generation = UUID(); task?.cancel(); task = nil; fetching = false }
    private func save() { if persist { UserDefaults.standard.set(enabled.map(\.rawValue).sorted(), forKey: "StillWidgets") } }

    private func rebuild() {
        let now = Date()
        cards = UsageProvider.allCases.filter { enabled.contains($0) }.map { provider in
            if suspended { return NativeWidgetCard(provider: provider, snapshot: nil, status: "Source paused") }
            if provider == .codex {
                let current = snapshot.flatMap { $0.isUsable(now: now) ? $0 : nil }
                return NativeWidgetCard(provider: provider, snapshot: current, status: current != nil ? "Account quota · live client" : (fetching ? "Connecting to Codex…" : codexIssue?.message ?? "Waiting for quota"))
            }
            let path = ClaudeBridgeInstaller.root.appendingPathComponent("usage/claude.json")
            let size = (try? FileManager.default.attributesOfItem(atPath: path.path)[.size] as? NSNumber)?.intValue ?? 0
            guard size > 0, size <= 65536, let data = try? Data(contentsOf: path),
                  let value = try? JSONDecoder().decode(UsageSnapshot.self, from: data), value.provider == .claude else {
                return NativeWidgetCard(provider: provider, snapshot: nil, status: "Waiting for Claude’s next response. Quota may be unavailable for this account.")
            }
            guard value.isUsable(now: now) else { return NativeWidgetCard(provider: provider, snapshot: nil, status: "Client data is out of date. Waiting for a new quota observation.") }
            return NativeWidgetCard(provider: provider, snapshot: value, status: "Client-reported quota · status line")
        }
    }
}
