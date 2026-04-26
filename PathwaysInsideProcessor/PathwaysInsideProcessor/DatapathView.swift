// DatapathView.swift
// PathwaysInsideProcessor
//
// Explore screen — lets students see which datapath components are active
// for each instruction type, with annotated explanation bubbles and a
// link to a per-instruction detail page.

import SwiftUI

struct DatapathView: View {
    enum InstructionType: String, CaseIterable {
        case load   = "Load"
        case store  = "Store"
        case alu    = "ALU"
        case branch = "Branch"
    }

    struct DatapathExplanation: Identifiable {
        let id = UUID()
        let text: String
        // Fractional position (0–1) relative to the diagram's rendered size
        let position: CGPoint
    }

    @State private var selectedInstruction: InstructionType? = nil
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var showExplanations: Bool = false

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .navigationTitle("Processor Datapath")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Portrait: stacked vertically — less ideal for a wide diagram but still supported
    var portraitLayout: some View {
        VStack {
            instructionMenu
            zoomableDiagram
            exploreButton
        }
    }

    // Landscape: side-by-side — more comfortable for displaying the full processor diagram
    var landscapeLayout: some View {
        HStack {
            instructionMenu
                .frame(width: 150)
            zoomableDiagram
            exploreButton
                .frame(width: 240)
        }
    }

    var instructionMenu: some View {
        VStack(spacing: 12) {
            ForEach(InstructionType.allCases, id: \.self) { type in
                Button(action: {
                    selectedInstruction = type
                    showExplanations = false
                    withAnimation {
                        scale = 1.0
                        offset = .zero
                    }
                }) {
                    Text(type.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedInstruction == type ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedInstruction == type ? .white : .primary)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    var zoomableDiagram: some View {
        ZStack {
            // Base full-datapath image — dimmed when an instruction is selected
            Image("datapath_full")
                .resizable()
                .scaledToFit()
                .opacity(selectedInstruction == nil ? 1.0 : 0.3)

            // Highlight overlay showing the active path for the selected instruction
            if let instruction = selectedInstruction {
                Image(imageName(for: instruction))
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)
            }

            // Explanation bubbles, staggered in when Explore is tapped
            if let instruction = selectedInstruction, showExplanations {
                GeometryReader { geo in
                    ForEach(Array(explanations(for: instruction).enumerated()), id: \.element.id) { index, item in
                        ExplanationBubble(text: item.text)
                            .position(
                                x: item.position.x * geo.size.width,
                                y: item.position.y * geo.size.height
                            )
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeIn.delay(Double(index) * 0.15), value: showExplanations)
                    }
                }
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .gesture(
            MagnificationGesture()
                .onChanged { value in scale = value }
        )
        .gesture(
            DragGesture()
                .onChanged { value in offset = value.translation }
        )
        // Double-tap resets zoom and pan
        .onTapGesture(count: 2) {
            withAnimation {
                scale = 1.0
                offset = .zero
            }
        }
        .padding()
    }

    // Appears once an instruction type is selected — toggles explanation bubbles
    // and links to the per-instruction detail page.
    var exploreButton: some View {
        VStack(spacing: 12) {
            if selectedInstruction != nil {
                Button(action: {
                    withAnimation { showExplanations.toggle() }
                }) {
                    Text(showExplanations ? "Hide Explanations" : "Explore")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                if let instruction = selectedInstruction {
                    NavigationLink(destination: DatapathDetailView(instruction: instruction)) {
                        Text("Open Detailed Page")
                            .font(.subheadline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
    }

    func imageName(for instruction: InstructionType) -> String {
        switch instruction {
        case .load:   return "highlight_load"
        case .store:  return "highlight_store"
        case .alu:    return "highlight_alu"
        case .branch: return "highlight_branch"
        }
    }

    func explanations(for instruction: InstructionType) -> [DatapathExplanation] {
        switch instruction {
        case .load:
            return [
                DatapathExplanation(text: "ALU computes the effective memory address (base + offset).", position: CGPoint(x: 0.55, y: 0.55)),
                DatapathExplanation(text: "Data Memory is read using that address.", position: CGPoint(x: 0.75, y: 0.45)),
                DatapathExplanation(text: "Loaded value is written back into the Register File.", position: CGPoint(x: 0.3, y: 0.6))
            ]
        case .store:
            return [
                DatapathExplanation(text: "ALU computes the address where data will be stored.", position: CGPoint(x: 0.55, y: 0.55)),
                DatapathExplanation(text: "Register File provides the value to write.", position: CGPoint(x: 0.3, y: 0.6)),
                DatapathExplanation(text: "Data Memory writes the value at the computed address.", position: CGPoint(x: 0.75, y: 0.45))
            ]
        case .alu:
            return [
                DatapathExplanation(text: "Register operands are read from the Register File.", position: CGPoint(x: 0.3, y: 0.6)),
                DatapathExplanation(text: "ALU performs the arithmetic or logic operation.", position: CGPoint(x: 0.55, y: 0.55)),
                DatapathExplanation(text: "Result is written back to the destination register.", position: CGPoint(x: 0.35, y: 0.45))
            ]
        case .branch:
            return [
                DatapathExplanation(text: "Registers are compared in the ALU (subtract, check Zero flag).", position: CGPoint(x: 0.55, y: 0.55)),
                DatapathExplanation(text: "Immediate is sign-extended and shifted to compute branch target.", position: CGPoint(x: 0.6, y: 0.35)),
                DatapathExplanation(text: "PC is updated conditionally to the branch target.", position: CGPoint(x: 0.2, y: 0.3))
            ]
        }
    }
}

// MARK: - Explanation Bubble

struct ExplanationBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}

// MARK: - Detail View

struct DatapathDetailView: View {
    var instruction: DatapathView.InstructionType

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(instruction.rawValue) Datapath")
                    .font(.largeTitle.bold())

                Text(explanation)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle(instruction.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    var explanation: String {
        switch instruction {
        case .load:
            return "Uses memory and registers to load data into the CPU."
        case .store:
            return "Writes data from registers into memory."
        case .alu:
            return "Performs arithmetic and logical operations."
        case .branch:
            return "Controls program flow based on conditions."
        }
    }
}

#Preview {
    NavigationStack { DatapathView() }
}
