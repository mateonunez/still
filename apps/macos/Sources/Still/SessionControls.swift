import CoreGraphics
import Foundation
import SessionKit

@MainActor
final class SessionControls: ObservableObject {
    @Published private(set) var idleMinutes = 0
    @Published private(set) var keepDisplaysOn = false
    @Published var selectedDuration = 30
    @Published private(set) var running = false
    @Published private(set) var energyStatus = "Normal sleep behavior"
    @Published private(set) var issue = ""
    @Published private(set) var idleIssue = ""

    static let idleOptions = [0, 1, 3, 5, 10, 15, 30]
    static let durations = [15, 30, 60, 120]
    private let clock = SessionClock()
    private let driver = IOKitAssertionDriver()
    private lazy var energy = EnergySession(driver: driver, now: { [weak self] in self?.clock.now ?? 0 })
    private lazy var curtainAwake = CurtainAwakeSession(driver: driver)
    private lazy var curtainActivity = CurtainActivitySession(driver: driver, now: { [weak self] in self?.clock.now ?? 0 })
    var curtainAwakeID: UInt32? { curtainAwake.owned }
    var curtainAwakeIssue: String { curtainAwake.failure?.message ?? curtainActivity.failure?.message ?? "" }
    private var idle = IdlePolicy()
    private let persist: Bool
    private var platformIssue = ""

    init(persist: Bool = true) {
        self.persist = persist
        if persist {
            let saved = UserDefaults.standard.integer(forKey: "StillIdleMinutes")
            idleMinutes = Self.idleOptions.contains(saved) ? saved : 0
            keepDisplaysOn = UserDefaults.standard.bool(forKey: "StillKeepDisplaysOn")
        }
        idle.configure(threshold: idleMinutes == 0 ? nil : Double(idleMinutes * 60), now: clock.now)
        energy.setKeepDisplaysOn(keepDisplaysOn)
    }

    func setIdleMinutes(_ minutes: Int) {
        guard Self.idleOptions.contains(minutes) else { return }
        idleMinutes = minutes
        idle.configure(threshold: minutes == 0 ? nil : Double(minutes * 60), now: clock.now)
        if persist { UserDefaults.standard.set(minutes, forKey: "StillIdleMinutes") }
    }

    func setKeepDisplaysOn(_ enabled: Bool) {
        keepDisplaysOn = enabled
        energy.setKeepDisplaysOn(enabled)
        if persist { UserDefaults.standard.set(enabled, forKey: "StillKeepDisplaysOn") }
        refresh()
    }

    func start(minutes: Int) {
        guard Self.durations.contains(minutes) else { return }
        selectedDuration = minutes
        platformIssue = ""
        energy.start(seconds: Double(minutes * 60))
        refresh()
    }

    func stop() { platformIssue = ""; energy.stop(); refresh() }
    func setCovered(_ covered: Bool) { curtainAwake.setCovered(covered); curtainActivity.setCovered(covered) }
    func resetIdleInterval() { idle.resetAfterReturn(now: clock.now) }

    func tick(alreadyCovered: Bool, sessionAvailable: Bool) -> Bool {
        if let id = curtainAwake.owned, !driver.isActive(id) { curtainAwake.assertionEnded() }
        curtainAwake.tick()
        curtainActivity.tick()
        energy.tick()
        if energy.isRunning, energy.owned.values.contains(where: { !driver.isActive($0) }) {
            energy.stop()
            platformIssue = "macOS ended an awake request. Start a new session when ready."
        }
        refresh()
        guard idleMinutes > 0 else { idleIssue = ""; return false }
        guard let anyInput = CGEventType(rawValue: UInt32.max) else { idleIssue = "Inactivity signal unavailable"; return false }
        let age = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyInput)
        guard age.isFinite, age >= 0 else { idleIssue = "Inactivity signal unavailable"; return false }
        idleIssue = ""
        return idle.shouldActivate(inputAge: age, now: clock.now, alreadyCovered: alreadyCovered, sessionAvailable: sessionAvailable)
    }

    private func refresh() {
        running = energy.isRunning
        issue = energy.failure?.message ?? platformIssue
        if running {
            let minutes = max(1, Int(ceil(energy.remaining / 60)))
            energyStatus = "Awake session · \(minutes)m left"
            if energy.owned[.display] != nil { energyStatus += " · displays on" }
        } else if !energy.owned.isEmpty {
            energyStatus = "Ending awake requests…"
        } else {
            energyStatus = "Normal sleep behavior"
        }
    }
}
