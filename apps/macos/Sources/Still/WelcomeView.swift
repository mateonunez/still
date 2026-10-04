import SwiftUI

struct WelcomeView: View {
    let showStill: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    private var palette: PorcelainPalette { colorScheme == .dark ? .dark : .light }

    var body: some View {
        VStack(spacing: 20) {
            StillMarkView().frame(width: 48, height: 48).foregroundStyle(palette.accent)
            Text("Meet Still.").font(.custom("InstrumentSerif-Regular", size: 48))
            Text("A little space to step away.")
                .font(.system(size: 15)).foregroundStyle(palette.secondary)
            HStack(spacing: 12) {
                StillMarkView().frame(width: 20, height: 20).foregroundStyle(palette.accent)
                Text("You’ll find Still in the menu bar, at the top of your screen.")
                    .font(.system(size: 13)).fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(palette.background, in: RoundedRectangle(cornerRadius: 12))
            Button(action: showStill) {
                Text("Show Still")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16).padding(.vertical, 6)
            }
            .stillControl(prominent: true)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            Text("Visual privacy, with system authentication.\nUse the macOS security lock when you need a secure lock.")
                .font(.system(size: 11)).foregroundStyle(palette.secondary)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(palette.primary)
        .padding(36)
        .frame(width: 460)
        .stillServiceSurface()
    }
}
