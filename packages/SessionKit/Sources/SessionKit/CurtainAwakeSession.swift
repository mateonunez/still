/// One system-idle-sleep assertion for the lifetime of an active curtain.
/// Display sleep and explicit system sleep remain under macOS control.
@MainActor
public final class CurtainAwakeSession {
    private let driver: AwakeAssertionDriver
    public private(set) var requested = false
    public private(set) var owned: UInt32?
    public private(set) var failure: EnergyFailure?

    public init(driver: AwakeAssertionDriver) { self.driver = driver }

    public func setCovered(_ covered: Bool) {
        requested = covered
        tick()
    }

    /// Retry failed acquisition/cleanup without stacking assertions.
    public func tick() {
        if requested {
            guard owned == nil else { failure = nil; return }
            switch driver.acquire(.system, timeout: 0) {
            case .success(let id): owned = id; failure = nil
            case .failure(let error): failure = error
            }
        } else if let id = owned {
            switch driver.release(id) {
            case .success: owned = nil; failure = nil
            case .failure(let error): failure = error
            }
        } else {
            failure = nil
        }
    }

    /// The driver has confirmed that macOS no longer holds this exact ID.
    public func assertionEnded() {
        owned = nil
        tick()
    }
}
