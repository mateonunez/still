import AppKit
import OSLog
import StillWidgets
import StillPluginKit

struct NativeWidgetCard: Identifiable {
    let provider: UsageProvider
    let snapshot: UsageSnapshot?
    let status: String
    var isLastReported = false
    var id: UsageProvider { provider }
}

@MainActor
final class WidgetCenter: ObservableObject {
    @Published private(set) var enabled: Set<UsageProvider> = []
    @Published private(set) var cards: [NativeWidgetCard] = []
    @Published private(set) var fetching = false
    @Published private(set) var connectionIssue = ""
    @Published private(set) var activityEnabled: Set<UsageProvider> = []
    @Published private(set) var activityCards: [ExtensionCard] = []
    @Published var layout = "corner" { didSet { if persist { UserDefaults.standard.set(layout, forKey: "StillWidgetLayout") } } }
    @Published var side = "right" { didSet { if persist { UserDefaults.standard.set(side, forKey: "StillWidgetSide") } } }
    private var snapshot: UsageSnapshot?
    private var codexIssue: UsageFailure?
    private var lastFetch = Date.distantPast
    private var task: Task<Void, Never>?
    private var generation = UUID()
    private let persist: Bool
    private var suspended = false
    private var activityAfter = Date.distantPast
    private let logger = Logger(subsystem: "co.mateonunez.still.development", category: "usage")
    private var codexURL: URL?
    private let sourceRoot: URL

    init(persist: Bool = true, readOnlySources: Set<UsageProvider> = [], readOnlyActivitySources: Set<UsageProvider> = [], sourceRoot: URL? = nil) {
        self.persist = persist
        self.sourceRoot = sourceRoot ?? ClaudeBridgeInstaller.root
        codexURL = CodexUsageAdapter.locate()
        if persist {
            enabled = Set((UserDefaults.standard.stringArray(forKey: "StillWidgets") ?? []).compactMap(UsageProvider.init(rawValue:)))
            activityEnabled = Set((UserDefaults.standard.stringArray(forKey: "StillActivitySources") ?? []).compactMap(UsageProvider.init(rawValue:)))
            let saved = UserDefaults.standard.string(forKey: "StillWidgetLayout")
            layout = saved == "canvas" ? "canvas" : saved == "rail" ? "rail" : "corner"
            side = UserDefaults.standard.string(forKey: "StillWidgetSide") == "left" ? "left" : "right"
            if let path = UserDefaults.standard.string(forKey: "StillCodexExecutable") { codexURL = URL(fileURLWithPath: path) }
        } else { enabled = readOnlySources; activityEnabled = readOnlyActivitySources }
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

    func toggleActivity(_ provider: UsageProvider) {
        let connecting = !activityEnabled.contains(provider)
        do {
            try AgentHookInstaller.configure(provider, enabled: connecting)
            if connecting { activityEnabled.insert(provider) } else { activityEnabled.remove(provider) }
            connectionIssue = connecting && provider == .codex ? "In Codex, review and trust Still's commands using /hooks. Until then, activity is unavailable." : ""
            if persist { UserDefaults.standard.set(activityEnabled.map(\.rawValue).sorted(), forKey: "StillActivitySources") }
            rebuild()
        } catch { connectionIssue = "Activity configuration was not completed. Existing settings are preserved; check access and conflicts." }
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
        if !available { activityAfter = Date(); cancel(); snapshot = nil; rebuild(); return }
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
        activityCards = UsageProvider.allCases.filter { activityEnabled.contains($0) }.map { provider in
            let path = sourceRoot.appendingPathComponent("activity/\(provider.rawValue).json")
            let size = (try? FileManager.default.attributesOfItem(atPath: path.path)[.size] as? NSNumber)?.intValue ?? 0
            let data = size > 0 && size <= 65536 ? try? Data(contentsOf: path) : nil
            let value = data.flatMap { try? JSONDecoder().decode(ActivitySnapshot.self, from: $0) }
            let records = !suspended && value?.provider == provider ? (value?.current(now: now) ?? []).filter { $0.observedAt >= activityAfter } : []
            let attention = records.filter { $0.state == .attentionRequested }.count
            let working = records.filter { $0.state == .working }.count
            let completed = records.filter { $0.state == .completed }.count
            let failed = records.filter { $0.state == .failed }.count
            let interrupted = records.filter { $0.state == .interrupted }.count
            let state = attention > 0 ? "attentionRequested" : working > 0 ? "working" : failed > 0 ? "failed" : interrupted > 0 ? "interrupted" : completed > 0 ? "completed" : "unknown"
            let count = attention > 0 ? attention : working > 0 ? working : failed > 0 ? failed : interrupted > 0 ? interrupted : completed
            return ExtensionCard(id: provider.rawValue + "-activity", title: provider.title, kind: .agentActivity, quota: nil, observedAt: records.map(\.observedAt).max(), state: state, detail: suspended ? "Source paused" : records.isEmpty ? "No recent events · activity unavailable" : "Advisory hook signal · not pending approvals", count: count, isSample: false)
        }
        cards = UsageProvider.allCases.filter { enabled.contains($0) }.map { provider in
            if suspended { return NativeWidgetCard(provider: provider, snapshot: nil, status: "Source paused") }
            if provider == .codex {
                let current = snapshot.flatMap { $0.isUsable(now: now) ? $0 : nil }
                return NativeWidgetCard(provider: provider, snapshot: current, status: current != nil ? "Account quota · live client" : (fetching ? "Connecting to Codex…" : codexIssue?.message ?? "Waiting for quota"))
            }
            let path = sourceRoot.appendingPathComponent("usage/claude.json")
            let size = (try? FileManager.default.attributesOfItem(atPath: path.path)[.size] as? NSNumber)?.intValue ?? 0
            guard size > 0, size <= 65536, let data = try? Data(contentsOf: path),
                  let value = try? JSONDecoder().decode(UsageSnapshot.self, from: data), value.provider == .claude else {
                return NativeWidgetCard(provider: provider, snapshot: nil, status: "Waiting for Claude’s next response. Quota may be unavailable for this account.")
            }
            guard value.isUsable(now: now) else {
                if let historical = value.lastReported(now: now) { return NativeWidgetCard(provider: provider, snapshot: historical, status: "Last reported · waiting for a new Claude update", isLastReported: true) }
                return NativeWidgetCard(provider: provider, snapshot: nil, status: "Waiting for a new Claude usage update.")
            }
            return NativeWidgetCard(provider: provider, snapshot: value, status: "Client-reported quota · status line")
        }
    }
}
