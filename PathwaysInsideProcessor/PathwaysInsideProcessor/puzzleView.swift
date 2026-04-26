// puzzleView.swift
// PathwaysInsideProcessor
//
// Full MIPS single-cycle datapath puzzle.
// The canvas replicates ProcessorDatapathDiagram.svg exactly:
//   - 1317 × 737 native SVG coordinate space, scaled to fit the device.
//   - Exact component colors (#fff2cc / #d5e8d4 / #f8cecc / #e1d5e7).
//   - All wire paths taken directly from the SVG path data.
//   - Drag ● output dots → ○ input dots to connect active wires.

import SwiftUI
import Combine
import UIKit

// MARK: - Puzzle options

private struct PuzzleOption: Identifiable {
    let id: String; let title, subtitle: String; let iconColor: Color
}
private let puzzleOptions: [PuzzleOption] = [
    .init(id: "rtype",  title: "R-Type",
          subtitle: "add / sub / and / or / slt — ALU path with register write-back",
          iconColor: .blue),
    .init(id: "load",   title: "Load Word (lw)",
          subtitle: "Compute address, read Data Memory, write result to register",
          iconColor: .green),
    .init(id: "store",  title: "Store Word (sw)",
          subtitle: "Compute address, write register data to Data Memory",
          iconColor: .orange),
    .init(id: "branch", title: "Branch Equal (beq)",
          subtitle: "Compare registers; take branch when Zero flag is set",
          iconColor: .red),
]

// MARK: - Puzzle Selection

struct PuzzleSelectionView: View {
    var body: some View {
        List(puzzleOptions) { opt in
            NavigationLink(destination: StandalonePuzzleView(instrType: opt.id, title: opt.title)) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(opt.iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "cpu").foregroundColor(opt.iconColor))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(opt.title).font(.headline)
                        Text(opt.subtitle).font(.caption).foregroundColor(.secondary).lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Datapath Puzzles")
    }
}

// MARK: - Standalone Puzzle View

struct StandalonePuzzleView: View {
    let instrType: String
    let title: String

    @State private var userConnections: [Connection]       = []
    @State private var checkedResult:   [Connection: Bool] = [:]
    @State private var showResult       = false
    @State private var allCorrect       = false
    @State private var showHint         = false
    @State private var isPortrait       = false
    // Passed down to the canvas; while true the ScrollView is disabled so that
    // a drag starting on a port isn't stolen by the scroll gesture recogniser.
    @State private var isDrawingWire    = false
    @State private var scrollOffset     = CGPoint.zero
    @State private var committedZoom:   CGFloat = 1.0
    // @GestureState resets to 1.0 automatically when the pinch ends, so
    // committedZoom accumulates across multiple pinch gestures correctly.
    @GestureState private var pinchDelta: CGFloat = 1.0
    private var zoom: CGFloat { (committedZoom * pinchDelta).clamped(to: 0.4...3.0) }

    private var correct: Set<Connection> { correctConnections(for: instrType) }
    private var totalNeeded: Int         { correct.count }

    private let baseW = svgNativeWidth  * 0.9
    private let baseH = svgNativeHeight * 0.9

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                infoBar
                Divider()

                // ── Scrollable + zoomable SVG canvas with custom scrollbars ──
                GeometryReader { vp in
                    ZStack {
                        ScrollView([.horizontal, .vertical]) {
                            SVGDatapathPuzzleCanvas(
                                instrType: instrType,
                                userConnections: $userConnections,
                                checkedResult:   $checkedResult,
                                isDrawingWire:   $isDrawingWire
                            )
                            .frame(width: baseW * zoom, height: baseH * zoom)
                            .background(Color(UIColor.systemGroupedBackground))
                            .gesture(
                                MagnificationGesture()
                                    .updating($pinchDelta) { val, state, _ in state = val }
                                    .onEnded { val in
                                        committedZoom = (committedZoom * val).clamped(to: 0.4...3.0)
                                    }
                            )
                            // SwiftUI's ScrollView exposes no built-in scroll offset API.
                            // Attaching a GeometryReader inside the scroll content and reading
                            // its frame relative to the named coordinate space is the standard
                            // workaround to retrieve the current scroll position.
                            .background(GeometryReader { inner in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: CGPoint(
                                        x: -inner.frame(in: .named("datapathSV")).minX,
                                        y: -inner.frame(in: .named("datapathSV")).minY))
                            })
                        }
                        .coordinateSpace(name: "datapathSV")
                        .scrollDisabled(isDrawingWire)
                        .scrollIndicators(.never)
                        .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }

                        // Always-visible custom scrollbars overlay
                        scrollbarsOverlay(viewport: vp.size,
                                          contentW: baseW * zoom,
                                          contentH: baseH * zoom)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()
                controlBar
            }

            if isPortrait   { landscapeOverlay }
            if showResult && allCorrect { successOverlay }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(
            for: UIDevice.orientationDidChangeNotification)) { _ in updateOrientation() }
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            updateOrientation()
        }
    }

    // MARK: Info bar
    private var infoBar: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Wire all \(totalNeeded) active connections")
                    .font(.subheadline.weight(.semibold))
                Text("Drag ● output ports → ○ input ports. Tap ● to remove a wire.")
                    .font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            let drawn = userConnections.count
            ZStack {
                Circle().stroke(Color.blue.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: totalNeeded > 0 ? CGFloat(drawn) / CGFloat(totalNeeded) : 0)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(drawn)/\(totalNeeded)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal).padding(.vertical, 8)
    }

    // MARK: Control bar
    private var controlBar: some View {
        HStack(spacing: 10) {
            Button { withAnimation { showHint.toggle() } }
            label: { Label("Hint", systemImage: "lightbulb").frame(maxWidth: .infinity) }
            .buttonStyle(.bordered).tint(.orange)

            Button { userConnections = []; checkedResult = [:]; showResult = false }
            label: { Label("Reset", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity) }
            .buttonStyle(.bordered).tint(.gray)

            Button(action: checkAnswer) {
                Label("Check", systemImage: "checkmark.seal.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(userConnections.isEmpty)
        }
        .padding(.horizontal).padding(.vertical, 10)
        .overlay(alignment: .top) {
            if showHint {
                hintBanner.offset(y: -44)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            if showResult && !allCorrect {
                resultBanner.offset(y: -44)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var hintBanner: some View {
        // Reveals just one missing connection at a time — giving the full list
        // would bypass the learning intent of the puzzle.
        let missing = correct.subtracting(Set(userConnections))
        let msg = missing.first.map { "Try connecting \($0.fromPort) → \($0.toPort)" }
                  ?? "All connections drawn!"
        return Label(msg, systemImage: "lightbulb.fill")
            .font(.caption.bold()).foregroundColor(.orange)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(Capsule().fill(Color.orange.opacity(0.12))
                .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1)))
            .padding(.horizontal)
    }

    private var resultBanner: some View {
        let extra   = Set(userConnections).subtracting(correct).count
        let missing = correct.subtracting(Set(userConnections)).count
        let msg = "\(extra) wrong, \(missing) missing — keep trying!"
        return Label(msg, systemImage: "xmark.circle.fill")
            .font(.caption.bold()).foregroundColor(.red)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(Capsule().fill(Color.red.opacity(0.10))
                .overlay(Capsule().stroke(Color.red.opacity(0.4), lineWidth: 1)))
            .padding(.horizontal)
    }

    private var landscapeOverlay: some View {
        VStack(spacing: 14) {
            Image(systemName: "rotate.right").font(.system(size: 52)).foregroundColor(.white)
            Text("Rotate to Landscape").font(.title3.bold()).foregroundColor(.white)
            Text("The full MIPS datapath puzzle is designed for landscape view.")
                .font(.subheadline).foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center).padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.72)).ignoresSafeArea()
    }

    private var successOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64)).foregroundColor(.green)
            Text("All Wires Correct!").font(.title.bold())
            Text("You successfully wired the \(title) datapath.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            Button("Play Again") { userConnections = []; checkedResult = [:]; showResult = false }
                .buttonStyle(.borderedProminent).tint(.green)
        }
        .padding(32)
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(Color(UIColor.systemBackground)).shadow(radius: 20))
        .padding(32)
        .transition(.scale.combined(with: .opacity))
    }

    private func checkAnswer() {
        let user = Set(userConnections)
        checkedResult = Dictionary(uniqueKeysWithValues: userConnections.map { ($0, correct.contains($0)) })
        allCorrect = user == correct
        withAnimation(.spring()) { showResult = true }
        if showHint { showHint = false }
    }

    private func updateOrientation() {
        let o = UIDevice.current.orientation
        isPortrait = o == .portrait || o == .portraitUpsideDown
    }

    /// Draws always-visible horizontal + vertical scrollbar tracks and thumbs.
    @ViewBuilder
    private func scrollbarsOverlay(viewport: CGSize,
                                   contentW: CGFloat,
                                   contentH: CGFloat) -> some View {
        let barW: CGFloat  = 10          // scrollbar thickness
        let minThumb: CGFloat = 44       // minimum thumb length (easy to see)
        let trackColor = Color.black.opacity(0.08)
        let thumbColor = Color.gray.opacity(0.55)
        let corner: CGFloat = barW / 2

        ZStack(alignment: .topLeading) {
            // ── Vertical scrollbar (right edge) ───────────────────────────
            if contentH > viewport.height {
                let trackH   = viewport.height - barW   // leave corner gap
                let thumbH   = max(minThumb, trackH * viewport.height / contentH)
                let maxTravel = trackH - thumbH
                let thumbY   = maxTravel * min(1, scrollOffset.y / max(1, contentH - viewport.height))

                // Track
                RoundedRectangle(cornerRadius: corner)
                    .fill(trackColor)
                    .frame(width: barW, height: trackH)
                    .position(x: viewport.width - barW / 2, y: trackH / 2)

                // Thumb
                RoundedRectangle(cornerRadius: corner)
                    .fill(thumbColor)
                    .frame(width: barW, height: thumbH)
                    .position(x: viewport.width - barW / 2,
                              y: thumbH / 2 + thumbY)
            }

            // ── Horizontal scrollbar (bottom edge) ────────────────────────
            if contentW > viewport.width {
                let trackW   = viewport.width - barW
                let thumbW   = max(minThumb, trackW * viewport.width / contentW)
                let maxTravel = trackW - thumbW
                let thumbX   = maxTravel * min(1, scrollOffset.x / max(1, contentW - viewport.width))

                // Track
                RoundedRectangle(cornerRadius: corner)
                    .fill(trackColor)
                    .frame(width: trackW, height: barW)
                    .position(x: trackW / 2, y: viewport.height - barW / 2)

                // Thumb
                RoundedRectangle(cornerRadius: corner)
                    .fill(thumbColor)
                    .frame(width: thumbW, height: barW)
                    .position(x: thumbW / 2 + thumbX,
                              y: viewport.height - barW / 2)
            }
        }
        .frame(width: viewport.width, height: viewport.height)
        .allowsHitTesting(false)
    }
}

// MARK: - Scroll offset tracking

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - SVG Datapath Puzzle Canvas

/// Renders the MIPS datapath exactly as in ProcessorDatapathDiagram.svg and
/// handles drag-to-connect puzzle interaction.
private struct SVGDatapathPuzzleCanvas: View {
    let instrType: String
    @Binding var userConnections: [Connection]
    @Binding var checkedResult:   [Connection: Bool]
    @Binding var isDrawingWire:   Bool

    /// Extra distractor port IDs — identical appearance to real ports so the user
    /// cannot tell them apart visually. Set by PuzzleView (quiz mode only).
    var extraOutputIds: Set<String> = []
    var extraInputIds:  Set<String> = []
    /// When true (after Submit), all wire drawing is locked.
    var isLocked: Bool = false

    @State private var dragFromPortId: String? = nil
    @State private var dragLocation:   CGPoint = .zero
    @State private var isDragging      = false

    private let portDotR:   CGFloat = 9
    // 36 pt snap radius is large enough to be comfortable on a small device
    // screen without overlapping adjacent port dots.
    private let snapRadius: CGFloat = 36

    // Active port sets for this instruction type
    private var activeWireSet: Set<String> { activeWireIds[instrType] ?? [] }
    private var activeOutputIds: Set<String> {
        Set(activeWireSet.compactMap { wireById[$0]?.from })
    }
    private var activeInputIds: Set<String> {
        Set(activeWireSet.compactMap { wireById[$0]?.to })
    }

    // Merges real ports with distractor ports so both are rendered identically.
    // The student cannot tell them apart visually — that's the point of distractors.
    private var allVisibleOutputIds: Set<String> { activeOutputIds.union(extraOutputIds) }
    private var allVisibleInputIds:  Set<String> { activeInputIds.union(extraInputIds) }

    private var drawnFromPorts: Set<String> { Set(userConnections.map { $0.fromPort }) }
    private var drawnToPorts:   Set<String> { Set(userConnections.map { $0.toPort  }) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let sx = size.width  / svgNativeWidth
            let sy = size.height / svgNativeHeight

            ZStack {
                // ── 1. Static background (Canvas API) ─────────────────────
                // Canvas is used instead of individual SwiftUI shapes because
                // it batches all wire and component draws into a single render
                // pass — much faster than laying out ~40 separate Path views.
                Canvas { ctx, sz in
                    drawStaticBackground(ctx: ctx, size: sz)
                }
                .allowsHitTesting(false)  // background never needs touch events

                // ── 2. User-drawn connections ──────────────────────────────
                ForEach(userConnections, id: \.self) { conn in
                    userWirePath(conn: conn, size: size)
                        .stroke(userWireColor(conn),
                                style: StrokeStyle(lineWidth: 2.5,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .allowsHitTesting(false)
                }

                // ── 3. Live drag feedback ──────────────────────────────────
                if isDragging, let fid = dragFromPortId, let fp = portById[fid] {
                    Path { p in
                        p.move(to: CGPoint(x: fp.px * sx, y: fp.py * sy))
                        p.addLine(to: dragLocation)
                    }
                    .stroke(Color.accentColor.opacity(0.6),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 3]))
                    .allowsHitTesting(false)
                }

                // ── 4. Output port dots (draggable / tappable) ────────────
                // Colour shifts to red once a wire is drawn from this port.
                // Tapping a connected output dot removes its wire (no separate delete UI needed).
                // Distractors use the same orange — indistinguishable from real ports.
                ForEach(Array(allVisibleOutputIds), id: \.self) { pid in
                    if let p = portById[pid] {
                        let connected = drawnFromPorts.contains(pid)
                        Circle()
                            .fill(connected ? Color.red : Color.orange)
                            .frame(width: portDotR * 2, height: portDotR * 2)
                            .position(x: p.px * sx, y: p.py * sy)
                            .onTapGesture {
                                guard !isLocked else { return }
                                userConnections.removeAll { $0.fromPort == pid }
                                checkedResult = [:]
                            }
                    }
                }

                // ── 5. Input port dots (drop targets) ─────────────────────
                // Input dots are not hit-testable: they are pure visual feedback.
                // The DragGesture below handles snapping to the nearest input port.
                // Distractors use the same white/blue — indistinguishable from real ports.
                ForEach(Array(allVisibleInputIds), id: \.self) { pid in
                    if let p = portById[pid] {
                        let connected = drawnToPorts.contains(pid)
                        Circle()
                            .fill(connected ? Color.green.opacity(0.35) : Color.white)
                            .overlay(Circle().stroke(
                                connected ? Color.green : Color.blue,
                                lineWidth: 1.5))
                            .frame(width: portDotR * 2, height: portDotR * 2)
                            .position(x: p.px * sx, y: p.py * sy)
                            .allowsHitTesting(false)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { val in
                        guard !isLocked else { return }
                        if !isDragging {
                            // On first movement, check whether the drag started
                            // near an output port. If not, let the scroll view
                            // handle this gesture instead.
                            if let pid = snapPort(to: val.startLocation,
                                                  ports: allVisibleOutputIds,
                                                  sx: sx, sy: sy) {
                                dragFromPortId = pid
                                isDragging     = true
                                isDrawingWire  = true  // disables scroll in parent
                            }
                        }
                        if isDragging { dragLocation = val.location }
                    }
                    .onEnded { val in
                        // Always clear drag state — even if no connection is made.
                        defer {
                            dragFromPortId = nil
                            isDragging     = false
                            isDrawingWire  = false
                        }
                        guard !isLocked, isDragging, let fromId = dragFromPortId else { return }
                        guard let toId = snapPort(to: val.location,
                                                  ports: allVisibleInputIds,
                                                  sx: sx, sy: sy),
                              toId != fromId else { return }  // guard against connecting a port to itself
                        let fp = portById[fromId]!
                        let tp = portById[toId]!
                        let conn = Connection(fromComponent: fp.compId, fromPort: fromId,
                                             toComponent:   tp.compId, toPort:   toId)
                        // Prevent duplicate connections from the same output port.
                        if !userConnections.contains(conn) {
                            userConnections.append(conn)
                        }
                    }
            )
        }
    }

    // MARK: - Canvas background drawing

    private func drawStaticBackground(ctx: GraphicsContext, size: CGSize) {
        let sx = size.width  / svgNativeWidth
        let sy = size.height / svgNativeHeight

        // Wires drawn first so component rectangles paint on top of them.
        for wire in allWires {
            guard wire.pts.count >= 2 else { continue }
            var path = Path()
            path.move(to: scaledPt(wire.pts[0], sx, sy))
            for pt in wire.pts.dropFirst() { path.addLine(to: scaledPt(pt, sx, sy)) }
            // Control wires are rendered at lower opacity so data wires stand out.
            let col = wire.isControl
                ? Color.orange.opacity(0.30)
                : Color.black.opacity(0.35)
            ctx.stroke(path, with: .color(col),
                       style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
        }

        // Component rectangles and their labels
        for comp in allComponents {
            let rect = CGRect(x: comp.svgX * sx, y: comp.svgY * sy,
                              width: comp.w * sx, height: comp.h * sy)
            ctx.fill(Path(rect), with: .color(comp.fillColor))
            ctx.stroke(Path(rect), with: .color(comp.strokeColor), lineWidth: 1.2)

            // Font size scales with the component box height; clamped so tiny
            // boxes (e.g. PC) stay readable and large boxes don't look oversized.
            let fontSize = max(9, min(13, comp.h * sy * 0.22))
            let font = Font.system(size: fontSize, weight: .semibold)
            let lines = comp.label.split(separator: "\n", omittingEmptySubsequences: true)
            let lineH  = fontSize * 1.25
            let totalH = lineH * CGFloat(lines.count)
            let startY = comp.cy * sy - totalH / 2 + lineH * 0.5
            for (i, line) in lines.enumerated() {
                let txt = Text(String(line)).font(font).foregroundColor(.black)
                ctx.draw(txt, at: CGPoint(x: comp.cx * sx, y: startY + lineH * CGFloat(i)))
            }
        }
    }

    // MARK: - User wire rendering

    private func userWirePath(conn: Connection, size: CGSize) -> Path {
        let sx = size.width  / svgNativeWidth
        let sy = size.height / svgNativeHeight
        guard let fp = portById[conn.fromPort], let tp = portById[conn.toPort] else {
            return Path()
        }
        // Prefer the exact SVG waypoint path so the user-drawn wire overlays the
        // background wire precisely. Falls back to a straight line for distractor
        // connections that have no matching SVG wire definition.
        if let wire = wireById.values.first(where: {
            $0.from == conn.fromPort && $0.to == conn.toPort }) {
            return wirePath(for: wire, scaledTo: size)
        }
        return Path { p in
            p.move(to: CGPoint(x: fp.px * sx, y: fp.py * sy))
            p.addLine(to: CGPoint(x: tp.px * sx, y: tp.py * sy))
        }
    }

    private func userWireColor(_ conn: Connection) -> Color {
        // After "Check" the result dict is populated; before it, wires are blue.
        if let checked = checkedResult[conn] { return checked ? .green : .red }
        return .blue
    }

    // MARK: - Snap helper

    // Returns the nearest port within snapRadius, or nil if none qualifies.
    // Using hypot (Euclidean distance) rather than a bounding-box check avoids
    // accidentally snapping to ports that are close on one axis but far on the other.
    private func snapPort(to pt: CGPoint, ports: Set<String>,
                          sx: CGFloat, sy: CGFloat) -> String? {
        var best: (id: String, dist: CGFloat) = ("", .infinity)
        for pid in ports {
            guard let p = portById[pid] else { continue }
            let d = hypot(p.px * sx - pt.x, p.py * sy - pt.y)
            if d < snapRadius && d < best.dist { best = (pid, d) }
        }
        return best.id.isEmpty ? nil : best.id
    }

    private func scaledPt(_ pt: CGPoint, _ sx: CGFloat, _ sy: CGFloat) -> CGPoint {
        CGPoint(x: pt.x * sx, y: pt.y * sy)
    }
}

// MARK: - Quiz-integrated PuzzleView

struct PuzzleView: View {
    @ObservedObject var manager: QuizManager
    let puzzle: Puzzle

    @State private var userConnections:  [Connection]       = []
    @State private var checkedResult:    [Connection: Bool] = [:]
    @State private var showResult        = false
    // Once Submit is tapped the canvas is locked — no rewiring or second attempts.
    @State private var isLocked          = false
    @State private var isDrawingWire     = false
    @State private var committedZoom:    CGFloat = 1.0
    @GestureState private var pinchDelta: CGFloat = 1.0
    // Distractor ports injected at appear-time; absent in standalone puzzle mode.
    @State private var extraOutputIds:   Set<String> = []
    @State private var extraInputIds:    Set<String> = []

    private var zoom: CGFloat { (committedZoom * pinchDelta).clamped(to: 0.4...3.0) }

    private let baseW = svgNativeWidth  * 0.9
    private let baseH = svgNativeHeight * 0.9
    private var correct: Set<Connection> { correctConnections(for: puzzle.id) }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(puzzle.instructionType).font(.headline)
                Text(puzzle.description).font(.caption).foregroundColor(.secondary)
                if !puzzle.hint.isEmpty {
                    Label(puzzle.hint, systemImage: "lightbulb")
                        .font(.caption2).foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Text("Drag ● output ports → ○ input ports. Tap ● to remove a wire.")
                .font(.caption2).foregroundColor(.secondary).padding(.horizontal)
            Divider().padding(.top, 4)

            // Scrollable + zoomable SVG canvas
            ScrollView([.horizontal, .vertical]) {
                SVGDatapathPuzzleCanvas(
                    instrType:       puzzle.id,
                    userConnections: $userConnections,
                    checkedResult:   $checkedResult,
                    isDrawingWire:   $isDrawingWire,
                    extraOutputIds:  extraOutputIds,
                    extraInputIds:   extraInputIds,
                    isLocked:        isLocked
                )
                .frame(width: baseW * zoom, height: baseH * zoom)
                .background(Color(UIColor.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .gesture(
                    MagnificationGesture()
                        .updating($pinchDelta) { val, state, _ in state = val }
                        .onEnded { val in
                            committedZoom = (committedZoom * val).clamped(to: 0.4...3.0)
                        }
                )
            }
            .scrollDisabled(isDrawingWire)
            .scrollIndicators(.visible)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)   // fills all remaining vertical space
            .padding(.horizontal, 12).padding(.top, 8)

            // Result banner (shown after submit, above the button)
            if showResult {
                let ok = Set(userConnections) == correct
                HStack(spacing: 6) {
                    Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(ok ? "All correct connections made!" : "Submitted — review at results.")
                }
                .font(.caption.bold())
                .foregroundColor(ok ? .green : .red)
                .padding(.vertical, 6)
            }

            // One-try only: Submit locks immediately, no Reset or re-check.
            // The manager stores connections live (onChange below) so the results
            // screen always has the most recent state even if Submit wasn't tapped.
            Divider()
            Button {
                checkedResult = Dictionary(uniqueKeysWithValues:
                    userConnections.map { ($0, correct.contains($0)) })
                withAnimation { showResult = true }
                isLocked = true
                manager.submitPuzzleAnswer(connections: userConnections)
            } label: {
                Label("Submit", systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .disabled(userConnections.isEmpty || isLocked)
            .padding()
        }
        .onAppear { generateDistractors() }
        // Persist every intermediate state so navigating away and back preserves work.
        .onChange(of: userConnections) { _, newVal in manager.submitPuzzleAnswer(connections: newVal) }
    }

    // MARK: - Distractor generation

    /// Exposes every data-path port not already active as a distractor.
    /// Ports that appear exclusively in control wires (Control Unit outputs, ALU Control,
    /// AND gate output, PCSrc MUX select) are never shown — students should not wire
    /// control signals in the puzzle.
    private func generateDistractors() {
        let activeWires = activeWireIds[puzzle.id] ?? []
        let activeOuts  = Set(activeWires.compactMap { wireById[$0]?.from })
        let activeIns   = Set(activeWires.compactMap { wireById[$0]?.to })

        // Compute which ports appear ONLY in control wires — these are excluded entirely.
        let controlWirePorts = Set(allWires.filter {  $0.isControl }.flatMap { [$0.from, $0.to] })
        let dataWirePorts    = Set(allWires.filter { !$0.isControl }.flatMap { [$0.from, $0.to] })
        let controlOnlyPorts = controlWirePorts.subtracting(dataWirePorts)

        extraOutputIds = Set(allPorts.filter {
            $0.isOutput && !activeOuts.contains($0.id) && !controlOnlyPorts.contains($0.id)
        }.map { $0.id })
        extraInputIds = Set(allPorts.filter {
            !$0.isOutput && !activeIns.contains($0.id) && !controlOnlyPorts.contains($0.id)
        }.map { $0.id })
    }
}

// MARK: - Helpers

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Previews

#Preview("Puzzle Selection") { NavigationStack { PuzzleSelectionView() } }
#Preview("R-Type Puzzle")    { NavigationStack { StandalonePuzzleView(instrType: "rtype",  title: "R-Type") } }
#Preview("Load Puzzle")      { NavigationStack { StandalonePuzzleView(instrType: "load",   title: "Load Word") } }
#Preview("Branch Puzzle")    { NavigationStack { StandalonePuzzleView(instrType: "branch", title: "Branch Equal") } }
