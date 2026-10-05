import SwiftUI
import StillNativePlugins

private struct CanvasIdentity: LayoutValueKey { static let defaultValue = "clock" }
private struct CanvasPosition: LayoutValueKey { static let defaultValue = CanvasPlacement(x: 0.5, y: 0.4) }
private struct CanvasOffset: LayoutValueKey { static let defaultValue = CGSize.zero }
private struct CanvasWidth: LayoutValueKey { static let defaultValue: CGFloat = 280 }
private struct CanvasFrames: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) { value.merge(nextValue(), uniquingKeysWith: { _, latest in latest }) }
}

/// Measure actual cards before positioning them in this display's coordinate space.
private struct MeasuredCanvasLayout: Layout {
    var reservedFooter: CGFloat = 230
    struct Cache { var items: [CanvasItem] = []; var area = CGRect.zero; var frames: [String: CGRect] = [:] }
    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize { proposal.replacingUnspecifiedDimensions(by: CGSize(width: 1440, height: 900)) }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let geometry = CanvasGeometry(viewport: bounds.size, reservedFooter: reservedFooter)
        let items = subviews.map { view in CanvasItem(id: view[CanvasIdentity.self], size: view.sizeThatFits(ProposedViewSize(width: min(view[CanvasWidth.self], geometry.contentBounds.width), height: nil)), placement: view[CanvasPosition.self]) }
        if items != cache.items || geometry.contentBounds != cache.area { cache.items = items; cache.area = geometry.contentBounds; cache.frames = geometry.frames(for: items) }
        let frames = cache.frames
        for view in subviews {
            guard let rect = frames[view[CanvasIdentity.self]] else { continue }
            let offset = view[CanvasOffset.self]
            view.place(at: CGPoint(x: bounds.minX + rect.midX + offset.width, y: bounds.minY + rect.midY + offset.height), anchor: .center, proposal: ProposedViewSize(rect.size))
        }
    }
}

struct ScreenCanvasView: View {
    let cards: [NativePluginCard]
    let composition: ScreenComposition
    let palette: PorcelainPalette
    var editing = false
    @Binding var selection: String
    var place: (String, CanvasPlacement) -> Void = { _, _ in }
    var reportCrowding: (Bool) -> Void = { _ in }
    var reservedFooter: CGFloat = 230
    @State private var dragging: String?
    @State private var translation: CGSize = .zero
    @State private var renderedFrames: [String: CGRect] = [:]
    @State private var dragOrigin: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if editing {
                    Canvas { context, size in
                        var grid = Path()
                        for column in 1..<12 { let x = size.width * CGFloat(column) / 12; grid.move(to: CGPoint(x: x, y: 90)); grid.addLine(to: CGPoint(x: x, y: size.height - 230)) }
                        for row in 1..<8 { let y = size.height * CGFloat(row) / 8; if y >= 90 && y <= size.height - 230 { grid.move(to: CGPoint(x: 24, y: y)); grid.addLine(to: CGPoint(x: size.width - 24, y: y)) } }
                        context.stroke(grid, with: .color(palette.secondary.opacity(0.12)), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
                    }.accessibilityHidden(true)
                }
                MeasuredCanvasLayout(reservedFooter: reservedFooter) {
                    module("clock", index: 0, canvas: geometry.size, width: min(480, geometry.size.width * 0.38)) {
                        TimelineView(.periodic(from: .now, by: 1)) { timeline in
                            VStack(spacing: 14) {
                                Text(timeline.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()).font(.system(size: 11, weight: .medium)).tracking(3).foregroundStyle(palette.secondary)
                                Text(timeline.date, format: .dateTime.hour().minute()).font(.custom("InstrumentSerif-Regular", size: min(160, geometry.size.width * 0.105, geometry.size.height * 0.16))).monospacedDigit().minimumScaleFactor(0.7).lineLimit(1)
                                Text("A little space to step away.").font(.custom("InstrumentSerif-Regular", size: geometry.size.width < 1150 ? 20 : 24)).foregroundStyle(palette.secondary)
                            }.foregroundStyle(palette.primary)
                        }
                    }
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        let setting = composition.placement(card.id.rawValue, index: index)
                        let compact = setting.size == .compact || geometry.size.width < 1150
                        let requested: CGFloat = compact ? 220 : setting.size == .wide ? 380 : 280
                        let width = min(requested, max(180, geometry.size.width * 0.27))
                        module(card.id.rawValue, index: index, canvas: geometry.size, width: width) {
                            NativePluginCardView(card: card, palette: palette, width: width, showDetails: !compact, taskLimit: setting.size == .wide && !compact ? 2 : 1)
                        }
                    }
                }.mask { Path(CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds).fill(.white) }
            }.frame(width: geometry.size.width, height: geometry.size.height).coordinateSpace(name: "still.canvas").clipped()
                .onPreferenceChange(CanvasFrames.self) { frames in
                    renderedFrames = frames
                    if editing && dragging == nil {
                        let area = CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds
                        reportCrowding(CanvasGeometry.hasOverlap(frames) || frames.values.contains { !area.contains($0) })
                    }
                }
        }
    }
    private func module<Content: View>(_ id: String, index: Int, canvas: CGSize, width: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        content().frame(width: width)
            .padding(5).overlay(RoundedRectangle(cornerRadius: 22).stroke(editing && selection == id ? palette.accent : .clear, lineWidth: 2))
            .contentShape(Rectangle())
            .background { GeometryReader { proxy in Color.clear.preference(key: CanvasFrames.self, value: [id: proxy.frame(in: .named("still.canvas"))]) } }
            .layoutValue(key: CanvasIdentity.self, value: id)
            .layoutValue(key: CanvasPosition.self, value: composition.placement(id, index: index))
            .layoutValue(key: CanvasWidth.self, value: width + 10)
            .layoutValue(key: CanvasOffset.self, value: dragging == id ? translation : .zero)
            .onTapGesture { if editing { selection = id } }
            .gesture(DragGesture(minimumDistance: 3).onChanged { value in
                guard editing else { return }
                if dragging == nil, let frame = renderedFrames[id] { dragOrigin = CGPoint(x: frame.midX, y: frame.midY) }
                selection = id; dragging = id; translation = value.translation
            }.onEnded { value in
                guard editing else { return }
                var updated = composition.placement(id, index: index)
                let origin = dragOrigin ?? CGPoint(x: updated.x * canvas.width, y: updated.y * canvas.height)
                updated.x = (origin.x + value.translation.width) / canvas.width
                updated.y = (origin.y + value.translation.height) / canvas.height
                place(id, updated.snapped()); dragging = nil; translation = .zero; dragOrigin = nil
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
    @State private var crowded = false
    @Environment(\.colorScheme) private var scheme
    private var palette: PorcelainPalette { presentation.appearance == .light || (presentation.appearance == .system && scheme == .light) ? .light : .dark }
    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            ScreenCanvasView(cards: center.visibleCards, composition: center.composition, palette: palette, editing: true, selection: $selection, place: center.place, reportCrowding: { crowded = $0 })
            VStack {
                HStack { Text("Make room for what matters.").font(.custom("InstrumentSerif-Regular", size: 30)); Spacer(); Text("Main display · Auto fit · Drag to place").font(.system(size: 12)).foregroundStyle(palette.secondary); Button("Done", action: finish).stillControl(prominent: true).keyboardShortcut(.defaultAction) }.padding(28)
                Spacer()
                HStack(spacing: 16) {
                    Menu("Layout") { ForEach(CanvasPreset.allCases, id: \.self) { preset in Button(preset.title) { center.applyPreset(preset) } } }
                    Menu("Add widget") { ForEach(center.installed.filter { center.configurations[$0]?.enabled == true && center.configurations[$0]?.visible != true }) { id in Button(id.title) { center.setVisible(id, true); selection = id.rawValue } } }
                    Picker("Selected module", selection: $selection) { Text("Clock").tag("clock"); ForEach(center.visibleIDs) { Text($0.title).tag($0.rawValue) } }.frame(width: 190)
                    Picker("Size", selection: Binding(get: { center.composition.placement(selection, index: selectedIndex).size }, set: { var p = center.composition.placement(selection, index: selectedIndex); p.size = $0; center.place(selection, p) })) { ForEach(CanvasModuleSize.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) } }.frame(width: 130).disabled(selection == "clock")
                    ForEach([("Left", -1.0, 0.0, "arrow.left"), ("Up", 0.0, -1.0, "arrow.up"), ("Down", 0.0, 1.0, "arrow.down"), ("Right", 1.0, 0.0, "arrow.right")], id: \.0) { name, x, y, symbol in Button { move(x, y) } label: { Image(systemName: symbol) }.accessibilityLabel("Move selected module \(name.lowercased())") }
                    Button("Remove") { if let id = NativePluginID(rawValue: selection) { center.setVisible(id, false); selection = "clock" } }.disabled(selection == "clock")
                    Button("Reset layout") { center.resetComposition() }
                }.padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20)).padding(.bottom, 44)
                Text("The return controls keep their own space. Changes are saved on this Mac.").font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.bottom, 20)
                if crowded { Text("This screen needs more room. Choose Compact or remove a widget.").font(.system(size: 12)).foregroundStyle(palette.secondary).padding(.bottom, 16) }
                if !center.issue.isEmpty { Text(center.issue).font(.system(size: 12)).foregroundStyle(palette.secondary).padding(.bottom, 16) }
            }.foregroundStyle(palette.primary).tint(palette.accent)
        }.onExitCommand(perform: finish)
    }
    private var selectedIndex: Int { center.visibleIDs.firstIndex(where: { $0.rawValue == selection }) ?? 0 }
    private func move(_ x: Double, _ y: Double) { var p = center.composition.placement(selection, index: selectedIndex); p.x += x / 12; p.y += y / 8; center.place(selection, p.snapped()) }
}
