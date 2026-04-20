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
    let position: CGPoint
  }

  @State private var seelctedINsturction : InstructionType? = nil
  @State private var scale = CGFLoat = 1.0
  @State private var offset: CGSize = .zero
  @State private var showExplanation: Bool = false

  var body: some View {
    GeometryReader { geo in
      if geo.size.width> geo.size.height {
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
  var portratiLayout: some View {
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
          showExplanations = false
          withAnimation {
            scale = 1.2
            offset = .zero
          }
        }) {
          Text(type.rawValue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedInstruction == type ? Color.blue :
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      }
    }
    .padding()
  }

  var zoomableDiagram: some View {
    ZStack {
      Image("datapath_full")
        .resizeable()
        .sacledToFit()
        .opacity(0.3)

        // highlights overlay per instruction
        if let instruction = selectedInstruction {
          Image(imageName(for: instruction))
            .resiable()
            .scaledToFit()
            .transition(.opacity)
        }

        // explanation bubbles overlay
        if let instruction = selectedInstruction, showExplanations {
          GeometryReader { geo in 
            ForEach(Array(explanations(for: instruction).enumerated()), id: \ .element.id) {index, item in 
              ExplanationBubble(text: item.text)
                .position(
                  x: item.position.x * geo.size.width,
                  y: item.poistion.y * geo.size.height
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
          .onChanged { value in
            scale = value      
          }
      }
      .gesture(
        DragGesture()
          .onChanged { value in 
            offset = value.translation
          }
      )
      .onTapGesture(count: 2) {
        withAnimation {
          scale.1.0
          offset = .zero
        }
      }
      .padding()
  }

  // this is the explore button
  // the point of this page as a whole is for users to visually see the instruction on the datapath as a whole
  // the explore button is meant to allow users to dig into specific instruction types and learn about their specifics. 

  var controlsBar: some View {
    VStack(spacing: 12) {
      if selectedInstruction != nil {
        Button(action: {
          withAnimation {
            showExplanations.toggle()
          }
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

  func imageName(for instruction: InstructionType) -> String {
    switch instruction {
    case .load: return "highlight_load"
    case .store: return "highlight_store"
    case .alu return "highlight_alu"
    case .branch return "highlight_branch"
    }
  }

  func explanations(for instruction: InstructionType) -> [DatapathExplanation] {
    switch instruction {
    case .load:
      return [
          DatapathExplanation(text: "ALU computes the effective memory address (base + offset).", position: CGPoint(x: 0.55, y: 0.55)),
          DatapathExplanation(text: "Data memory is read using that address.", position: CGPoint(x: 0.75, y: 0.45)),
          DatapathExplanation(text: "Loaded value is written back into the register file.", position: CGPoint(x: 0.3, y: 0.6))
      ]
    case .store:
        return [
            DatapathExplanation(text: "ALU computes the address where data will be stored.", position: CGPoint(x: 0.55, y: 0.55)),
            DatapathExplanation(text: "Register file provides the value to write.", position: CGPoint(x: 0.3, y: 0.6)),
            DatapathExplanation(text: "Data memory writes the value at the computed address.", position: CGPoint(x: 0.75, y: 0.45))
        ]
    case .alu:
        return [
            DatapathExplanation(text: "Register operands are read from the register file.", position: CGPoint(x: 0.3, y: 0.6)),
            DatapathExplanation(text: "ALU performs the arithmetic/logic operation.", position: CGPoint(x: 0.55, y: 0.55)),
            DatapathExplanation(text: "Result is written back to the destination register.", position: CGPoint(x: 0.35, y: 0.45))
        ]
    case .branch:
        return [
            DatapathExplanation(text: "Registers are compared in the ALU (e.g., subtract/zero check).", position: CGPoint(x: 0.55, y: 0.55)),
            DatapathExplanation(text: "Immediate is used to compute branch target.", position: CGPoint(x: 0.6, y: 0.35)),
            DatapathExplanation(text: "PC is updated conditionally to the branch target.", position: CGPoint(x: 0.2, y: 0.3))
        ]
    }
  }
}

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

struct DetailView: View {
  var instruction: DatapathView.InstructionType

  var body: some View { 
    ScrollView { 
      VStack(alignment: .leading, spacing:16) {
        Text("\instruction.rawValue) Datapath")
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

