public enum AwakeAssertion: String, CaseIterable, Sendable {
    case system, display
}

public struct EnergyFailure: Error, Equatable, Sendable {
    public let code: String
    public let message: String
    public init(code: String, message: String) { self.code = code; self.message = message }
}

@MainActor
public protocol AwakeAssertionDriver: AnyObject {
    func acquire(_ kind: AwakeAssertion, timeout: Double) -> Result<UInt32, EnergyFailure>
    func release(_ id: UInt32) -> Result<Void, EnergyFailure>
}

/// Owns only its driver's assertion IDs; intent is separate from acquired resources.
@MainActor
public final class EnergySession {
    private let driver: any AwakeAssertionDriver
    private let now: () -> Double
    public private(set) var owned: [AwakeAssertion: UInt32] = [:]
    public private(set) var deadline: Double?
    public private(set) var keepDisplaysOn = false
    public private(set) var failure: EnergyFailure?

    public init(driver: any AwakeAssertionDriver, now: @escaping () -> Double) {
        self.driver = driver
        self.now = now
    }

    public var remaining: Double { max(0, (deadline ?? now()) - now()) }
    public var isRunning: Bool { deadline != nil && owned[.system] != nil }

    @discardableResult
    public func start(seconds: Double) -> Result<Void, EnergyFailure> {
        guard seconds.isFinite, seconds > 0, seconds <= 86_400 else {
            return fail(EnergyFailure(code: "INVALID_DURATION", message: "Choose a finite awake duration."))
        }
        stop()
        guard owned.isEmpty else {
            return fail(EnergyFailure(code: "CLEANUP_PENDING", message: "A previous awake request is still ending."))
        }
        failure = nil
        switch driver.acquire(.system, timeout: seconds + 2) {
        case .failure(let error): return fail(error)
        case .success(let id): owned[.system] = id
        }
        if keepDisplaysOn {
            switch driver.acquire(.display, timeout: seconds + 2) {
            case .failure(let error):
                stop()
                return fail(failure ?? error)
            case .success(let id): owned[.display] = id
            }
        }
        deadline = now() + seconds
        return .success(())
    }

    @discardableResult
    public func setKeepDisplaysOn(_ enabled: Bool) -> Result<Void, EnergyFailure> {
        keepDisplaysOn = enabled
        guard deadline != nil else { return .success(()) }
        if remaining <= 0 { stop(); return .success(()) }
        failure = nil
        if enabled, owned[.display] == nil {
            switch driver.acquire(.display, timeout: remaining + 2) {
            case .failure(let error): return fail(error)
            case .success(let id): owned[.display] = id
            }
        } else if !enabled, let id = owned[.display] {
            switch driver.release(id) {
            case .success: owned.removeValue(forKey: .display)
            case .failure(let error): return fail(error)
            }
        }
        return .success(())
    }

    public func tick() {
        if deadline == nil {
            if !owned.isEmpty { stop() }
        } else if remaining <= 0 {
            stop()
        } else if !keepDisplaysOn, let id = owned[.display] {
            if case .success = driver.release(id) { owned.removeValue(forKey: .display); failure = nil }
        }
    }

    /// Failed releases remain owned and are retried; never claim they are gone.
    public func stop() {
        deadline = nil
        failure = nil
        for kind in [AwakeAssertion.display, .system] {
            guard let id = owned[kind] else { continue }
            switch driver.release(id) {
            case .success: owned.removeValue(forKey: kind)
            case .failure(let error): failure = error
            }
        }
    }

    private func fail(_ error: EnergyFailure) -> Result<Void, EnergyFailure> {
        failure = error
        return .failure(error)
    }
}
