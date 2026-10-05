import AppKit
import LocalAuthenticationEmbeddedUI
import SessionKit
import SwiftUI

@MainActor
private final class CurtainPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class CurtainCoordinator: NSObject, NSMenuDelegate {
    private var session = CurtainSession()
    private let presentation = CurtainPresentation()
    private let authentication = AuthenticationService()
    private var panels: [NSPanel] = []
    private var statusItem: NSStatusItem?
    private var welcomeWindow: NSWindow?
    private var preferencesWindow: NSWindow?
    private var widgetsWindow: NSWindow?
    private let widgets = WidgetCenter(persist: !ProcessInfo.processInfo.arguments.contains("--evidence-directory"))
    private let plugins = PluginCenter(persist: !ProcessInfo.processInfo.arguments.contains("--evidence-directory"))
    private let desktopPolicy = DesktopPresentationPolicy()
    private let interactionTrace = InteractionTrace()
    private var rebuildGate = CurtainRebuildGate()
    private let controls = SessionControls(persist: !ProcessInfo.processInfo.arguments.contains("--evidence-directory"))
    private var policyTimer: Timer?
    private var energyMenuItem: NSMenuItem?
    private var previousApplication: NSRunningApplication?
    private var sleeping = false
    private var userSessionActive = true

    override init() {
        super.init()
        if let saved = UserDefaults.standard.string(forKey: "StillAppearance"),
           let appearance = StillAppearance(rawValue: saved) {
            presentation.appearance = appearance
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(displaysChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(self, selector: #selector(willSleep), name: NSWorkspace.willSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(didWake), name: NSWorkspace.didWakeNotification, object: nil)
        workspace.addObserver(self, selector: #selector(sessionResigned), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        workspace.addObserver(self, selector: #selector(sessionBecameActive), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        workspace.addObserver(self, selector: #selector(interactionChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        for name in [NSApplication.didBecomeActiveNotification, NSApplication.didResignActiveNotification, NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(interactionChanged), name: name, object: nil)
        }
    }

    private func trace(_ phase: String) {
        let mode: String = switch presentation.authenticationMode { case .none: "none"; case .touchID: "touchID"; case .system: "system" }
        interactionTrace.record(phase, covered: session.isRequested, touchID: presentation.touchIDView != nil, preparationError: authentication.preparationError, authentication: mode, panelCount: panels.count, keyPanel: panels.contains { $0.isKeyWindow }, attached: presentation.touchIDView?.window != nil)
    }
    @objc private func interactionChanged(_ notification: Notification) {
        trace(notification.name.rawValue)
        if notification.name == NSApplication.didBecomeActiveNotification || notification.name == NSWindow.didBecomeKeyNotification {
            startAttachedTouchID()
        }
    }

    private func startAttachedTouchID() {
        guard presentation.authenticationMode == .none, let view = presentation.touchIDView else { return }
        touchIDViewReady(view)
    }

    func installMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = StillMark.menuImage(covered: false)
        item.button?.toolTip = "Still — ready when you are"
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        updateMenu(menu)
        item.menu = menu
        statusItem = item

        let mainMenu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        addItem("Quit Still", action: #selector(quit), key: "q", to: appMenu)
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)
        NSApp.mainMenu = mainMenu
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.policyTick() }
        }
        policyTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func menuNeedsUpdate(_ menu: NSMenu) { updateMenu(menu) }

    private func updateMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        let model = CurtainMenu(state: session.state, embeddedBiometrics: presentation.authenticationMode == .touchID)
        let status = NSMenuItem(title: model.status, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        let primary = addItem(model.actionTitle, action: #selector(primaryAction), to: menu)
        primary.isEnabled = model.actionEnabled && !sleeping && userSessionActive
        menu.addItem(.separator())
        energyMenuItem = nil
        if ProductFeatures.awakeControlsVisible {
            let energyItem = NSMenuItem(title: controls.running ? controls.energyStatus : "Keep Mac awake", action: nil, keyEquivalent: "")
            let energyChoices = NSMenu()
            energyChoices.autoenablesItems = false
            for minutes in SessionControls.durations {
                let choice = addItem("For \(minutes) minutes", action: #selector(startAwake(_:)), to: energyChoices)
                choice.representedObject = minutes
                choice.state = controls.running && controls.selectedDuration == minutes ? .on : .off
                choice.isEnabled = !sleeping && userSessionActive
            }
            energyChoices.addItem(.separator())
            let displayChoice = addItem("Keep displays on", action: #selector(toggleDisplayAwake), to: energyChoices)
            displayChoice.state = controls.keepDisplaysOn ? .on : .off
            if controls.running || controls.energyStatus == "Ending awake requests…" {
                energyChoices.addItem(.separator())
                addItem("Stop awake session", action: #selector(stopAwake), to: energyChoices)
            }
            energyItem.submenu = energyChoices
            energyMenuItem = energyItem
            menu.addItem(energyItem)
            if !controls.issue.isEmpty {
                let issue = NSMenuItem(title: controls.issue, action: nil, keyEquivalent: "")
                issue.isEnabled = false
                menu.addItem(issue)
            }
        }
        let idleItem = NSMenuItem(title: controls.idleMinutes == 0 ? "After inactivity: Never" : "After inactivity: \(controls.idleMinutes)m", action: nil, keyEquivalent: "")
        let idleChoices = NSMenu()
        idleChoices.autoenablesItems = false
        for minutes in SessionControls.idleOptions {
            let choice = addItem(minutes == 0 ? "Never" : "After \(minutes) \(minutes == 1 ? "minute" : "minutes")", action: #selector(changeIdle(_:)), to: idleChoices)
            choice.representedObject = minutes
            choice.state = controls.idleMinutes == minutes ? .on : .off
        }
        idleItem.submenu = idleChoices
        menu.addItem(idleItem)
        let preferences = addItem("Preferences…", action: #selector(showPreferences), key: ",", to: menu)
        preferences.isEnabled = !session.isRequested
        let customize = addItem("Customize…", action: #selector(showWidgets), to: menu)
        customize.isEnabled = !session.isRequested
        menu.addItem(.separator())
        let appearanceItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        let appearances = NSMenu()
        appearances.autoenablesItems = false
        for mode in StillAppearance.allCases {
            let choice = addItem(mode.title, action: #selector(changeAppearance(_:)), to: appearances)
            choice.representedObject = mode.rawValue
            choice.state = presentation.appearance == mode ? .on : .off
        }
        appearanceItem.submenu = appearances
        menu.addItem(appearanceItem)
        menu.addItem(.separator())
        let about = addItem("About Still", action: #selector(about), to: menu)
        about.isEnabled = !session.isRequested
        addItem("Quit Still", action: #selector(quit), key: "q", to: menu)
    }

    @discardableResult
    private func addItem(_ title: String, action: Selector, key: String = "", to menu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
        return item
    }

    private func policyTick() {
        trace("state")
        widgets.tick(available: !sleeping && userSessionActive)
        plugins.tick(available: !sleeping && userSessionActive)
        let template = plugins.template
        presentation.widgetCards = widgets.cards.filter { card in template == nil || template!.widgets.contains { $0.kind == .quota && $0.provider.rawValue == card.provider.rawValue } }
        let activity = widgets.activityCards.filter { card in template == nil || template!.widgets.contains { $0.kind == .agentActivity && card.id == $0.provider.rawValue + "-activity" } }
        presentation.extensionCards = Array((activity + plugins.cards).prefix(max(0, 4 - presentation.widgetCards.count)))
        if let template, widgets.layout != template.template.layout.rawValue { widgets.layout = template.template.layout.rawValue }
        presentation.widgetLayout = widgets.layout
        let activate = controls.tick(alreadyCovered: session.isRequested, sessionAvailable: !sleeping && userSessionActive)
        energyMenuItem?.title = controls.running ? controls.energyStatus : "Keep Mac awake"
        if activate { cover() }
        updateStatus()
    }

    @objc private func startAwake(_ item: NSMenuItem) {
        guard !sleeping, userSessionActive, let minutes = item.representedObject as? Int else { return }
        controls.start(minutes: minutes)
        updateStatus()
    }

    @objc private func stopAwake() { controls.stop(); updateStatus() }
    @objc private func toggleDisplayAwake() { controls.setKeepDisplaysOn(!controls.keepDisplaysOn); updateStatus() }
    @objc private func changeIdle(_ item: NSMenuItem) {
        guard let minutes = item.representedObject as? Int else { return }
        controls.setIdleMinutes(minutes)
    }

    @objc func showWidgets() {
        guard !session.isRequested else { return }
        if let widgetsWindow { NSApp.activate(ignoringOtherApps: true); widgetsWindow.makeKeyAndOrderFront(nil); return }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 590, height: 740), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.minSize = NSSize(width: 560, height: 600)
        window.title = "Customize Still"; window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false; window.isOpaque = false; window.backgroundColor = .clear
        window.contentView = NSHostingView(rootView: WidgetsHubView(widgets: widgets, plugins: plugins, presentation: presentation, titlebarInset: window.frame.height - window.contentLayoutRect.height)); window.center()
        widgetsWindow = window; NSApp.activate(ignoringOtherApps: true); window.makeKeyAndOrderFront(nil)
    }

    @objc private func showPreferences() {
        guard !session.isRequested else { return }
        if let preferencesWindow {
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindow.makeKeyAndOrderFront(nil)
            return
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 520, height: 420),
                              styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = "Still Preferences"
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        let content = NSHostingView(rootView: PreferencesView(controls: controls, titlebarInset: window.frame.height - window.contentLayoutRect.height))
        window.contentView = content
        window.setContentSize(content.fittingSize)
        window.center()
        preferencesWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func primaryAction() {
        if session.isRequested { useSystemAuthentication() } else { cover() }
    }

    func showWelcomeIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "StillWelcomeSeenV1") else { return }
        showWelcome()
        UserDefaults.standard.set(true, forKey: "StillWelcomeSeenV1")
    }

    func showWelcome() {
        guard !session.isRequested else { return }
        rememberPreviousApplication()
        if let welcomeWindow {
            NSApp.activate(ignoringOtherApps: true)
            welcomeWindow.makeKeyAndOrderFront(nil)
            return
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 460, height: 440),
                              styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Welcome to Still"
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: WelcomeView { [weak self] in self?.cover() })
        window.center()
        welcomeWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func rememberPreviousApplication() {
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            previousApplication = frontmost
        }
    }

    @objc func cover() {
        guard !sleeping, userSessionActive, session.cover() else { return }
        controls.setCovered(true)
        rememberPreviousApplication()
        welcomeWindow?.close()
        preferencesWindow?.close()
        widgetsWindow?.close()
        presentation.message = ""
        rebuildPanels()
        trace("cover")
    }

    private func touchIDViewReady(_ view: LAAuthenticationView) {
        trace("touchIDViewReady")
        guard session.isRequested, NSApp.isActive, let window = view.window,
              panels.contains(where: { $0 === window && $0.isKeyWindow }),
              presentation.touchIDView === view, presentation.authenticationMode == .none,
              let attempt = session.beginAuthentication() else { return }
        presentation.authenticationMode = .touchID
        trace("touchIDEvaluation")
        presentation.message = "Place your finger on Touch ID to return."
        updateStatus()
        authentication.evaluateTouchID(view: view) { [weak self] outcome in
            self?.completeAuthentication(attempt: attempt, outcome: outcome)
        }
    }

    private func returnToDesktop() {
        guard session.isRequested, presentation.authenticationMode != .system else { return }
        if presentation.authenticationMode == .touchID {
            useSystemAuthentication()
            return
        }
        if let view = authentication.prepareTouchID() {
            session.invalidateAuthentication()
            presentation.authenticationMode = .none
            presentation.touchIDView = view
            // The view-attachment callback starts evaluation on the active display.
            presentation.message = "Touch ID is getting ready."
        } else {
            useSystemAuthentication()
        }
    }

    @objc private func useSystemAuthentication() {
        guard session.isRequested, presentation.authenticationMode != .system else { return }
        session.invalidateAuthentication()
        authentication.invalidate()
        presentation.touchIDView = nil
        guard let attempt = session.beginAuthentication() else { return }
        presentation.authenticationMode = .system
        trace("systemAuthentication")
        presentation.message = "Choose Use Mac password in the macOS dialog."
        desktopPolicy.restore()
        panels.forEach { $0.level = .normal }
        updateStatus()
        NSApp.activate(ignoringOtherApps: true)
        authentication.evaluateSystem { [weak self] outcome in
            self?.completeAuthentication(attempt: attempt, outcome: outcome)
        }
    }

    private func completeAuthentication(attempt: UUID, outcome: AuthenticationService.Outcome) {
        let result: CurtainSession.AuthenticationOutcome
        switch outcome {
        case .authenticated: result = .authenticated
        case .canceled: result = .canceled
        case .failed: result = .failed
        }
        guard session.completeAuthentication(attempt: attempt, outcome: result) else { return }
        trace(result == .authenticated ? "authenticated" : result == .canceled ? "authenticationCanceled" : "authenticationFailed")
        authentication.invalidate()
        presentation.touchIDView = nil
        presentation.authenticationMode = .none
        if result == .authenticated {
            controls.setCovered(false)
            controls.resetIdleInterval()
            closePanels()
            previousApplication?.activate(options: [])
            previousApplication = nil
        } else {
            switch outcome {
            case .canceled: presentation.message = "Still is here. Try again whenever you are ready."
            case .failed(let message): presentation.message = message
            case .authenticated: break
            }
            panels.forEach { $0.level = .screenSaver; $0.orderFrontRegardless() }
            panels.first?.makeKeyAndOrderFront(nil)
            desktopPolicy.cover()
            announce(presentation.message)
        }
        updateStatus()
    }

    private func cancelAuthentication() {
        guard presentation.authenticating else { return }
        session.invalidateAuthentication()
        authentication.invalidate()
        presentation.touchIDView = nil
        presentation.authenticationMode = .none
        presentation.message = "Still is here. Try again whenever you are ready."
        panels.forEach { $0.level = .screenSaver; $0.orderFrontRegardless() }
        desktopPolicy.cover()
        updateStatus()
        announce(presentation.message)
    }

    private func updateStatus() {
        presentation.energyWarning = controls.curtainAwakeIssue.isEmpty ? "" : "Mac may sleep. " + controls.curtainAwakeIssue
        statusItem?.button?.image = StillMark.menuImage(covered: session.isRequested)
        statusItem?.button?.toolTip = "Still — " + (session.isRequested ? "your desktop is covered" : "ready when you are") + (session.isRequested && controls.curtainAwakeID != nil ? " · Mac stays awake" : "")
    }

    private func rebuildPanels(force: Bool = true) {
        guard rebuildGate.begin(CurtainDisplay.current(), force: force) else { trace("topologyUnchangedOrBuilding"); return }
        defer {
            rebuildGate.finish()
            // A physical change during construction is reconciled once the build is complete.
            Task { @MainActor [weak self] in self?.displaysChanged() }
        }
        session.invalidateAuthentication()
        closePanels(restoringPresentation: false)
        presentation.authenticationMode = .none
        let isProbe = ProcessInfo.processInfo.arguments.contains("--evidence-directory")
        presentation.touchIDView = isProbe ? nil : authentication.prepareTouchID()
        trace("touchIDPreparation")
        let screens = NSScreen.screens
        let cursor = NSEvent.mouseLocation
        let activeScreen = screens.first(where: { $0.frame.contains(cursor) }) ?? screens.first
        for screen in screens {
            let panel = CurtainPanel(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
            panel.title = "Still — Porcelain"
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle, .canJoinAllApplications]
            panel.isOpaque = true
            panel.backgroundColor = .windowBackgroundColor
            panel.hasShadow = false
            panel.isReleasedWhenClosed = false
            panel.hidesOnDeactivate = false
            panel.isFloatingPanel = false
            panel.isMovable = false
            panel.level = .screenSaver
            panel.animationBehavior = .none
            let view = CurtainView(
                presentation: presentation,
                authenticate: { [weak self] in self?.returnToDesktop() },
                useSystemAuthentication: { [weak self] in self?.useSystemAuthentication() },
                cancelAuthentication: { [weak self] in self?.cancelAuthentication() },
                touchIDReady: { [weak self] view in self?.touchIDViewReady(view) },
                isAuthenticationDisplay: screen === activeScreen
            )
            panel.contentView = NSHostingView(rootView: view)
            panels.append(panel)
            panel.orderFrontRegardless()
        }
        NSApp.activate(ignoringOtherApps: true)
        let active = panels.first(where: { $0.frame.contains(cursor) }) ?? panels.first
        active?.makeKeyAndOrderFront(nil)
        if active != nil { desktopPolicy.cover() }
        updateStatus()
        trace("panelsReady")
        NativeEvidence.exportIfRequested(panels: panels, awakeID: controls.curtainAwakeID)
    }

    private func closePanels(restoringPresentation: Bool = true) {
        if restoringPresentation { desktopPolicy.restore(); rebuildGate.reset() }
        panels.forEach { $0.orderOut(nil); $0.close() }
        panels.removeAll()
    }

    @objc private func displaysChanged() {
        guard session.isRequested, !sleeping, userSessionActive else { return }
        trace("screenParametersChanged")
        rebuildPanels(force: false)
    }

    private func suspend() {
        plugins.tick(available: false)
        widgets.tick(available: false)
        session.suspend()
        controls.setCovered(false)
        controls.stop()
        authentication.invalidate()
        presentation.touchIDView = nil
        presentation.authenticationMode = .none
        closePanels()
        updateStatus()
    }

    private func resumeIfPossible() {
        guard !sleeping, userSessionActive else { return }
        session.resume()
        controls.resetIdleInterval()
        guard session.isRequested else { return }
        controls.setCovered(true)
        presentation.message = "Welcome back. Authenticate to return to your desktop."
        rebuildPanels()
    }

    @objc private func willSleep() { sleeping = true; suspend() }
    @objc private func didWake() { sleeping = false; resumeIfPossible() }
    @objc private func sessionResigned() { userSessionActive = false; suspend() }
    @objc private func sessionBecameActive() { userSessionActive = true; resumeIfPossible() }

    @objc private func changeAppearance(_ item: NSMenuItem) {
        guard let value = item.representedObject as? String, let mode = StillAppearance(rawValue: value) else { return }
        presentation.appearance = mode
        UserDefaults.standard.set(value, forKey: "StillAppearance")
        item.menu?.items.forEach { $0.state = $0 === item ? .on : .off }
    }

    @objc private func about() {
        let alert = NSAlert()
        alert.messageText = "Still"
        alert.informativeText = "A calm screen for your Mac.\n\nVersion 0.1.0 · Local development preview\n\nVisual privacy with system authentication and optional inactivity activation. Still does not replace the macOS security lock.\n\nInstrument Serif · SIL Open Font License."
        alert.addButton(withTitle: "Done")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    private func announce(_ message: String) {
        guard let view = panels.first?.contentView else { return }
        NSAccessibility.post(element: view, notification: .announcementRequested, userInfo: [
            .announcement: message, .priority: NSAccessibilityPriorityLevel.high.rawValue,
        ])
    }

    @objc private func quit() { NSApp.terminate(nil) }

    func tearDown() {
        desktopPolicy.restore()
        plugins.tick(available: false)
        widgets.stop()
        session.stop()
        policyTimer?.invalidate()
        policyTimer = nil
        controls.setCovered(false)
        controls.stop()
        authentication.invalidate()
        presentation.touchIDView = nil
        closePanels()
        welcomeWindow?.close()
        preferencesWindow?.close()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        if let statusItem { NSStatusBar.system.removeStatusItem(statusItem) }
    }
}
