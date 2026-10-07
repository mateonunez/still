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
    var resizing: String?
    struct Cache { var items: [CanvasItem] = []; var area = CGRect.zero; var frames: [String: CGRect] = [:]; var mode: CanvasLayoutMode?; var gridWidth: Double? }
    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize { proposal.replacingUnspecifiedDimensions(by: CGSize(width: 1440, height: 900)) }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let geometry = CanvasGeometry(viewport: bounds.size, reservedFooter: reservedFooter)
        let items = subviews.map { view in CanvasItem(id: view[CanvasIdentity.self], size: view.sizeThatFits(ProposedViewSize(width: min(view[CanvasWidth.self], geometry.contentBounds.width), height: nil)), placement: view[CanvasPosition.self]) }
        if frozenFrames.isEmpty && (items != cache.items || geometry.contentBounds != cache.area || mode != cache.mode || gridWidth != cache.gridWidth) { cache.items = items; cache.area = geometry.contentBounds; cache.mode = mode; cache.gridWidth = gridWidth; cache.frames = mode == .grid ? CanvasGridGeometry(viewport: bounds.size, reservedFooter: reservedFooter, preferredWidth: gridWidth).frames(for: items) : geometry.frames(for: items) }
        let frames = frozenFrames.isEmpty ? cache.frames : Dictionary(uniqueKeysWithValues: items.map { item in
            let original = frozenFrames[item.id] ?? cache.frames[item.id] ?? .zero
            let rect = item.id == resizing ? CanvasResizeGeometry.frame(original: original, size: item.size) : CGRect(x: original.midX - item.size.width / 2, y: original.midY - item.size.height / 2, width: item.size.width, height: item.size.height)
            return (item.id, rect)
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
    @State private var gridDrag: String?
    @State private var gridLastTarget: String?
    @State private var dragging: String?
    @State private var translation: CGSize = .zero
    @State private var renderedFrames: [String: CGRect] = [:]
    @State private var dragOrigin: CGPoint?
    @State private var resizing: String?
    @State private var resizeOrigin: CGFloat?
    @State private var resizeWidth: CGFloat?
    @State private var frozenFrames: [String: CGRect] = [:]
    @State private var alignment: CanvasAlignment?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if editing, dragging != nil, let alignment {
                    let bounds = CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds
                    Path { path in
                        if let x = alignment.verticalGuide { path.move(to: CGPoint(x: x, y: bounds.minY)); path.addLine(to: CGPoint(x: x, y: bounds.maxY)) }
                        if let y = alignment.horizontalGuide { path.move(to: CGPoint(x: bounds.minX, y: y)); path.addLine(to: CGPoint(x: bounds.maxX, y: y)) }
                    }.stroke(palette.accent.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 4])).allowsHitTesting(false).accessibilityHidden(true)
                }
                MeasuredCanvasLayout(reservedFooter: reservedFooter, frozenFrames: frozenFrames, mode: composition.effectiveLayout, gridWidth: composition.gridWidth, resizing: resizing) {
                    let clockWidth = liveWidth("clock", index: 0, viewport: geometry.size.width)
                    module("clock", index: 0, canvas: geometry.size, width: clockWidth) {
                        StillClockFace(palette: palette, size: min(180, clockWidth * 0.36, geometry.size.height * (composition.effectiveLayout == .grid ? max(0.09, 0.18 - Double(cards.count) * 0.009) : 0.18)), messageSize: geometry.size.width < 1150 ? 20 : 24)
                    }
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        let width = liveWidth(card.id.rawValue, index: index, viewport: geometry.size.width)
                        module(card.id.rawValue, index: index, canvas: geometry.size, width: width) {
                            NativePluginCardView(card: card, palette: palette, width: width, showDetails: composition.placement(card.id.rawValue, index: index).showsDetails, taskLimit: composition.placement(card.id.rawValue, index: index).showsDetails ? 4 : 1)
                        }
                    }
                }
                .animation(reduceMotion || adjustingWidth || dragging != nil || resizing != nil ? nil : .smooth(duration: 0.24), value: composition)
                .animation(reduceMotion || dragging != nil ? nil : .smooth(duration: 0.24), value: cards.map(\.id))
                .mask { Path(CanvasGeometry(viewport: geometry.size, reservedFooter: reservedFooter).contentBounds).fill(.white) }
                .transaction { transaction in
                    if dragging != nil || resizing != nil {
                        transaction.animation = nil
                        transaction.disablesAnimations = true
                    }
                }
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
            .gesture(DragGesture(minimumDistance: 3, coordinateSpace: .named("still.canvas")).onChanged { value in
                guard editing, resizing == nil, composition.effectiveLayout == .free else { return }
                if dragging == nil, let frame = renderedFrames[id] {
                    dragOrigin = CGPoint(x: frame.midX, y: frame.midY)
                    frozenFrames = renderedFrames
                }
                selection = id; dragging = id
                if let frame = frozenFrames[id] {
                    let aligned = CanvasAlignment.resolve(frame: frame, translation: value.translation, others: frozenFrames.filter { $0.key != id }.map(\.value), bounds: CanvasGeometry(viewport: canvas, reservedFooter: reservedFooter).contentBounds)
                    alignment = aligned
                    translation = CGSize(width: aligned.center.x - frame.midX, height: aligned.center.y - frame.midY)
                } else { translation = value.translation }
            }.onEnded { value in
                guard editing, resizing == nil, composition.effectiveLayout == .free else { return }
                var updated = composition.placement(id, index: index)
                let origin = dragOrigin ?? CGPoint(x: updated.x * canvas.width, y: updated.y * canvas.height)
                updated.x = (origin.x + translation.width) / canvas.width
                updated.y = (origin.y + translation.height) / canvas.height
                place(id, updated.fitted()); dragging = nil; translation = .zero; dragOrigin = nil; frozenFrames = [:]; alignment = nil
            }, including: editing && composition.effectiveLayout == .free ? .all : .none)
            .modifier(CanvasGridDrag(id: id, enabled: editing && composition.effectiveLayout == .grid && id != "clock", accent: palette.accent, source: $gridDrag, lastTarget: $gridLastTarget, select: { selection = id }, reorder: reorder))
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
                        .padding(3)
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("still.canvas")).onChanged { value in
                            if resizing == nil { resizeOrigin = width; frozenFrames = renderedFrames }
                            resizing = id
                            let bounds = CanvasGeometry(viewport: canvas, reservedFooter: reservedFooter).contentBounds
                            let leading = frozenFrames[id]?.minX ?? bounds.minX
                            let maximum = min(600, max(180, bounds.maxX - leading - 10))
                            resizeWidth = min(maximum, max(180, (resizeOrigin ?? width) + value.translation.width))
                        }.onEnded { _ in
                            var updated = composition.placement(id, index: index)
                            updated.width = resizeWidth ?? width
                            if let original = frozenFrames[id] {
                                let size = CGSize(width: (resizeWidth ?? width) + 10, height: renderedFrames[id]?.height ?? original.height)
                                let frame = CanvasResizeGeometry.frame(original: original, size: size)
                                updated.x = frame.midX / canvas.width
                                updated.y = frame.midY / canvas.height
                            }
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
    @State private var showGallery = false
    @State private var showAppearance = false
    @State private var showInspector = false
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    private var palette: PorcelainPalette { presentation.theme.palette(dark: presentation.appearance == .dark || (presentation.appearance == .system && scheme == .dark)) }
    private var grid: Bool { center.composition.effectiveLayout == .grid }
    private var selectedIndex: Int { center.visibleIDs.firstIndex(where: { $0.rawValue == selection }) ?? 0 }
    private var selectedPlacement: CanvasPlacement { center.composition.placement(selection, index: selectedIndex) }
    private var selectedTitle: String { selection == "clock" ? "Clock" : NativePluginID(rawValue: selection)?.title ?? "Widget" }

    var body: some View {
        ZStack {
            StillSceneBackground(theme: presentation.theme, palette: palette)
            canvas
            VStack {
                header
                Spacer()
                selectionBar
                status.padding(.bottom, 20)
            }.foregroundStyle(palette.primary).tint(palette.accent)
        }
        .environment(\.stillTheme, presentation.theme)
        .preferredColorScheme(presentation.appearance == .system ? nil : presentation.appearance == .dark ? .dark : .light)
        .background { GeometryReader { proxy in Color.clear.onAppear { editorWidth = proxy.size.width }.onChange(of: proxy.size.width) { _, width in editorWidth = width } } }
        .onChange(of: center.visibleIDs) { _, ids in if selection != "clock", !ids.contains(where: { $0.rawValue == selection }) { selection = "clock" } }
        .sheet(isPresented: $showGallery) { gallery }
        .onExitCommand { if showAppearance || showInspector { showAppearance = false; showInspector = false } else { finish() } }
    }
    private var canvas: some View {
        ScreenCanvasView(cards: center.visibleCards, composition: center.composition, palette: palette, editing: true, adjustingWidth: adjustingWidth, selection: $selection, place: center.place, reorder: reorder, reportCrowding: { crowded = $0 }, reservedFooter: 155)
    }
    private var header: some View {
        HStack(spacing: 14) {
            Label("Edit screen", systemImage: "rectangle.3.group").font(.system(size: 15, weight: .semibold))
            Spacer()
            Picker("Arrangement", selection: Binding(get: { center.composition.effectiveLayout }, set: { center.setLayout($0) })) {
                Text("Grid").tag(CanvasLayoutMode.grid); Text("Free").tag(CanvasLayoutMode.free)
            }.pickerStyle(.segmented).labelsHidden().frame(width: 140)
            Button { showAppearance = true } label: { Label("Appearance", systemImage: "paintpalette") }.stillControl()
                .popover(isPresented: $showAppearance) { SceneAppearanceControls(presentation: presentation).padding(24).frame(width: 310) }
            Button { showGallery = true } label: { Label("Add widget", systemImage: "plus") }.stillControl()
            Button("Done", action: finish).stillControl(prominent: true).keyboardShortcut(.defaultAction)
        }.padding(.horizontal, 28).padding(.vertical, 22)
    }
    private var selectionBar: some View {
        HStack(spacing: 16) {
            Picker("Selected module", selection: $selection) {
                Text("Clock").tag("clock"); ForEach(center.visibleIDs) { Text($0.title).tag($0.rawValue) }
            }.labelsHidden().frame(width: 150)
            Divider().frame(height: 20)
            Button { showInspector = true } label: { Label("Adjust", systemImage: "slider.horizontal.3") }.buttonStyle(.borderless)
                .popover(isPresented: $showInspector) { inspector.padding(24).frame(width: 320) }
            Menu { movementControls } label: { Image(systemName: "arrow.up.and.down.and.arrow.left.and.right") }.menuStyle(.borderlessButton).fixedSize().accessibilityLabel("Move \(selectedTitle)")
            if selection != "clock" {
                Button(role: .destructive) { removeSelection() } label: { Image(systemName: "minus.circle") }.buttonStyle(.borderless).accessibilityLabel("Remove \(selectedTitle)")
            }
        }.padding(.horizontal, 18).padding(.vertical, 12).background { toolbarSurface }.fixedSize().padding(.bottom, 12)
    }
    @ViewBuilder private var toolbarSurface: some View {
        if reduceTransparency || contrast == .increased { RoundedRectangle(cornerRadius: 24).fill(palette.surface) }
        else if #available(macOS 26.0, *) { RoundedRectangle(cornerRadius: 24).fill(.clear).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24)) }
        else { RoundedRectangle(cornerRadius: 24).fill(.regularMaterial) }
    }
    private var status: some View {
        Text(crowded ? "Not all modules fit. Try narrower columns or fewer widgets." : grid ? "Drag widgets to reorder. Select a module to adjust it." : "Drag to move. Pull a selected module’s handle to resize.")
            .font(.system(size: 12)).foregroundStyle(palette.secondary)
    }
    private var inspector: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(selectedTitle).font(.system(size: 20, weight: .semibold))
            if selection == "clock" { ClockAppearanceControls() }
            else { Toggle("Show source details", isOn: Binding(get: { selectedPlacement.showsDetails }, set: { value in var p = selectedPlacement; p.showsDetails = value; center.place(selection, p) })).toggleStyle(.switch) }
            if grid && selection != "clock" { gridSizing } else { freeSizing }
            Text(grid ? "Grid aligns rows automatically. Module height follows its content." : "Width is continuous. Height follows content.").font(.system(size: 12)).foregroundStyle(.secondary)
            Divider()
            Menu("Reset arrangement") {
                Button("Reset layout") { center.resetComposition() }
                ForEach(CanvasPreset.allCases, id: \.self) { preset in Button(preset.title) { center.applyPreset(preset) } }
            }.stillControl()
        }
    }
    private var gallery: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack { Text("Widget gallery").font(.system(size: 24, weight: .semibold)); Spacer(); Button("Done") { showGallery = false }.keyboardShortcut(.cancelAction) }
            Text("Choose a connected widget. Configure sources and permissions in Settings → Plugins.").font(.system(size: 13)).foregroundStyle(.secondary)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 210))], spacing: 16) {
                    ForEach(center.installed) { id in galleryItem(id) }
                }
            }
        }.padding(28).frame(width: 620, height: 510)
    }
    private func galleryItem(_ id: NativePluginID) -> some View {
        let enabled = center.configurations[id]?.enabled == true
        let visible = center.configurations[id]?.visible == true
        return Button {
            center.setVisible(id, true); selection = id.rawValue; showGallery = false
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Label(id.title, systemImage: id.symbol).font(.system(size: 14, weight: .semibold))
                Text(visible ? "Already on your screen" : enabled ? "Add to screen" : "Connect in Settings first").font(.system(size: 11)).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, minHeight: 75, alignment: .leading).padding(14)
        }.buttonStyle(.bordered).disabled(!enabled || visible)
    }
    @ViewBuilder private var gridSizing: some View {
        Toggle("Automatic columns", isOn: Binding(get: { center.composition.gridWidth == nil }, set: { center.setGridWidth($0 ? nil : 280) })).toggleStyle(.switch)
        if let width = center.composition.gridWidth {
            Slider(value: Binding(get: { width }, set: { center.setGridWidth($0) }), in: 180...600, onEditingChanged: { adjustingWidth = $0 }) { Text("Preferred column width") }
        }
    }
    @ViewBuilder private var freeSizing: some View {
        Toggle("Automatic width", isOn: Binding(get: { selectedPlacement.width == nil }, set: { automatic in var p = selectedPlacement; p.width = automatic ? nil : p.resolvedWidth(viewport: editorWidth, clock: selection == "clock"); center.place(selection, p) })).toggleStyle(.switch)
        if selectedPlacement.width != nil {
            let maximum = min(600, max(180, editorWidth - 58))
            Slider(value: Binding(get: { selectedPlacement.resolvedWidth(viewport: editorWidth, clock: selection == "clock") }, set: { value in var p = selectedPlacement; p.width = value; center.place(selection, p) }), in: 180...maximum, onEditingChanged: { adjustingWidth = $0 }) { Text("Module width") }
        }
    }
    private var movementControls: some View {
        ForEach([("Left", -1.0, 0.0, "arrow.left"), ("Up", 0.0, -1.0, "arrow.up"), ("Down", 0.0, 1.0, "arrow.down"), ("Right", 1.0, 0.0, "arrow.right")], id: \.0) { name, x, y, symbol in
            Button { move(x, y) } label: { Image(systemName: symbol) }.buttonStyle(.borderless).accessibilityLabel("Move selected module \(name.lowercased())").disabled(grid && selection == "clock")
        }
    }
    private func removeSelection() { if let id = NativePluginID(rawValue: selection) { center.setVisible(id, false); selection = "clock"; showInspector = false } }
    private func reorder(_ source: String, _ target: String) {
        if let source = NativePluginID(rawValue: source), let target = NativePluginID(rawValue: target) { center.reorderVisible(source, over: target) }
    }
    private func move(_ x: Double, _ y: Double) {
        if grid {
            guard let id = NativePluginID(rawValue: selection) else { return }
            let columns = CanvasGridGeometry(viewport: CGSize(width: editorWidth, height: 900), preferredWidth: center.composition.gridWidth).columns(count: center.visibleIDs.count)
            center.move(id, by: Int(x) + Int(y) * columns)
        } else {
            var p = selectedPlacement; p.x += x * 0.025; p.y += y * 0.025; center.place(selection, p.fitted())
        }
    }
}

struct ClockAppearanceControls: View {
    @AppStorage("StillClockStyle") private var style = StillClockStyle.serif.rawValue
    @AppStorage("StillShowDate") private var date = true
    @AppStorage("StillShowTagline") private var tagline = true
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Clock type", selection: $style) { ForEach(StillClockStyle.allCases, id: \.self) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
            Toggle("Show date", isOn: $date).toggleStyle(.switch)
            Toggle("Show message", isOn: $tagline).toggleStyle(.switch)
        }
    }
}

struct SceneAppearanceControls: View {
    @ObservedObject var presentation: CurtainPresentation
    @AppStorage("StillBackdrop") private var backdrop = StillBackdropStyle.aurora.rawValue
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ForEach(StillTheme.allCases, id: \.self) { theme in
                    let palette = theme.palette(dark: presentation.appearance == .dark || (presentation.appearance == .system && scheme == .dark))
                    Button { presentation.theme = theme } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            ZStack {
                                StillSceneBackground(theme: theme, palette: palette)
                                Text("12:48").font(.custom("InstrumentSerif-Regular", size: 32)).foregroundStyle(palette.primary)
                            }.frame(height: 78).clipShape(RoundedRectangle(cornerRadius: 12)).accessibilityHidden(true)
                            HStack { Text(theme.title).font(.system(size: 12, weight: .medium)); Spacer(); Image(systemName: presentation.theme == theme ? "checkmark.circle.fill" : "circle").foregroundStyle(presentation.theme == theme ? palette.accent : palette.secondary) }
                        }.padding(10).background(palette.surface.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(presentation.theme == theme ? palette.accent : palette.secondary.opacity(0.2), lineWidth: presentation.theme == theme ? 2 : 1))
                    }.buttonStyle(.plain).accessibilityLabel("\(theme.title) theme").accessibilityValue(presentation.theme == theme ? "Selected" : "Not selected")
                }
            }
            Picker("Appearance", selection: $presentation.appearance) { ForEach(StillAppearance.allCases, id: \.self) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
            if presentation.theme == .glass {
                Picker("Backdrop", selection: $backdrop) { ForEach(StillBackdropStyle.allCases, id: \.self) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
            }
        }
    }
}
