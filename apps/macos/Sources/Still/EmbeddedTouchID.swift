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

    func updateNSView(_ nsView: AuthenticationContainer, context: Context) {}

    @MainActor
    final class AuthenticationContainer: NSView {
        private let ready: @MainActor () -> Void
        private var didNotify = false

        init(authenticationView: LAAuthenticationView, ready: @escaping @MainActor () -> Void) {
            self.ready = ready
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
            guard window != nil, !didNotify else { return }
            didNotify = true
            Task { @MainActor [weak self] in
                guard let self, self.window != nil else { return }
                self.ready()
            }
        }
    }
}
