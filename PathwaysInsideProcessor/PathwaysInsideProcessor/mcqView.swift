// this is the screen that shows when you get a multiple choice question on the quiz

struct mcqView: View {
  @ObservedObject var manager: QuizManager
  let mcq: MCQ

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(mcq.prompt)
        .font(.headline)

      ForEach(0..<mcq.options.count, id: \.self) {
        idx in Button(action : {
          manager.submitMCQAnswer(selectedIdx: idx)
        }) {
          Text(mcq.options[idx].text)
            .padding()
            .frame(maxWidth: .infnity, alightment: .leading)
            .backround(manager.getMCQAnswer(for: manager.currentIdx) == idx ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
            .cornerRadius(6)
        }
      }
    }
    .padding()
  }
}
