import Foundation
import IOKit.pwr_mgt
import SessionKit

@MainActor
final class IOKitAssertionDriver: AwakeAssertionDriver {
    func acquire(_ kind: AwakeAssertion, timeout: Double) -> Result<UInt32, EnergyFailure> {
        let type = kind == .system ? kIOPMAssertionTypePreventUserIdleSystemSleep : kIOPMAssertionTypePreventUserIdleDisplaySleep
        var identifier: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithDescription(
            type as CFString,
            (timeout == 0 ? "Still — curtain awake session" : "Still — timed \(kind.rawValue) awake session") as CFString,
            nil,
            (timeout == 0 ? "Keep the Mac awake while Still covers the desktop." : "An explicitly started, finite Still awake session.") as CFString,
            nil, timeout, kIOPMAssertionTimeoutActionRelease as CFString, &identifier
        )
        guard result == kIOReturnSuccess else {
            return .failure(EnergyFailure(code: "ASSERTION_CREATE_\(result)", message: "macOS could not start the \(kind.rawValue) awake request."))
        }
        return .success(identifier)
    }

    func properties(_ id: UInt32) -> [String: Any]? {
        guard let properties = IOPMAssertionCopyProperties(id)?.takeRetainedValue() else { return nil }
        return properties as NSDictionary as? [String: Any]
    }

    func isActive(_ id: UInt32) -> Bool {
        guard let level = (properties(id)?[kIOPMAssertionLevelKey] as? NSNumber)?.uint32Value else { return false }
        return level == kIOPMAssertionLevelOn
    }

    func release(_ id: UInt32) -> Result<Void, EnergyFailure> {
        // The OS timeout may have released this exact owned ID while the app was delayed.
        let result = IOPMAssertionRelease(id)
        if (result == kIOReturnBadArgument || result == kIOReturnNotFound), properties(id) == nil { return .success(()) }
        guard result == kIOReturnSuccess else {
            return .failure(EnergyFailure(code: "ASSERTION_RELEASE_\(result)", message: "An awake request is still ending. Still will retry."))
        }
        return .success(())
    }
}

struct SessionClock {
    private let clock = ContinuousClock()
    private let origin = ContinuousClock().now
    var now: Double {
        let parts = origin.duration(to: clock.now).components
        return Double(parts.seconds) + Double(parts.attoseconds) / 1e18
    }
}
