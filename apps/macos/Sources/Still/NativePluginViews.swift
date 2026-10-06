import AppKit
import StillNativePlugins
import SwiftUI

struct NativePluginCardView: View {
    let card: NativePluginCard
    let palette: PorcelainPalette
    var width: CGFloat = 280
    var showDetails = true
    var taskLimit = 4
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: card.plugin.symbol).foregroundStyle(palette.accent).accessibilityHidden(true)
                Text(card.plugin.title).font(.system(size: 13, weight: .semibold)); Spacer()
                if card.state == .refreshing { ProgressView().controlSize(.mini) }
            }
            if let payload = card.payload { payloadView(payload) }
            else { Text(stateTitle).font(.custom("InstrumentSerif-Regular", size: 24)) }
            if showDetails || card.payload == nil { Text(card.detail).font(.system(size: 10)).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true) }
            if showDetails, let observed = card.observedAt, ![.worldClock, .quietTimer, .agents].contains(card.plugin) { Text("Observed \(observed.formatted(.relative(presentation: .numeric)))").font(.system(size: 9)).foregroundStyle(palette.secondary) }
        }.padding(16).frame(width: width, alignment: .leading).foregroundStyle(palette.primary)
            .background { StillCardSurface(palette: palette) }.help(card.detail).accessibilityElement(children: .combine)
    }
    private var stateTitle: String { switch card.state { case .ready: "Ready"; case .refreshing: "Connecting…"; case .unavailable: "Unavailable"; case .permissionRequired: "Permission needed"; case .setupRequired: "Choose a source"; case .paused: "Paused" } }
    @ViewBuilder private func payloadView(_ payload: NativePayload) -> some View {
        switch payload {
        case .metrics(let metrics), .agents(let metrics):
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in VStack(alignment: .leading, spacing: 4) { Text(metric.label).font(.system(size: 10)).foregroundStyle(palette.secondary); Text(metric.value).font(.system(size: 13, weight: .medium)).fixedSize(horizontal: false, vertical: true) } }
        case .work(let tasks):
            if tasks.isEmpty { Text("No tasks registered").font(.system(size: 13)) }
            ForEach(Array(tasks.prefix(taskLimit).enumerated()), id: \.offset) { _, task in
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.label).font(.system(size: 11)).foregroundStyle(palette.secondary).lineLimit(2)
                    Text(task.state.rawValue.capitalized).font(.custom("InstrumentSerif-Regular", size: 26))
                    if let progress = task.progress { ProgressView(value: progress, total: 100).tint(palette.accent).accessibilityLabel(task.label).accessibilityValue("\(Int(progress)) percent") }
                    if let start = task.startedAt { Text("Started \(start.formatted(.relative(presentation: .numeric)))").font(.system(size: 10)).foregroundStyle(palette.secondary) }
                }
            }
            if tasks.count > taskLimit { Text("+\(tasks.count - taskLimit) other tasks").font(.system(size: 10)).foregroundStyle(palette.secondary) }
        case .agenda(let event):
            if let event { Text(event.title).font(.system(size: 13, weight: .medium)); Text(event.startsAt, style: .relative).font(.custom("InstrumentSerif-Regular", size: 28)); Text(event.startsAt.formatted(date: .omitted, time: .shortened)).font(.system(size: 11)).foregroundStyle(palette.secondary) }
            else { Text("A clear day ahead.").font(.custom("InstrumentSerif-Regular", size: 26)) }
        case .clocks(let clocks):
            TimelineView(.periodic(from: .now, by: 30)) { timeline in
                VStack(spacing: 10) {
                    ForEach(Array(clocks.enumerated()), id: \.offset) { _, clock in
                        HStack { Text(clock.name).font(.system(size: 11)); Spacer(); Text(clockTime(timeline.date, zone: clock.timeZone)).font(.custom("InstrumentSerif-Regular", size: 26)).monospacedDigit() }
                    }
                }
            }
        case .timer(let deadline):
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                let seconds = deadline.map { max(0, Int(ceil($0 - ProcessInfo.processInfo.systemUptime))) }
                Text(seconds.map { $0 == 0 ? "Take your time." : String(format: "%02d:%02d", $0 / 60, $0 % 60) } ?? "Ready when you are.").font(.custom("InstrumentSerif-Regular", size: 30)).monospacedDigit()
            }
        case .weather(let weather):
            HStack(alignment: .firstTextBaseline) { Text("\(Int(weather.temperature.rounded()))°").font(.custom("InstrumentSerif-Regular", size: 42)); Text(weather.city).font(.system(size: 12)).foregroundStyle(palette.secondary) }
            Text(weather.condition).font(.system(size: 13))
            if let chance = weather.rainChance { Text("\(Int(chance))% chance of rain next hour").font(.system(size: 11)).foregroundStyle(palette.secondary) }
        case .playback(let song):
            Text(song.title).font(.custom("InstrumentSerif-Regular", size: 26)).lineLimit(2)
            Text(song.artist).font(.system(size: 12)).foregroundStyle(palette.secondary).lineLimit(2)
            Label(song.playing ? "Playing" : "Paused", systemImage: song.playing ? "waveform" : "pause.fill").font(.system(size: 10))
        }
    }
    private func clockTime(_ date: Date, zone: String) -> String { let formatter = DateFormatter(); formatter.timeStyle = .short; formatter.timeZone = TimeZone(identifier: zone); return formatter.string(from: date) }
}

struct NativePluginLibraryView: View {
    @ObservedObject var center: NativePluginCenter
    let palette: PorcelainPalette
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { VStack(alignment: .leading, spacing: 5) { Text("Made for Still.").font(.custom("InstrumentSerif-Regular", size: 28)); Text("mateonunez · Native collection · v0.1.0").font(.system(size: 11)).foregroundStyle(palette.secondary) }; Spacer(); Button("Discover sources") { center.discover() }.stillControl() }
            Text("Connect any plugin. Choose what to show and arrange it across your screen.").font(.system(size: 12)).foregroundStyle(palette.secondary)
            if !center.visibleIDs.isEmpty {
                DisclosureGroup("Screen order") {
                    Text("Drag to reorder, or arrange modules in Edit screen.").font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.vertical, 8)
                    ForEach(center.visibleIDs) { id in
                        HStack(spacing: 12) {
                            Image(systemName: "line.3.horizontal").foregroundStyle(palette.secondary).padding(6).draggable(id.rawValue).accessibilityLabel("Drag \(id.title) to reorder")
                            Text(id.title).font(.system(size: 12)); Spacer()
                            Button { center.move(id, by: -1) } label: { Image(systemName: "arrow.up") }.accessibilityLabel("Move \(id.title) up").disabled(center.visibleIDs.first == id)
                            Button { center.move(id, by: 1) } label: { Image(systemName: "arrow.down") }.accessibilityLabel("Move \(id.title) down").disabled(center.visibleIDs.last == id)
                        }.padding(10).background(palette.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                            .dropDestination(for: String.self) { items, _ in
                                guard items.count == 1, let dragged = NativePluginID(rawValue: items[0]), center.visibleIDs.contains(dragged) else { return false }
                                center.move(dragged, before: id); return true
                            }
                    }
                }.padding(.vertical, 8)
            }
            if center.installed.isEmpty { Text("The native collection could not be prepared. Check local file access, then relaunch Still.").font(.system(size: 13)) }
            ForEach(center.installed) { id in
                VStack(alignment: .leading, spacing: 14) {
                    HStack { Image(systemName: id.symbol).foregroundStyle(palette.accent).accessibilityHidden(true); Text(id.title).font(.system(size: 16, weight: .semibold)); Spacer(); Toggle("Enabled", isOn: Binding(get: { center.configurations[id]?.enabled == true }, set: { center.setEnabled(id, $0) })).toggleStyle(.switch).controlSize(.small).accessibilityLabel("Enable \(id.title)") }
                    Text(id.summary).font(.system(size: 12)).foregroundStyle(palette.secondary)
                    Toggle("Show on curtain", isOn: Binding(get: { center.configurations[id]?.visible == true }, set: { center.setVisible(id, $0) })).disabled(center.configurations[id]?.enabled != true)
                    DisclosureGroup("Configure \(id.title)") {
                        NativePluginSettingsView(id: id, center: center).padding(.top, 12)
                        if let card = center.cards[id] { NativePluginCardView(card: card.current(now: Date()), palette: palette).padding(.top, 12) }
                    }
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(palette.surface.opacity(0.65), in: RoundedRectangle(cornerRadius: 18))
            }
            if !center.issue.isEmpty { Text(center.issue).font(.system(size: 12)).foregroundStyle(palette.secondary).accessibilityLabel("Plugin status: \(center.issue)") }
        }
    }
}

struct NativePluginSettingsView: View {
    let id: NativePluginID
    @ObservedObject var center: NativePluginCenter
    @State private var settings: NativePluginSettings
    init(id: NativePluginID, center: NativePluginCenter) { self.id = id; self.center = center; _settings = State(initialValue: center.configurations[id]?.settings ?? NativePluginSettings()) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            fields
            if id != .agents { Button("Save settings") { center.update(id, settings: settings) }.stillControl(prominent: true) }
            Button("Refresh \(id.title)") { center.refresh(id) }.stillControl()
        }.font(.system(size: 12))
            .onChange(of: center.configurations[id]?.settings.spotifyAuthorized) { _, value in settings.spotifyAuthorized = value ?? false }
    }
    @ViewBuilder private var fields: some View {
        switch id {
        case .agents:
            Text("Configure each discovered client in the Agents tab. Quota and activity are separate source choices; both appear in one Agents widget.")
            ForEach(center.discovered) { source in Label("\(source.provider.title) · \(source.executable == nil ? "not installed" : "installed")", systemImage: source.executable == nil ? "minus.circle" : "checkmark.circle") }
        case .buildWatch:
            TextField("GitHub repository (owner/name)", text: $settings.repository).textFieldStyle(.roundedBorder)
            Text("Uses the installed gh CLI and its current login. Only workflow status is requested.")
        case .deployWatch:
            TextField("Vercel project ID", text: $settings.projectID).textFieldStyle(.roundedBorder)
            TextField("Vercel team ID", text: $settings.teamID).textFieldStyle(.roundedBorder)
            TextField("Personal scope", text: $settings.scope).textFieldStyle(.roundedBorder)
            Text("Uses the installed Vercel CLI login. No token is copied into Still.")
        case .taskWatch:
            Toggle("Show completed tasks briefly", isOn: $settings.showCompletedTasks)
            Text("Register commands using still-task run --label Build -- pnpm build. Only the label and status are shared; stdout/stderr are not read by Still.")
            Button("Show task inbox") { NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: center.taskInbox.path) }.stillControl()
        case .macPulse:
            Toggle("Show CPU activity", isOn: $settings.showCPU)
            Toggle("Show memory pressure", isOn: $settings.showMemory)
            Toggle("Show battery and power", isOn: $settings.showBattery)
            Text("Native read-only system metrics. No process names, window titles or input are collected.")
        case .nextUp:
            Button("Allow calendar access…") { center.requestCalendar() }.stillControl()
            Picker("Calendar", selection: $settings.calendarID) { Text("Choose a calendar").tag(""); ForEach(center.calendarChoices, id: \.calendarIdentifier) { Text($0.title).tag($0.calendarIdentifier) } }
            Toggle("Show event titles", isOn: $settings.showTitles)
        case .worldClock:
            ForEach(settings.clocks.indices, id: \.self) { index in HStack { TextField("City \(index + 1)", text: $settings.clocks[index].name); TextField("Time zone", text: $settings.clocks[index].timeZone) }.textFieldStyle(.roundedBorder) }
            HStack { Button("Add city") { settings.clocks.append(ClockLocation(name: "City", timeZone: "UTC")) }.stillControl().disabled(settings.clocks.count >= 3); Button("Remove last city") { if settings.clocks.count > 1 { settings.clocks.removeLast() } }.stillControl().disabled(settings.clocks.count <= 1) }
        case .quietTimer:
            Stepper("Duration: \(settings.timerMinutes) minutes", value: $settings.timerMinutes, in: 1...240)
            HStack { Button("Start timer") { center.update(id, settings: settings); center.startTimer() }.stillControl(prominent: true); Button("Stop timer") { center.stopTimer() }.stillControl() }
        case .weather:
            TextField("City", text: $settings.city).textFieldStyle(.roundedBorder)
            HStack { TextField("Latitude", value: $settings.latitude, format: .number); TextField("Longitude", value: $settings.longitude, format: .number) }.textFieldStyle(.roundedBorder)
            Text("Open-Meteo · CC BY 4.0. Coordinates are sent to the weather service. Free endpoint is for local, non-commercial evaluation.")
            Link("Weather data attribution", destination: URL(string: "https://open-meteo.com/")!)
        case .spotify:
            Button(center.requestingSpotify ? "Waiting for macOS…" : "Allow Spotify Automation…") { center.requestSpotify() }.stillControl().disabled(center.requestingSpotify)
            if !center.spotifyConnectionStatus.isEmpty { Text(center.spotifyConnectionStatus).fixedSize(horizontal: false, vertical: true) }
            if center.requestingSpotify { Button("Cancel connection") { center.cancelSpotifyAuthorization() }.stillControl() }
            Toggle("Show track and artist", isOn: $settings.showTitles)
            Text("Reads only the local Spotify app. No Spotify web login, listening history or playback controls.")
        }
    }
}
