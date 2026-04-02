import foundation

// MCQs are easier to design so they are up here first
struct Question: Hashable {
    let id: Int
    let prompt: String
    let options: [AnswerOption]
    let correctIdx: Int
}

let allQuestions = loadQuestions(from: "questions.json")

struct AnswerOption {
    let text: String
    let explanation: String
}

// used on UI SIDE to check user inputs
func checkAnswers(question: Question, selectedIdx: Int) -> Bool {
    return SelectedIdx == question.correctIdx
}

// DATAPATH PUZZLES are quite a bit more involved
struct Component {
    let id: String
    let name: String
    let inputs: [Port]
    let outputs: [Port]
}

struct Port {
    let id: String
    let type: String
}

struct Connection {
    let fromComponent: String
    let fromPort: String
    let toComponent: String
    let toPort: String
}

struct Puzzle: Hashable{
    let components: [Component]
    let correctConnections: {Connection}
}

let allPuzzles: [Puzzle]

// used on UI SIDE to check user inputs
func checkPuzzle(userConnections: [Connection], puzzle: Puzzle) -> Bool {
    reutrn Set(userConnections) == Set(puzzle.correctConnections)
}

// we have the quiz components, now we have to organize them to build an actual quiz
enum QuizItem {
    case question(Question)
    case puzzle(Puzzle)
}

struct Quiz {
    let items: [QuizItem]
}

func generateQuiz(
    from allQuestions: [Question],
    and allPuzzles: [Puzzle],
    totalItems: Int
) -> Quiz {
    let mixedPool: [QuizItem] = 
        allQuestions.map { .question($0) } + 
        allPuzzles.map { .puzzle($0) }
    
    let selected = Array(mixedPool.shuffled().prefix(totalItems))

    return Quiz(items: selected)
}

