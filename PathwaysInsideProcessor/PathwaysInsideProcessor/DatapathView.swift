// This will be the screen where the users can see the entire processor datapath
// The image will be right aligned
// There will be buttons on the left side to see the basic instruction types that we covered in class
// These buttons will include "Load" "Store" "ALU" "Branch" "None"
// clicking on a button will "highlight" the datapath (changing images would be the easiest approach, but if we really wanted to an overlay type of highlight could work too)
// after selecting an instruction, a button will appear below the diagram sasying "Explore {InstructionType} Datapath"
// that will take you to a different screen that explains why the instruction uses each component that it interacts with. 

import SwiftUI

struct DatapathView: View {
  enum InstructionType: String, CaseIterable {
    case load = "Load"
    case store = "Store"
    case alu = "ALU" 
    case branch = "Branch"
  }

  struct DatapathExplanation: Identifiable {
    let id = UUID()
    let text: String
    let componentId: String
  }

  @State private var selectedInstruction : InstructionType? = nil
  @State private var scale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var selectedComponent: String? = nil

  var body: some View {
    GeometryReader { geo in
      if geo.size.width > geo.size.height {
        landscapeLayout
      } else {
        portraitLayout
      }
    }
    .navigationTitle("Processor Datapath")
  }

  // Portrait View
  // it isn't ideal for displaying the whole processor datapath
  // but it is the default view that users prefer, so it ought to be supported
  var portraitLayout: some View {
    VStack {
      instructionMenu
      zoomableDiagram
      exploreButton
    }
  }

  // Landscape View
  // this is more ideal because it means we can more comfortably display all the processor stuff
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
          selectedComponent = nil
          withAnimation {
            scale = 1.2
            offset = .zero
          }
        }) {
          Text(type.rawValue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedInstruction == type ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      }
    }
    .padding()
  }

var zoomableDiagram: some View {
    ZStack {
        GeometryReader { geo in
            let instrKey       = selectedInstruction.map { instructionKey($0) }
            let activeComps: Set<String>  = instrKey.map { activeComponentIds(instrType: $0) } ?? []
            let activeWireSet: Set<String> = instrKey.flatMap { activeWireIds[$0] } ?? []

            // Wires — drawn on a Canvas so no SwiftUI view overhead per path
            Canvas { ctx, size in
                for wire in allWires {
                    let path = wirePath(for: wire, scaledTo: size)
                    let isActive = activeWireSet.contains(wire.id)
                    let color: Color
                    if selectedInstruction == nil {
                        color = wire.isControl ? .gray.opacity(0.3) : .gray.opacity(0.45)
                    } else if wire.isControl {
                        color = .gray.opacity(0.2)
                    } else if isActive {
                        color = .blue.opacity(0.8)
                    } else {
                        color = .gray.opacity(0.12)
                    }
                    ctx.stroke(path, with: .color(color), lineWidth: isActive ? 2.5 : 1.0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Components — SwiftUI views so taps work
            ForEach(allComponents) { comp in
                let isActive   = activeComps.contains(comp.id)
                let isSelected = selectedComponent == comp.id
                let cx  = comp.cx * geo.size.width  / svgNativeWidth
                let cy  = comp.cy * geo.size.height / svgNativeHeight
                let w   = comp.w  * geo.size.width  / svgNativeWidth
                let h   = comp.h  * geo.size.height / svgNativeHeight
                let labelSize = min(w * 0.24, h * 0.30, 11.0)

                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            selectedInstruction == nil
                                ? comp.fillColor
                                : (isActive ? Color.yellow.opacity(0.45) : comp.fillColor.opacity(0.3))
                        )
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(
                            isSelected ? Color.orange :
                            (isActive  ? comp.strokeColor : comp.strokeColor.opacity(0.3)),
                            lineWidth: isSelected ? 3 : (isActive ? 1.5 : 1)
                        )
                    Text(comp.label)
                        .font(.system(size: labelSize, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            .black.opacity(selectedInstruction == nil || isActive ? 0.85 : 0.3)
                        )
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .padding(2)
                }
                .frame(width: w, height: h)
                // contentShape has to come before position — if you put it after,
                // SwiftUI uses the un-moved layout bounds and every tap lands on the
                // last component in the array (branch_mux) no matter what you tap
                .contentShape(Rectangle())
                .position(x: cx, y: cy)
                .onTapGesture {
                    guard isActive else { return }
                    withAnimation { selectedComponent = isSelected ? nil : comp.id }
                }
            }
        }

        // Explanation bubble
        if let instruction = selectedInstruction,
           let selComp = selectedComponent {
            GeometryReader { geo in
                let items = explanations(for: instruction).filter { $0.componentId == selComp }
                if let comp = compById[selComp], let item = items.first {
                    let point        = scalePoint(CGPoint(x: comp.cx, y: comp.cy), to: geo.size)
                    // figure out how tall this component is on screen so the bubble
                    // clears the component edge instead of sitting on top of it
                    let scaledHalfH  = (comp.h / 2) * geo.size.height / svgNativeHeight
                    // top-half components push the bubble downward (toward screen center),
                    // bottom-half components push it upward — keeps it visible either way
                    let yOffset: CGFloat = comp.cy < svgNativeHeight / 2
                        ? scaledHalfH + 55
                        : -(scaledHalfH + 55)
                    // clamp so the bubble never slides off the left/right/top/bottom edges
                    let clampedX = min(max(point.x, 115), geo.size.width  - 115)
                    let clampedY = min(max(point.y + yOffset, 60), geo.size.height - 60)
                    ExplanationBubble(text: item.text)
                        .frame(maxWidth: 220)
                        .position(x: clampedX, y: clampedY)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    .scaleEffect(scale)
    .offset(offset)
    .simultaneousGesture(
        MagnificationGesture()
            .onChanged { value in scale = value }
    )
    .simultaneousGesture(
        DragGesture()
            .onChanged { value in offset = value.translation }
    )
    .onTapGesture(count: 2) {
        withAnimation { scale = 1.0; offset = .zero }
    }
    .padding()
}

  // this is the explore button
  // the point of this page as a whole is for users to visually see the instruction on the datapath as a whole
  // the explore button is meant to allow users to dig into specific instruction types and learn about their specifics. 

  var exploreButton: some View {
    VStack(spacing: 12) {
      if let instruction = selectedInstruction {
        Text("Tap a highlighted component to explore")
          .font(.subheadline)
          .foregroundColor(.gray)
        if let instruction = selectedInstruction { 
          NavigationLink(destination: DetailView(instruction: instruction)) {
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

  func instructionKey(_ type: InstructionType) -> String {
    switch type {
      case .load: return "load"
      case .store: return "store"
      case .alu: return "rtype"
      case .branch: return "branch"
    }
  }

  func explanations(for instruction: InstructionType) -> [DatapathExplanation] {
    switch instruction {
    case .load:
      return [
          DatapathExplanation(text: "Base register is read from the register file. Loaded value is written back to the register file.", componentId: "registers"),
          DatapathExplanation(text: "Immediate offset is sign-extended to 32 bits.", componentId: "sign_extend"),
          DatapathExplanation(text: "ALU adds base register and offset to compute memory address.", componentId: "alu"),
          DatapathExplanation(text: "Data memory reads the value at the computed address.", componentId: "data_memory"),
          DatapathExplanation(text: "MUX selects memory output instead of ALU result.", componentId: "wb_mux")
      ]
    case .store:
        return [
            DatapathExplanation(text: "Base register provides memory address base. Second register provides the value to store.", componentId: "registers"),
            DatapathExplanation(text: "Immediate offset is sign-extended.", componentId: "sign_extend"),
            DatapathExplanation(text: "ALU computes target memory address.", componentId: "alu"),
            DatapathExplanation(text: "Data memory writes the value to memory.", componentId: "data_memory")
        ]
    case .alu:
        return [
            DatapathExplanation(text: "Two operands are read from the register file. Result is written back into destination register.", componentId: "registers"),
            DatapathExplanation(text: "Control unit determines ALU operation.", componentId: "alu_control"),
            DatapathExplanation(text: "ALU performs arithmetic or logical computation.", componentId: "alu"),
            DatapathExplanation(text: "Result is selected by write-back MUX.", componentId: "wb_mux"),
        ]
    case .branch:
        return [
            DatapathExplanation(text: "Registers provide values to compare.", componentId: "registers"),
            DatapathExplanation(text: "ALU subtracts values to check if equal (Zero flag).", componentId: "alu"),
            DatapathExplanation(text: "Immediate is sign-extended.", componentId: "sign_extend"),
            DatapathExplanation(text: "Offset is shifted left to form word address.", componentId: "shift_left2"),
            DatapathExplanation(text: "Branch target address is computed.", componentId: "branch_adder"),
            DatapathExplanation(text: "Branch decision uses Zero AND Branch signal.", componentId: "and_gate"),
            DatapathExplanation(text: "MUX selects next PC (branch or sequential).", componentId: "branch_mux")
        ]
    }
  }
}

struct ExplanationBubble: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.caption)
      // without this, multi-sentence explanations left-align and look weird in a bubble
      .multilineTextAlignment(.center)
      .padding(10)
      .background(Color.white)
      .cornerRadius(10)
      .shadow(radius: 4)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.blue, lineWidth: 1.5)
      )
  }
}

struct DetailView: View {
  var instruction: DatapathView.InstructionType

  var body: some View { 
    ScrollView { 
      VStack(alignment: .leading, spacing:16) {
        Text("\(instruction.rawValue) Datapath")
          .font(.largeTitle)
          .bold()

        Text(explanation)
      }
      .padding()
    }
    .navigationTitle(instruction.rawValue)
  }

  var explanation: String{
    switch instruction {
    case .load:
      return "Uses memory and registers to load data into the CPU."
    case .store:
      return "Writes data from registers into memory."
    case .alu:
      return "Performs arithmetic and lgoical oeprations."
    case .branch:
      return "Controls program flow based on conditions."
    }
  }
}

struct DatapathView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DatapathView()
    }
  }
}

