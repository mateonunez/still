import SwiftUI
import StillNativePlugins

struct ScreenCanvasView: View {
    let cards: [NativePluginCard]
    let composition: ScreenComposition
    let palette: PorcelainPalette
    var editing = false
    @Binding var selection: String
    var place: (String, CanvasPlacement) -> Void = { _, _ in }
    @State private var dragging: String?
    @State private var translation: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if editing {
                    Canvas { context, size in
                        var grid = Path()
                        for column in 1..<12 { let x = size.width * CGFloat(column) / 12; grid.move(to: CGPoint(x: x, y: 80)); grid.addLine(to: CGPoint(x: x, y: size.height * 0.8)) }
                        for row in 1..<8 { let y = size.height * CGFloat(row) / 8; if y >= 80 && y <= size.height * 0.8 { grid.move(to: CGPoint(x: 30, y: y)); grid.addLine(to: CGPoint(x: size.width - 30, y: y)) } }
                        context.stroke(grid, with: .color(palette.secondary.opacity(0.12)), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
                    }.accessibilityHidden(true)
                }
                module("clock", index: 0, canvas: geometry.size, width: min(480, geometry.size.width * 0.45), height: 260) {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        VStack(spacing: 14) {
                            Text(timeline.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()).font(.system(size: 11, weight: .medium)).tracking(3).foregroundStyle(palette.secondary)
                            Text(timeline.date, format: .dateTime.hour().minute()).font(.custom("InstrumentSerif-Regular", size: min(160, geometry.size.width * 0.13))).monospacedDigit()
                            Text("A little space to step away.").font(.custom("InstrumentSerif-Regular", size: 24)).foregroundStyle(palette.secondary)
                        }.foregroundStyle(palette.primary)
                    }
                }
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let setting = composition.placement(card.id.rawValue, index: index)
                    let width: CGFloat = setting.size == .wide ? 380 : setting.size == .compact ? 220 : 280
                    module(card.id.rawValue, index: index, canvas: geometry.size, width: width + 32, height: 280) {
                        NativePluginCardView(card: card, palette: palette, width: width, showDetails: setting.size != .compact).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }
    }
    private func point(_ id: String, index: Int, canvas: CGSize, width: CGFloat, height: CGFloat) -> CGPoint {
        let item = composition.placement(id, index: index)
        let bottom = max(360, canvas.height - 260)
        return CGPoint(x: min(canvas.width - width / 2 - 24, max(width / 2 + 24, canvas.width * item.x)), y: min(bottom - height / 2, max(90 + height / 2, canvas.height * item.y)))
    }
    private func module<Content: View>(_ id: String, index: Int, canvas: CGSize, width: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        let center = point(id, index: index, canvas: canvas, width: width, height: height)
        return content().frame(width: width)
            .padding(5).overlay(RoundedRectangle(cornerRadius: 22).stroke(editing && selection == id ? palette.accent : .clear, lineWidth: 2))
            .contentShape(Rectangle()).position(x: center.x + (dragging == id ? translation.width : 0), y: center.y + (dragging == id ? translation.height : 0))
            .onTapGesture { if editing { selection = id } }
            .gesture(DragGesture(minimumDistance: 3).onChanged { value in
                guard editing else { return }; selection = id; dragging = id; translation = value.translation
            }.onEnded { value in
                guard editing else { return }
                var updated = composition.placement(id, index: index)
                updated.x = (center.x + value.translation.width) / canvas.width
                updated.y = (center.y + value.translation.height) / canvas.height
                place(id, updated.snapped()); dragging = nil; translation = .zero
            }, including: editing ? .all : .none)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(id == "clock" ? "Clock" : NativePluginID(rawValue: id)?.title ?? id)
            .accessibilityAddTraits(editing ? .isButton : [])
            .accessibilityAction { if editing { selection = id } }
    }
}

struct ScreenEditorView: View {
    @ObservedObject var center: NativePluginCenter
    @ObservedObject var presentation: CurtainPresentation
    let finish: () -> Void
    @State private var selection = "clock"
    @Environment(\.colorScheme) private var scheme
    private var palette: PorcelainPalette { presentation.appearance == .light || (presentation.appearance == .system && scheme == .light) ? .light : .dark }
    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            ScreenCanvasView(cards: center.visibleCards, composition: center.composition, palette: palette, editing: true, selection: $selection, place: center.place)
            VStack {
                HStack { Text("Make room for what matters.").font(.custom("InstrumentSerif-Regular", size: 30)); Spacer(); Text("Drag to place · Snap to grid").font(.system(size: 12)).foregroundStyle(palette.secondary); Button("Done", action: finish).stillControl(prominent: true).keyboardShortcut(.defaultAction) }.padding(28)
                Spacer()
                HStack(spacing: 16) {
                    Menu("Add widget") { ForEach(center.installed.filter { center.configurations[$0]?.enabled == true && center.configurations[$0]?.visible != true }) { id in Button(id.title) { center.setVisible(id, true); selection = id.rawValue } } }
                    Picker("Selected module", selection: $selection) { Text("Clock").tag("clock"); ForEach(center.visibleIDs) { Text($0.title).tag($0.rawValue) } }.frame(width: 190)
                    Picker("Size", selection: Binding(get: { center.composition.placement(selection, index: selectedIndex).size }, set: { var p = center.composition.placement(selection, index: selectedIndex); p.size = $0; center.place(selection, p) })) { ForEach(CanvasModuleSize.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) } }.frame(width: 130).disabled(selection == "clock")
                    ForEach([("Left", -1.0, 0.0, "arrow.left"), ("Up", 0.0, -1.0, "arrow.up"), ("Down", 0.0, 1.0, "arrow.down"), ("Right", 1.0, 0.0, "arrow.right")], id: \.0) { name, x, y, symbol in Button { move(x, y) } label: { Image(systemName: symbol) }.accessibilityLabel("Move selected module \(name.lowercased())") }
                    Button("Remove") { if let id = NativePluginID(rawValue: selection) { center.setVisible(id, false); selection = "clock" } }.disabled(selection == "clock")
                    Button("Reset layout") { center.resetComposition() }
                }.padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20)).padding(.bottom, 44)
                Text("The return controls keep their own space. Changes are saved on this Mac.").font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.bottom, 20)
                if !center.issue.isEmpty { Text(center.issue).font(.system(size: 12)).foregroundStyle(palette.secondary).padding(.bottom, 16) }
            }.foregroundStyle(palette.primary).tint(palette.accent)
        }.onExitCommand(perform: finish)
    }
    private var selectedIndex: Int { center.visibleIDs.firstIndex(where: { $0.rawValue == selection }) ?? 0 }
    private func move(_ x: Double, _ y: Double) { var p = center.composition.placement(selection, index: selectedIndex); p.x += x / 12; p.y += y / 8; center.place(selection, p.snapped()) }
}
