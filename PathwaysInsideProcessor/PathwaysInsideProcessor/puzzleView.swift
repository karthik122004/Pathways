// this is the screen that shows when you get a puzzle question on the quiz. 
// this is inherently going to be more involved than the mcqView because we have to manage the actual pathways

struct PuzzleView: View {
  @ObservedOjbect var manager: QuizManager
  let puzzle: Puzzle

  @State private var selectedPort: Port? = nil
  @State private var connections: [Connection] = []

  var body: some View {
    ZStack {
      // draw existing connectiosn
      ForEach(connections, id: \.self) {
        conn in ConnectionLineView(connection: conn)
      }

      // draw components
      ForEach(puzzle.components, id: \.id) {
        component in ComponentView(component: component) {
          tappedPort in handlePortTap(tappedPort)
        }
      }
    }
    .onChange(of: connections) {
      newValue in manager.submitPuzzleAnswer(connectiosn: newValue)
    }
  }

  func handlePortTap(_ port: Port) {
    if let start = selectedPort {
      //find nearest compatible input port and create connection
      let connection = Connection(
        fromComponent: start.id,
        fromPort: start.id,
        toComponent: port.id,
        toPort: port.id
      )
      connections.append(connection)
      selectedPort = nil
    } else {
      selectedPort = port
    }
  }
}


