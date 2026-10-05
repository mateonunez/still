import AppKit
import LocalAuthenticationEmbeddedUI
import SwiftUI

/// Readiness comes from actual attachment to a window, not a timer.
struct EmbeddedTouchID: NSViewRepresentable {
    let authenticationView: LAAuthenticationView
    let ready: @MainActor () -> Void

    func makeNSView(context: Context) -> AuthenticationContainer {
        AuthenticationContainer(authenticationView: authenticationView, ready: ready)
    }

    func updateNSView(_ nsView: AuthenticationContainer, context: Context) { nsView.checkReadiness() }

    @MainActor
    final class AuthenticationContainer: NSView {
        private let ready: @MainActor () -> Void
        private let authenticationView: LAAuthenticationView
        private var didNotify = false
        private var checking = false

        init(authenticationView: LAAuthenticationView, ready: @escaping @MainActor () -> Void) {
            self.ready = ready
            self.authenticationView = authenticationView
            super.init(frame: .zero)
            authenticationView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(authenticationView)
            NSLayoutConstraint.activate([
                authenticationView.widthAnchor.constraint(equalTo: widthAnchor),
                authenticationView.heightAnchor.constraint(equalTo: heightAnchor),
                authenticationView.centerXAnchor.constraint(equalTo: centerXAnchor),
                authenticationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }

        required init?(coder: NSCoder) { fatalError("Use init(authenticationView:ready:)") }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            checkReadiness()
        }

        func checkReadiness() {
            guard window != nil, !didNotify, !checking else { return }
            checking = true
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.checking = false
                guard !self.didNotify, let window = self.window, self.authenticationView.window === window else { return }
                self.didNotify = true
                self.ready()
            }
        }
    }
}
