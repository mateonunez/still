import Foundation

/// The app's presentation state, never the security state of macOS.
public struct CurtainSession: Sendable {
    public enum State: Equatable, Sendable {
        case inactive
        case covered(UUID)
        case authenticating(session: UUID, attempt: UUID)
        case suspended(UUID)
    }

    public enum AuthenticationOutcome: Equatable, Sendable {
        case authenticated
        case canceled
        case failed
    }

    public private(set) var state: State = .inactive

    public init() {}

    public var isRequested: Bool { state != .inactive }

    @discardableResult
    public mutating func cover() -> Bool {
        guard state == .inactive else { return false }
        state = .covered(UUID())
        return true
    }

    /// One attempt is shared by every display in the current session.
    public mutating func beginAuthentication() -> UUID? {
        guard case .covered(let session) = state else { return nil }
        let attempt = UUID()
        state = .authenticating(session: session, attempt: attempt)
        return attempt
    }

    /// Returns false for callbacks that no longer belong to the active attempt.
    @discardableResult
    public mutating func completeAuthentication(
        attempt: UUID, outcome: AuthenticationOutcome
    ) -> Bool {
        guard case .authenticating(let session, let current) = state,
              current == attempt else { return false }
        state = outcome == .authenticated ? .inactive : .covered(session)
        return true
    }

    public mutating func invalidateAuthentication() {
        guard case .authenticating(let session, _) = state else { return }
        state = .covered(session)
    }

    /// Sleep and user-session changes invalidate authorization in flight.
    public mutating func suspend() {
        guard isRequested else { return }
        state = .suspended(UUID())
    }

    public mutating func resume() {
        guard case .suspended = state else { return }
        state = .covered(UUID())
    }

    /// Ordinary app termination is always available; this is not an OS lock.
    public mutating func stop() { state = .inactive }
}
