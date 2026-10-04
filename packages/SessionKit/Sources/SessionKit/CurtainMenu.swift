/// A single useful menu action derived from the current session.
public struct CurtainMenu: Equatable, Sendable {
    public let status: String
    public let actionTitle: String
    public let actionEnabled: Bool

    public init(state: CurtainSession.State, embeddedBiometrics: Bool = false) {
        switch state {
        case .inactive:
            status = "Ready when you are"
            actionTitle = "Show Still"
            actionEnabled = true
        case .covered:
            status = "Your desktop is covered"
            actionTitle = "Return to desktop…"
            actionEnabled = true
        case .authenticating:
            status = embeddedBiometrics ? "Touch ID is ready" : "Waiting for macOS…"
            actionTitle = embeddedBiometrics ? "Other unlock options…" : "Authentication in progress…"
            actionEnabled = embeddedBiometrics
        case .suspended:
            status = "Waiting for your Mac"
            actionTitle = "Return after waking your Mac"
            actionEnabled = false
        }
    }
}
