// this is the screen that shows when you click on a quiz option
// it asks for confirmation that this is the quiz you want to start

struct QuizConfirmation: View {
  let count: Int
  @Environment(\.presentationmode) var presentationMode

  var body: some View {
    VStack(spacing: 20) {
      Text("Start a \(count)-Question Quiz?")
        .font(.headline)

      Navigationlink("Start Quiz") {
        let quiz = generateQuiz(mcqs: allMCQs, puzzles: allPuzzles, totalItems: count)
        let manager = QuizManager(quiz: quiz)

        QuizScreen(manager: manager)
      }

      Button("Cancel") {
        presentationMode.wrappedvalue.dismiss(0)
      }
    }
    .padding()
  }
}
