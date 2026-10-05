import SwiftUI

struct PreferencesView: View {
    @ObservedObject var controls: SessionControls
    var titlebarInset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Mac, on your terms.").font(.custom("InstrumentSerif-Regular", size: 34))
            inactivitySection
            if ProductFeatures.awakeControlsVisible {
                Divider()
                energySection
            }
        }
        .foregroundStyle(palette.primary)
        .padding(32).frame(width: 520)
        .padding(.top, titlebarInset)
        .stillServiceSurface()
    }

    private var inactivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("INACTIVITY")
            Picker("Show Still after", selection: Binding(get: { controls.idleMinutes }, set: { controls.setIdleMinutes($0) })) {
                ForEach(SessionControls.idleOptions, id: \.self) { minutes in
                    Text(minutes == 0 ? "Never" : "\(minutes) \(minutes == 1 ? "minute" : "minutes") of inactivity").tag(minutes)
                }
            }
            note("After returning, a fresh interval begins. This does not change your Mac’s lock settings.")
            if !controls.idleIssue.isEmpty { note(controls.idleIssue) }
        }
    }

    private var energySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("KEEP MAC AWAKE")
            durationControls
            Label(controls.energyStatus, systemImage: controls.running ? "sun.max" : "moon")
                .font(.system(size: 13, weight: .medium))
                .padding(.vertical, 8).padding(.horizontal, 12)
                .background(palette.background, in: Capsule())
            Toggle("Keep displays on during awake sessions", isOn: Binding(get: { controls.keepDisplaysOn }, set: { controls.setKeepDisplaysOn($0) }))
                .toggleStyle(.switch).tint(palette.accent)
            note("Display preference takes effect only during an awake session. Awake sessions may use more battery. Sleep and lid controls remain yours.")
            if !controls.issue.isEmpty { note(controls.issue) }
        }
    }

    private var durationControls: some View {
        HStack {
            Picker("Session duration", selection: $controls.selectedDuration) {
                ForEach(SessionControls.durations, id: \.self) { minutes in
                    Text("\(minutes) minutes").tag(minutes)
                }
            }.disabled(controls.running)
            Button(controls.running ? "Stop session" : "Start session") {
                if controls.running { controls.stop() } else { controls.start(minutes: controls.selectedDuration) }
            }
            .stillControl(prominent: true)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .semibold)).tracking(2)
    }

    private func note(_ text: String) -> some View {
        Text(text).font(.system(size: 12)).foregroundStyle(palette.secondary)
    }
}
