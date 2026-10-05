import LocalAuthentication
import LocalAuthenticationEmbeddedUI

@MainActor
final class AuthenticationService {
    enum Outcome: Sendable {
        case authenticated
        case canceled
        case failed(String)
    }

    private var context: LAContext?
    private(set) var preparationError: Int?

    /// Attach this system-owned view before evaluating the policy.
    /// Embedded UI does not support password entry; that uses a fresh system dialog.
    func prepareTouchID() -> LAAuthenticationView? {
        invalidate()
        let context = freshContext()
        preparationError = nil
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
              context.biometryType == .touchID else { preparationError = error?.code; return nil }
        self.context = context
        return LAAuthenticationView(context: context, controlSize: .regular)
    }

    func evaluateTouchID(view: LAAuthenticationView,
                         completion: @escaping @MainActor @Sendable (Outcome) -> Void) {
        guard context === view.context else { return }
        evaluate(context: view.context, policy: .deviceOwnerAuthenticationWithBiometrics, completion: completion)
    }

    func evaluateSystem(completion: @escaping @MainActor @Sendable (Outcome) -> Void) {
        invalidate()
        let context = freshContext()
        self.context = context
        context.localizedFallbackTitle = "Use Mac password"
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(.failed("System authentication is unavailable. Use normal macOS recovery if needed."))
            return
        }
        evaluate(context: context, policy: .deviceOwnerAuthentication, completion: completion)
    }

    private func freshContext() -> LAContext {
        let context = LAContext()
        context.localizedCancelTitle = "Stay in Still"
        context.touchIDAuthenticationAllowableReuseDuration = 0
        return context
    }

    private func evaluate(context: LAContext, policy: LAPolicy,
                          completion: @escaping @MainActor @Sendable (Outcome) -> Void) {
        context.evaluatePolicy(policy, localizedReason: "Return to your desktop.") { success, error in
            let outcome: Outcome
            if success {
                outcome = .authenticated
            } else if let error = error as? LAError,
                      [.userCancel, .appCancel, .systemCancel].contains(error.code) {
                outcome = .canceled
            } else {
                outcome = .failed("Authentication did not complete. Try Touch ID again or use your Mac password.")
            }
            Task { @MainActor in completion(outcome) }
        }
    }

    func invalidate() {
        context?.invalidate()
        context = nil
    }
}
