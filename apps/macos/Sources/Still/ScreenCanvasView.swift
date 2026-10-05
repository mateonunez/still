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
    var frozenFrames: [String: CGRect] = [:]
    var mode: CanvasLayoutMode = .free
    var gridWidth: Double?
    struct Cache { var items: [CanvasItem] = []; var area = CGRect.zero; var frames: [String: CGRect] = [:]; var mode: CanvasLayoutMode?; var gridWidth: Double? }
    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize { proposal.replacingUnspecifiedDimensions(by: CGSize(width: 1440, height: 900)) }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let geometry = CanvasGeometry(viewport: bounds.size, reservedFooter: reservedFooter)
        let items = subviews.map { view in CanvasItem(id: view[CanvasIdentity.self], size: view.sizeThatFits(ProposedViewSize(width: min(view[CanvasWidth.self], geometry.contentBounds.width), height: nil)), placement: view[CanvasPosition.self]) }
        if frozenFrames.isEmpty && (items != cache.items || geometry.contentBounds != cache.area || mode != cache.mode || gridWidth != cache.gridWidth) { cache.items = items; cache.area = geometry.contentBounds; cache.mode = mode; cache.gridWidth = gridWidth; cache.frames = mode == .grid ? CanvasGridGeometry(viewport: bounds.size, reservedFooter: reservedFooter, preferredWidth: gridWidth).frames(for: items) : geometry.frames(for: items) }
        let frames = frozenFrames.isEmpty ? cache.frames : Dictionary(uniqueKeysWithValues: items.map { item in
            let original = frozenFrames[item.id] ?? cache.frames[item.id] ?? .zero
            return (item.id, CGRect(x: original.midX - item.size.width / 2, y: original.midY - item.size.height / 2, width: item.size.width, height: item.size.height))
        })
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
    var adjustingWidth = false
    @Binding var selection: String
    var place: (String, CanvasPlacement) -> Void = { _, _ in }
    var reorder: (String, String) -> Void = { _, _ in }
    var reportCrowding: (Bool) -> Void = { _ in }
    var reservedFooter: CGFloat = 230
    @State private var dragging: String?
    @State private var dropTarget: String?
    @State private var translation: CGSize = .zero
    @State private var renderedFrames: [String: CGRect] = [:]
    @State private var dragOrigin: CGPoint?
    @State private var resizing: String?
    @State private var resizeOrigin: CGFloat?
    @State private var resizeWidth: CGFloat?
    @State private var frozenFrames: [String: CGRect] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MeasuredCanvasLayout(reservedFooter: reservedFooter, frozenFrames: frozenFrames, mode: composition.effectiveLayout, gridWidth: composition.gridWidth) {
                    let clockWidth = liveWidth("clock", index: 0, viewport: geometry.size.width)
                    module("clock", index: 0, canvas: geometry.size, width: clockWidth) {
                        TimelineView(.periodic(from: .now, by: 1)) { timeline in
                            VStack(spacing: 14) {
                                Text(timeline.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()).font(.system(size: 11, weight: .medium)).tracking(3).foregroundStyle(palette.secondary)
                                Text(timeline.date, format: .dateTime.hour().minute()).font(.custom("InstrumentSerif-Regular", size: min(180, clockWidth * 0.36, geometry.size.height * (composition.effectiveLayout == .grid ? 0.09 : 0.18)))).monospacedDigit().minimumScaleFactor(0.7).lineLimit(1)
                                Text("A little space to step away.").font(.custom("InstrumentSerif-Regular", size: geometry.size.width < 1150 ? 20 : 24)).foregroundStyle(palette.secondary)
                            }.foregroundStyle(palette.primary)
                        }
                    }
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        let width = liveWidth(card.id.rawValue, index: index, viewport: geometry.size.width)
                        module(card.id.rawValue, index: index, canvas: geometry.size, width: width) {
                            NativePluginCardView(card: card, palette: palette, width: width, showDetails: false, taskLimit: 1)
                        }
                    }
                }
                .animation(reduceMotion || adjustingWidth || dragging != nil || resizing != nil ? nil : .smooth(duration: 0.24), value: composition)
                .animation(reduceMotion || dragging != nil ? nil : .smooth(duration: 0.24), value: cards.map(\.id))
                .mask { Path(CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds).fill(.white) }
            }.frame(width: geometry.size.width, height: geometry.size.height).coordinateSpace(name: "still.canvas").clipped()
                .onPreferenceChange(CanvasFrames.self) { frames in
                    renderedFrames = frames
                    if editing && dragging == nil && resizing == nil {
                        let area = CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds
                        reportCrowding(CanvasGeometry.hasOverlap(frames) || frames.values.contains { !area.contains($0) })
                    }
                }
        }
    }
    private func liveWidth(_ id: String, index: Int, viewport: CGFloat) -> CGFloat {
        if resizing == id, let resizeWidth { return resizeWidth }
        if composition.effectiveLayout == .grid, id != "clock" {
            return max(1, CanvasGridGeometry(viewport: CGSize(width: viewport, height: 900), reservedFooter: reservedFooter, preferredWidth: composition.gridWidth).trackWidth(count: cards.count) - 10)
        }
        return composition.placement(id, index: index).resolvedWidth(viewport: viewport, clock: id == "clock")
    }
    private func nearestModule(to point: CGPoint, excluding id: String) -> String? {
        CanvasGridGeometry.insertionTarget(at: point, frames: renderedFrames, excluding: id)
    }
    private func module<Content: View>(_ id: String, index: Int, canvas: CGSize, width: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        content().frame(width: width)
            .padding(5).overlay(RoundedRectangle(cornerRadius: 22).stroke(editing && (selection == id || dropTarget == id) ? palette.accent : .clear, lineWidth: 2))
            .contentShape(Rectangle())
            .background { GeometryReader { proxy in Color.clear.preference(key: CanvasFrames.self, value: [id: proxy.frame(in: .named("still.canvas"))]) } }
            .layoutValue(key: CanvasIdentity.self, value: id)
            .layoutValue(key: CanvasPosition.self, value: composition.placement(id, index: index))
            .layoutValue(key: CanvasWidth.self, value: width + 10)
            .layoutValue(key: CanvasOffset.self, value: dragging == id ? translation : .zero)
            .onTapGesture { if editing { selection = id } }
            .gesture(DragGesture(minimumDistance: 3, coordinateSpace: .named("still.canvas")).onChanged { value in
                guard editing, resizing == nil, composition.effectiveLayout == .free || id != "clock" else { return }
                if dragging == nil, let frame = renderedFrames[id] {
                    dragOrigin = CGPoint(x: frame.midX, y: frame.midY)
                    if composition.effectiveLayout == .grid { frozenFrames = renderedFrames }
                }
                selection = id; dragging = id; translation = value.translation
                if composition.effectiveLayout == .grid, let origin = dragOrigin {
                    let point = CGPoint(x: origin.x + value.translation.width, y: origin.y + value.translation.height)
                    dropTarget = nearestModule(to: point, excluding: id)
                }
            }.onEnded { value in
                guard editing, resizing == nil, composition.effectiveLayout == .free || id != "clock" else { return }
                if composition.effectiveLayout == .grid {
                    if let dropTarget { reorder(id, dropTarget) }
                    dragging = nil; translation = .zero; dragOrigin = nil; dropTarget = nil; frozenFrames = [:]
                    return
                }
                var updated = composition.placement(id, index: index)
                let origin = dragOrigin ?? CGPoint(x: updated.x * canvas.width, y: updated.y * canvas.height)
                updated.x = (origin.x + value.translation.width) / canvas.width
                updated.y = (origin.y + value.translation.height) / canvas.height
                place(id, updated.fitted()); dragging = nil; translation = .zero; dragOrigin = nil
            }, including: editing ? .all : .none)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(id == "clock" ? "Clock" : NativePluginID(rawValue: id)?.title ?? id)
            .accessibilityAddTraits(editing ? .isButton : [])
            .accessibilityAction { if editing { selection = id } }
            .overlay(alignment: .bottomTrailing) {
                if editing && selection == id && composition.effectiveLayout == .free {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 10, weight: .semibold)).foregroundStyle(palette.primary)
                        .frame(width: 30, height: 24).background(palette.surface, in: Capsule())
                        .overlay(Capsule().stroke(palette.accent, lineWidth: 1))
                        .offset(x: 10, y: 10)
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("still.canvas")).onChanged { value in
                            if resizing == nil { resizeOrigin = width; frozenFrames = renderedFrames }
                            resizing = id
                            let maximum = min(600, max(180, canvas.width * (id == "clock" ? 0.55 : 0.32)))
                            resizeWidth = min(maximum, max(180, (resizeOrigin ?? width) + value.translation.width * 2))
                        }.onEnded { _ in
                            var updated = composition.placement(id, index: index)
                            updated.width = resizeWidth ?? width
                            place(id, updated); resizing = nil; resizeOrigin = nil; resizeWidth = nil; frozenFrames = [:]
                        })
                        .help("Drag to resize. Height follows content.")
                        .accessibilityHidden(true)
                }
            }
    }
}

struct ScreenEditorView: View {
    @ObservedObject var center: NativePluginCenter
    @ObservedObject var presentation: CurtainPresentation
    let finish: () -> Void
    @State private var selection = "clock"
    @State private var crowded = false
    @State private var adjustingWidth = false
    @State private var editorWidth: CGFloat = 1440
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    private var palette: PorcelainPalette { presentation.appearance == .light || (presentation.appearance == .system && scheme == .light) ? .light : .dark }
    private var grid: Bool { center.composition.effectiveLayout == .grid }
    private var selectedIndex: Int { center.visibleIDs.firstIndex(where: { $0.rawValue == selection }) ?? 0 }
    private var selectedPlacement: CanvasPlacement { center.composition.placement(selection, index: selectedIndex) }

    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            canvas
            VStack {
                header
                Spacer()
                toolbar
                Text("The return controls keep their own space. Changes are saved on this Mac.").font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.bottom, 20)
                if crowded { Text("This screen needs more room. Reduce widths or remove a widget.").font(.system(size: 12)).foregroundStyle(palette.secondary).padding(.bottom, 16) }
                if !center.issue.isEmpty { Text(center.issue).font(.system(size: 12)).foregroundStyle(palette.secondary).padding(.bottom, 16) }
            }.foregroundStyle(palette.primary).tint(palette.accent)
        }.background { GeometryReader { proxy in Color.clear.onAppear { editorWidth = proxy.size.width }.onChange(of: proxy.size.width) { _, width in editorWidth = width } } }
        .onExitCommand(perform: finish)
    }
    private var canvas: some View {
        ScreenCanvasView(cards: center.visibleCards, composition: center.composition, palette: palette, editing: true, adjustingWidth: adjustingWidth, selection: $selection, place: center.place, reorder: reorder, reportCrowding: { crowded = $0 })
    }
    private var header: some View {
        HStack {
            Text("Make room for what matters.").font(.custom("InstrumentSerif-Regular", size: 30))
            Spacer()
            Text(grid ? "Aligned columns · Drop on a card to reorder" : "Drag to move · Pull the handle to resize").font(.system(size: 12)).foregroundStyle(palette.secondary)
            Button("Done", action: finish).stillControl(prominent: true).keyboardShortcut(.defaultAction)
        }.padding(28)
    }
    private var toolbar: some View {
        VStack(spacing: 14) { primaryControls; Divider(); sizingControls }
            .frame(maxWidth: 820).controlSize(.small).padding(16).background { toolbarSurface }
            .padding(.horizontal, 24).padding(.bottom, 32)
    }
    @ViewBuilder private var toolbarSurface: some View {
        if reduceTransparency || contrast == .increased { RoundedRectangle(cornerRadius: 22).fill(palette.surface) }
        else if #available(macOS 26.0, *) { RoundedRectangle(cornerRadius: 22).fill(.clear).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22)) }
        else { RoundedRectangle(cornerRadius: 22).fill(.regularMaterial) }
    }
    private var primaryControls: some View {
        HStack(spacing: 12) {
            Picker("Arrangement", selection: Binding(get: { center.composition.effectiveLayout }, set: { center.setLayout($0) })) { Text("Grid").tag(CanvasLayoutMode.grid); Text("Free").tag(CanvasLayoutMode.free) }.pickerStyle(.segmented).labelsHidden().frame(width: 120)
            Menu("Presets") { ForEach(CanvasPreset.allCases, id: \.self) { preset in Button(preset.title) { center.applyPreset(preset) } } }.disabled(grid)
            Menu("Add widget") { ForEach(center.installed.filter { center.configurations[$0]?.enabled == true && center.configurations[$0]?.visible != true }) { id in Button(id.title) { center.setVisible(id, true); selection = id.rawValue } } }
            Picker("Selected module", selection: $selection) { Text("Clock").tag("clock"); ForEach(center.visibleIDs) { Text($0.title).tag($0.rawValue) } }.labelsHidden().frame(width: 175)
            Spacer(minLength: 8)
            Button("Remove") { if let id = NativePluginID(rawValue: selection) { center.setVisible(id, false); selection = "clock" } }.disabled(selection == "clock")
            Button("Reset layout") { center.resetComposition() }
        }
    }
    private var sizingControls: some View {
        HStack(spacing: 16) {
            if grid { gridSizing } else { freeSizing }
            movementControls
            Spacer(minLength: 8)
            Text(grid ? "Rows fit content" : "Height fits content").font(.system(size: 11)).foregroundStyle(palette.secondary)
        }
    }
    @ViewBuilder private var gridSizing: some View {
        Toggle("Automatic columns", isOn: Binding(get: { center.composition.gridWidth == nil }, set: { center.setGridWidth($0 ? nil : 280) })).toggleStyle(.switch).controlSize(.small)
        if let width = center.composition.gridWidth {
            Slider(value: Binding(get: { width }, set: { center.setGridWidth($0) }), in: 180...600, onEditingChanged: { adjustingWidth = $0 }) { Text("Preferred column width") }.frame(width: 120)
        }
    }
    @ViewBuilder private var freeSizing: some View {
        Toggle("Automatic", isOn: Binding(get: { selectedPlacement.width == nil }, set: { automatic in var p = selectedPlacement; p.width = automatic ? nil : p.resolvedWidth(viewport: editorWidth, clock: selection == "clock"); center.place(selection, p) })).toggleStyle(.switch).controlSize(.small).help("Adapt width to this display. Height always follows content.")
        if selectedPlacement.width != nil {
            let maximum = min(600, max(180, editorWidth * (selection == "clock" ? 0.55 : 0.32)))
            Slider(value: Binding(get: { selectedPlacement.resolvedWidth(viewport: editorWidth, clock: selection == "clock") }, set: { value in var p = selectedPlacement; p.width = value; center.place(selection, p) }), in: 180...maximum, onEditingChanged: { adjustingWidth = $0 }) { Text("Module width") }.frame(width: 120).accessibilityLabel("Selected module width")
        }
    }
    private var movementControls: some View {
        ForEach([("Left", -1.0, 0.0, "arrow.left"), ("Up", 0.0, -1.0, "arrow.up"), ("Down", 0.0, 1.0, "arrow.down"), ("Right", 1.0, 0.0, "arrow.right")], id: \.0) { name, x, y, symbol in
            Button { move(x, y) } label: { Image(systemName: symbol) }.accessibilityLabel("Move selected module \(name.lowercased())").disabled(grid && selection == "clock")
        }
    }
    private func reorder(_ source: String, _ target: String) {
        if let source = NativePluginID(rawValue: source), let target = NativePluginID(rawValue: target) { center.reorderVisible(source, over: target) }
    }
    private func move(_ x: Double, _ y: Double) {
        if grid {
            guard let id = NativePluginID(rawValue: selection) else { return }
            let columns = CanvasGridGeometry(viewport: CGSize(width: editorWidth, height: 900), preferredWidth: center.composition.gridWidth).columns(count: center.visibleIDs.count)
            center.move(id, by: Int(x) + Int(y) * columns)
        } else { var p = selectedPlacement; p.x += x / 100; p.y += y / 100; center.place(selection, p.fitted()) }
    }
}
