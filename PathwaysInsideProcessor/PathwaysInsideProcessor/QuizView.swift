// this is the screen that shows when the user clicks on quiz from the home screen
// from here the user can choose between different quiz types based on how long the quiz is

struct QuizSelectionView: View {
  @State private var selectedCount: Int?
  @State private var showConfirmation = false

  // these are the options for quiz length that the user can pick
  let availableCounts = [10, 20, 30]

  var body: some View {
    NavigationView {
      VStack {
        Text("Choose a Quiz Length")
          .font(.title)

        ForEach(availableCounts, id: \.self) { 
          count in Button("Start \(count)-Question Quiz") {
            selectedCount = count
            showConfirmation = true
          }
          .padding()
          .background(Color.blue.opacity(0.2))
          .cornerRadius(8)
        }
      }
      .navigationTitle("Quiz Selection")
      .sheet(isPresented: $showConfirmation) {
        if let count = selectedCount {
          QuizConfirmationView(count: count)
        }
      }
    }
  }
}
