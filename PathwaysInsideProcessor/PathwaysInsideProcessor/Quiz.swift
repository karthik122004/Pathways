import foundation

// MCQs are easier to design so they are up here first
struct Question {
    let id: Int
    let prompt: String
    let options: [AnswerOption]
    let correctIdx: Int
}

let questions: [Question]= [
    Question(
        id: 1, 
        prompt: "What does the ALU do?",
        options: [
           AnswerOption(text: "Stores data", explanation: "Registers store data."),
           AnswerOption(text: "Performs arithmetic and logic operations", explanation: "Correct!"),
           AnswerOption(text: "Controls Memory", explanation: "Control Unit manages memory."),
           AnswerOption(text: "Fetches Instructions", explanation: "Instruction Fetch is handled by control logic."),
        ],
        correctIdx: 1,
    )
]

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

struct Puzzle {
    let components: [Component]
    let correctConnections: {Connection}
}

// used on UI SIDE to check user inputs
func checkPuzzle(userConnections: [Connection], puzzle: Puzzle) -> Bool {
    reutrn Set(userConnections) == Set(puzzle.correctConnections)
}