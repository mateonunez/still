import AppKit
import EventKit
import OSLog
import StillNativePlugins
import StillWidgets

struct AgentDiscovery: Identifiable {
    let provider: UsageProvider
    let executable: URL?
    var id: UsageProvider { provider }
}

@MainActor
final class NativePluginCenter: ObservableObject {
    @Published private(set) var configurations: [NativePluginID: NativePluginConfiguration] = [:]
    @Published private(set) var cards: [NativePluginID: NativePluginCard] = [:]
    @Published private(set) var discovered: [AgentDiscovery] = []
    @Published private(set) var issue = ""
    @Published private(set) var calendarChoices: [EKCalendar] = []
    @Published private(set) var requestingSpotify = false
    @Published private(set) var spotifyConnectionStatus = ""
    @Published private(set) var order: [NativePluginID] = NativePluginID.allCases
    @Published private(set) var composition = ScreenComposition()
    private let store: NativePluginStore
    private let widgets: WidgetCenter
    private let calendar = CalendarPluginSource()
    private let pulse = MacPulseSource()
    private var fetching: [NativePluginID: Task<Void, Never>] = [:]
    private var spotifyAuthorization: Task<Void, Never>?
    private var generations: [NativePluginID: UUID] = [:]
    private var lastFetch: [NativePluginID: Date] = [:]
    private var timerDeadline: TimeInterval?
    private var taskConnection: UUID?
    private var taskRevision: UInt64 = 0
    private var taskReceipt: TaskReceipt?
    private var taskDeadline: TimeInterval = 0
    private var deadlines: [NativePluginID: TimeInterval] = [:]
    private var suspended = false
    private let persist: Bool
    private let persistArrangement: Bool
    private let logger = Logger(subsystem: "co.mateonunez.still.development", category: "native-plugins")

    init(widgets: WidgetCenter, persist: Bool = true, root: URL? = nil) {
        self.widgets = widgets; self.persist = persist
        persistArrangement = persist && root == nil
        if persistArrangement {
            if let data = UserDefaults.standard.data(forKey: "StillScreenComposition"), let saved = ScreenComposition.decode(data) { composition = saved }
            let saved = (UserDefaults.standard.stringArray(forKey: "StillNativePluginOrder") ?? []).compactMap(NativePluginID.init(rawValue:))
            order = saved.reduce(into: []) { if !$0.contains($1) { $0.append($1) } } + NativePluginID.allCases.filter { !saved.contains($0) }
        }
        store = NativePluginStore(root: root ?? ClaudeBridgeInstaller.root.appendingPathComponent("native-plugins"))
        if persist {
            do { try store.prepareMissingConfigurations() }
            catch { issue = "Some plugins could not be prepared. Check local file access; existing settings were preserved." }
            for id in NativePluginID.allCases { configurations[id] = store.configuration(id) }
        }
        discover()
        if configurations[.taskWatch]?.enabled == true { rotateTasks() }
    }
    var installed: [NativePluginID] { order.filter { configurations[$0] != nil } }
    var visibleIDs: [NativePluginID] { installed.filter { configurations[$0]?.enabled == true && configurations[$0]?.visible == true } }
    func place(_ id: String, _ placement: CanvasPlacement) {
        guard id == "clock" || NativePluginID(rawValue: id) != nil, placement.x.isFinite, placement.y.isFinite, placement.width == nil || placement.width!.isFinite else { return }
        composition.placements[id] = placement.fitted()
        saveComposition()
    }
    func setLayout(_ mode: CanvasLayoutMode) { composition.layout = mode; saveComposition() }
    func setGridWidth(_ width: Double?) {
        guard width == nil || (width!.isFinite && (180...600).contains(width!)) else { return }
        composition.gridWidth = width; saveComposition()
    }
    func resetComposition() { composition = ScreenComposition(); saveComposition() }
    func applyPreset(_ preset: CanvasPreset) { composition = ScreenComposition.preset(preset, ids: visibleIDs); saveComposition() }
    private func saveComposition() { if persistArrangement, let data = try? JSONEncoder().encode(composition) { UserDefaults.standard.set(data, forKey: "StillScreenComposition") } }
    func move(_ id: NativePluginID, before target: NativePluginID) {
        guard id != target, order.contains(id), let destination = order.filter({ $0 != id }).firstIndex(of: target) else { return }
        var updated = order.filter { $0 != id }; updated.insert(id, at: destination); order = updated
        if persistArrangement { UserDefaults.standard.set(order.map(\.rawValue), forKey: "StillNativePluginOrder") }
    }
    func move(_ id: NativePluginID, by delta: Int) {
        guard let index = visibleIDs.firstIndex(of: id), visibleIDs.indices.contains(index + delta) else { return }
        reorderVisible(id, over: visibleIDs[index + delta])
    }
    func reorderVisible(_ id: NativePluginID, over target: NativePluginID) {
        guard id != target, let source = visibleIDs.firstIndex(of: id), let destination = visibleIDs.firstIndex(of: target) else { return }
        var updated = order.filter { $0 != id }
        guard let index = updated.firstIndex(of: target) else { return }
        updated.insert(id, at: index + (destination > source ? 1 : 0)); order = updated
        if persistArrangement { UserDefaults.standard.set(order.map(\.rawValue), forKey: "StillNativePluginOrder") }
    }
    var visibleCards: [NativePluginCard] { installed.filter { configurations[$0]?.enabled == true && configurations[$0]?.visible == true }.compactMap { cards[$0]?.current(now: Date()) } }
    var agentsEnabled: Bool { configurations[.agents]?.enabled == true }
    var taskInbox: URL { store.directory(.taskWatch) }

    func discover() {
        discovered = UsageProvider.allCases.map { AgentDiscovery(provider: $0, executable: $0 == .codex ? CodexUsageAdapter.locate() : NativeReadCommand.locate("claude")) }
        calendarChoices = calendar.calendars
    }
    func configureDiscoveredAgents() {
        guard agentsEnabled else { return }
        for client in discovered where client.executable != nil { widgets.connect(client.provider) }
    }
    func setEnabled(_ id: NativePluginID, _ enabled: Bool) {
        guard var config = configurations[id] else { return }
        config.enabled = enabled
        guard save(config) else { return }
        cancel(id); cards[id] = nil; deadlines[id] = nil; lastFetch[id] = nil
        if id == .spotify, !enabled { cancelSpotifyAuthorization() }
        if id == .taskWatch { taskReceipt = nil; taskRevision = 0; rotateTasks() }
        if id == .quietTimer, !enabled { timerDeadline = nil }
        if id == .agents, !enabled {
            for provider in UsageProvider.allCases {
                if widgets.activityEnabled.contains(provider) { widgets.toggleActivity(provider) }
                widgets.disconnect(provider)
            }
        }
        tick(available: !suspended)
    }
    func setVisible(_ id: NativePluginID, _ visible: Bool) {
        guard var config = configurations[id] else { return }
        config.visible = visible; _ = save(config)
    }
    func update(_ id: NativePluginID, settings: NativePluginSettings) {
        guard var config = configurations[id] else { return }
        config.settings = settings
        guard save(config) else { return }
        cancel(id); cards[id] = nil; lastFetch[id] = nil
        tick(available: !suspended)
    }
    @discardableResult private func save(_ config: NativePluginConfiguration) -> Bool {
        guard config.settings.valid(for: config.plugin) else { issue = "Check the plugin settings. No changes were saved."; return false }
        if persist {
            do { try store.write(config) } catch { issue = "Plugin settings could not be saved. Check local file access."; return false }
        }
        configurations[config.plugin] = config; issue = ""; return true
    }
    func refresh(_ id: NativePluginID) { guard fetching[id] == nil else { return }; lastFetch[id] = nil; tick(available: !suspended) }
    func startTimer() {
        guard configurations[.quietTimer]?.enabled == true else { return }
        timerDeadline = ProcessInfo.processInfo.systemUptime + Double((configurations[.quietTimer]?.settings.timerMinutes ?? 10) * 60)
        lastFetch[.quietTimer] = nil; tick(available: !suspended)
    }
    func stopTimer() { timerDeadline = nil; lastFetch[.quietTimer] = nil; tick(available: !suspended) }
    func requestCalendar() {
        Task { [weak self] in guard let self else { return }; let granted = await calendar.requestAccess(); calendarChoices = calendar.calendars; issue = granted ? "Choose a calendar below." : "Calendar access was not granted. Enable it in System Settings if desired."; refresh(.nextUp) }
    }
    func requestSpotify() {
        guard !requestingSpotify else { return }
        guard NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").contains(where: { !$0.isTerminated }), let helper = Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent("StillSpotifyBridge") else { issue = "Open Spotify before connecting it."; spotifyConnectionStatus = issue; return }
        requestingSpotify = true
        spotifyConnectionStatus = "Waiting up to 30 seconds for Spotify or macOS."
        spotifyAuthorization = Task { [weak self] in
            let result = await NativeReadCommand.fetch(executable: helper, arguments: ["--authorize"], timeoutSeconds: 30)
            guard let self, !Task.isCancelled else { return }
            self.requestingSpotify = false
            self.spotifyAuthorization = nil
            var connected = false
            let message: String
            switch result {
            case .success(let data):
                let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                connected = object?["state"] as? String == "ready"
                if connected { message = "Spotify connected. Playback is read-only." }
                else if object?["state"] as? String == "permissionRequired" { message = "macOS denied Spotify access. Review Privacy & Security → Automation, then retry." }
                else if object?["errorCode"] as? Int == -1712 { message = "Spotify did not respond. Keep Spotify open and try connecting again." }
                else { message = "Spotify playback is unavailable. Keep Spotify open and try again." }
            case .failure(.timeout): message = "The connection timed out. Keep Spotify open and try again."
            case .failure: message = "Spotify could not connect. Try again with Spotify open."
            }
            if connected, var settings = self.configurations[.spotify]?.settings { settings.spotifyAuthorized = true; self.update(.spotify, settings: settings) }
            self.issue = message
            self.spotifyConnectionStatus = self.issue
            self.refresh(.spotify)
        }
    }
    func cancelSpotifyAuthorization() { spotifyAuthorization?.cancel(); spotifyAuthorization = nil; requestingSpotify = false; spotifyConnectionStatus = "Spotify connection canceled." }
    func tick(available: Bool) {
        if !available {
            if requestingSpotify { cancelSpotifyAuthorization() }
            if !suspended { for id in installed { cancel(id) }; taskReceipt = nil; taskRevision = 0; rotateTasks() }
            suspended = true
            for id in installed where configurations[id]?.enabled == true { cards[id] = NativePluginCard(id, state: .paused, detail: "Source paused") }
            return
        }
        if suspended { lastFetch = [:] }; suspended = false
        for id in installed where configurations[id]?.enabled == true {
            guard let config = configurations[id] else { continue }
            if let deadline = deadlines[id], ProcessInfo.processInfo.systemUptime >= deadline { cards[id] = NativePluginCard(id, state: .unavailable, detail: "Source data expired. Refresh or check its connection."); deadlines[id] = nil }
            if let value = cards[id] { cards[id] = value.current(now: Date()) }
            guard fetching[id] == nil, Date().timeIntervalSince(lastFetch[id] ?? .distantPast) >= id.refreshSeconds else { continue }
            lastFetch[id] = Date()
            switch id {
            case .agents: cards[id] = agentsCard()
            case .worldClock: cards[id] = NativePluginCard(id, payload: .clocks(config.settings.clocks), state: .ready, detail: "Local time zones", observedAt: Date())
            case .quietTimer: cards[id] = NativePluginCard(id, payload: .timer(deadline: timerDeadline), state: .ready, detail: "Local timer · no automatic return", observedAt: Date())
            case .macPulse: cards[id] = pulse.read(config.settings)
            case .nextUp: cards[id] = calendar.read(config.settings)
            case .taskWatch: cards[id] = taskCard()
            default:
                let generation = UUID(); generations[id] = generation
                if cards[id] == nil { cards[id] = NativePluginCard(id, state: .refreshing, detail: "Connecting to source…") }
                fetching[id] = Task { [weak self] in
                    let card = await Self.fetch(id, settings: config.settings)
                    guard let self, !Task.isCancelled, self.generations[id] == generation, !self.suspended, self.configurations[id]?.enabled == true else { return }
                    self.fetching[id] = nil; self.cards[id] = card
                    self.deadlines[id] = card.expiresAt.map { ProcessInfo.processInfo.systemUptime + min(1800, max(0, $0.timeIntervalSinceNow)) }
                    if card.state != .ready { self.logger.info("source_state plugin=\(id.rawValue, privacy: .public) state=\(card.state.rawValue, privacy: .public)") }
                }
            }
        }
    }
    func stop() { cancelSpotifyAuthorization(); for id in installed { cancel(id) }; cards = [:]; timerDeadline = nil; taskReceipt = nil; rotateTasks() }
    private func cancel(_ id: NativePluginID) { generations[id] = UUID(); fetching[id]?.cancel(); fetching[id] = nil }
    private func rotateTasks() { guard persist, configurations[.taskWatch] != nil else { return }; do { taskConnection = try store.rotateTaskConnection(); taskRevision = 0 } catch { taskConnection = nil; issue = "Task Watch could not create its local connection." } }
    private func taskCard() -> NativePluginCard {
        let now = Date()
        guard let taskConnection else { return NativePluginCard(.taskWatch, state: .setupRequired, detail: "Task Watch connection unavailable. Re-enable the plugin.") }
        if let data = try? store.readTasks(), let value = TaskReceipt.decode(data, connectionID: taskConnection, revision: taskRevision, now: now) { taskRevision = value.revision; taskReceipt = value; taskDeadline = ProcessInfo.processInfo.systemUptime + min(300, value.expiresAt.timeIntervalSince(now)) }
        guard let value = taskReceipt, value.expiresAt > now, ProcessInfo.processInfo.systemUptime < taskDeadline else { return NativePluginCard(.taskWatch, state: .unavailable, detail: "No registered task yet. Use the Task Watch CLI.") }
        let current = value.tasks.filter { $0.expiresAt.map { $0 > now } ?? true }
        let tasks = configurations[.taskWatch]?.settings.showCompletedTasks == false ? current.filter { [.working, .queued].contains($0.state) } : current
        return NativePluginCard(.taskWatch, payload: .work(tasks), state: .ready, detail: "Explicit local tasks · output not read", observedAt: value.observedAt, expiresAt: value.expiresAt)
    }
    private func agentsCard() -> NativePluginCard {
        let metrics = discovered.map { client -> MetricFact in
            let quota = widgets.cards.first { $0.provider == client.provider }
            let windows = quota?.snapshot?.windows.map { "\($0.title) \(Int($0.usedPercent))%" }.joined(separator: " · ")
            let activity = widgets.activityCards.first { $0.id == client.provider.rawValue + "-activity" }
            let signal = activity.flatMap { $0.state == "unknown" ? nil : activityTitle($0.state) }
            let reported = windows.map { value in
                guard quota?.isLastReported == true, let observedAt = quota?.snapshot?.observedAt else { return value }
                return "Last reported · \(value) · \(observedAt.formatted(.relative(presentation: .numeric)))"
            }
            let value = [reported, signal].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
            return MetricFact(client.provider.title, !value.isEmpty ? value : quota?.status ?? (client.executable == nil ? "Not installed" : "Installed · configure quota/activity"))
        }
        return NativePluginCard(.agents, payload: .agents(metrics), state: .ready, detail: "Local clients · attention is advisory", observedAt: Date())
    }
    private static func fetch(_ id: NativePluginID, settings: NativePluginSettings) async -> NativePluginCard {
        if id == .weather { return await WeatherPluginSource.read(settings) }
        if id == .spotify { return settings.spotifyAuthorized ? await SpotifyPluginSource.read(showTitles: settings.showTitles) : NativePluginCard(.spotify, state: .permissionRequired, detail: "Connect local Spotify in plugin settings.") }
        if id == .buildWatch && settings.repository.isEmpty || id == .deployWatch && settings.projectID.isEmpty { return NativePluginCard(id, state: .setupRequired, detail: "Choose the source in plugin settings.") }
        let arguments = id == .buildWatch ? ["api", "--method", "GET", "repos/\(settings.repository)/actions/runs?per_page=1"] : ["api", "/v6/deployments?projectId=\(settings.projectID)&teamId=\(settings.teamID)&limit=1", "--method", "GET", "--raw"] + (settings.scope.isEmpty ? [] : ["--scope", settings.scope])
        switch await NativeReadCommand.fetch(id == .buildWatch ? "gh" : "vercel", arguments: arguments) {
        case .success(let data):
            let fact = id == .buildWatch ? SourceProjection.github(data) : SourceProjection.vercel(data)
            guard let fact else { return NativePluginCard(id, state: .unavailable, detail: "No supported run found. Check the selected source.") }
            let now = Date()
            return NativePluginCard(id, payload: .work([fact]), state: .ready, detail: id == .buildWatch ? "GitHub CLI · read only" : "Vercel CLI · read only", observedAt: now, expiresAt: now.addingTimeInterval(300))
        case .failure(let error): return NativePluginCard(id, state: error == .missingClient ? .setupRequired : .unavailable, detail: error == .missingClient ? "Install the source CLI and sign in separately." : error == .timeout ? "Source timed out. Check the network and CLI availability." : "Source could not connect. Check the network, CLI login and project access.")
        }
    }
}
