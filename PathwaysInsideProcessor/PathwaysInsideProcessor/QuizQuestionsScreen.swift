// this is the screen that shows once the quiz has actually started
// it will either show an mcq question, puzzle question, or the question navigation screen

struct QuizScreen: View {
  @ObservedObject var manager: QuizManager

  var body: some View {
    VStack {
      // Progress
      ProgressView(value: manager.progress)
        .padding()

      // Current Question
      if let item = manager.currentItem {
        switch item {
        case .mcq(let mcq):
          MCQView(manager: manager, mcq: mcq)
        case .puzzle(let puzzle):
          PuzzleView(manager: manager, puzzle: puzzle)
        }
      }

      // Navigation
      HStack {
        Button("Back") {
          manager.goBack()
        }.disabled(manager.currentIdx == 0)

        Spacer()

        Button("Next") {
          manager.goNext()
        }.disabled(manager.isFinished)
      }
      .padding()

      // Question Menu Button
      NavigationLink("Jump to Question") {
        QuizMenuView(manager: manager)
      }
      .padding()
    }
    .navigationTitle("Quiz")
    .navigationBarTitleDisplayMode(.inline)
  }
}
