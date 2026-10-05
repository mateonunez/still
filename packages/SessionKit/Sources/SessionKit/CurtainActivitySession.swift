@MainActor
public protocol CurtainActivityDriver: AnyObject {
    func declareActivity(previous: UInt32?) -> Result<UInt32, EnergyFailure>
    func releaseActivity(_ id: UInt32) -> Result<Void, EnergyFailure>
}

/// Renew a local activity declaration only during an active curtain.
/// OS display/idle behavior still requires physical endurance acceptance.
@MainActor
public final class CurtainActivitySession {
    private let driver: CurtainActivityDriver
    private let now: () -> Double
    private var nextRenewal: Double = 0
    public private(set) var owned: UInt32?
    public private(set) var requested = false
    public private(set) var failure: EnergyFailure?
    public init(driver: CurtainActivityDriver, now: @escaping () -> Double) { self.driver = driver; self.now = now }
    public func setCovered(_ covered: Bool) {
        if covered && !requested { nextRenewal = 0 }
        requested = covered; tick()
    }
    public func tick() {
        if requested {
            guard now() >= nextRenewal else { return }
            nextRenewal = now() + 15
            switch driver.declareActivity(previous: owned) {
            case .success(let id): owned = id; failure = nil
            case .failure(let error): failure = error
            }
        } else if let id = owned {
            switch driver.releaseActivity(id) {
            case .success: owned = nil; failure = nil; nextRenewal = 0
            case .failure(let error): failure = error
            }
        } else { failure = nil; nextRenewal = 0 }
    }
}
