import foundation

// represents mcq answer choices: the answer choice itself & the explanation for it
struct MCQAnswerOption: Codable {
    let text: String
    let explanation: String
}

// MCQs are easier to design so they are up here first
struct MCQ: Codable {
    let id: Int
    let prompt: String
    let options: [MCQAnswerOption]
    let correctIdx: Int
}

// this takes in mcq.json to load in all the mcq for the quiz
// i put the mcqs in the json for organization
func loadMCQs(from filename: String) -> [MCQ] {
    do {
        let url = URL(fileURLWithPath: filename)
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([MCQ].self, from: data)
        return decoded
    } catch {
        print("Error loading questions: \(error)")
        return []
    }
}

// all the mcqs are loaded in to be used
let allMCQs = loadMCQs(from: "mcqs.json")
print("Loaded \(allMCQs.count) questions")

// used on UI SIDE to check user inputs
func checkMCQ(mcq: MCQ, selectedIdx: Int) -> Bool {
    return selectedIdx == mcq.correctIdx
}

// DATAPATH PUZZLES are quite a bit more involved
// represents processor components: ALU, Register File, Data Memory, Sign Extend, Control Unit
struct Component: Codable {
    let id: String
    let name: String
    let inputs: [Port]
    let outputs: [Port]
}

// represents inputs and output ports of components
struct Port: Codable{
    let id: String
    let type: String
}

// represents the wires between components, also control signals
struct Connection: Codable, Hashable {
    let fromComponent: String
    let fromPort: String
    let toComponent: String
    let toPort: String
}

// represents puzzle questions where we provide components and the tester has to draw the wires
struct Puzzle: Codable{
    let components: [Component]
    let correctConnections: [Connection]
}

// loads puzzle questions from json
func loadPuzzles(from filename: String) -> [Puzzle] {
    do {
        let url = URL(fileURLWithPath: filename)
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Puzzle].self, from: data)
        return decoded
    } catch {
        print("Error loading questions: \(error)")
        return []
    }
}
let allPuzzles = loadPuzzles(from: "puzzles.json")

// used on UI SIDE to check user inputs
func checkPuzzle(userConnections: [Connection], puzzle: Puzzle) -> Bool {
    return Set(userConnections) == Set(puzzle.correctConnections)
}

// we have the quiz components, now we have to organize them to be options on the quiz
enum QuizItem {
    case mcq(MCQ)
    case puzzle(Puzzle)
}

// this represents the actual quiz composed of quiz items
struct Quiz {
    let items: [QuizItem]
}

// this builds the quiz to be used
func generateQuiz(mcqs: [MCQ], puzzles: [Puzzle], totalItems: Int) -> Quiz {
    let mixedPool: [QuizItem] = 
        allMCQs.map { .mcq($0) } + 
        allPuzzles.map { .puzzle($0) }
    
    let selected = Array(mixedPool.shuffled().prefix(totalItems))

    return Quiz(items: selected)
}

// ObservableObject makes quizManager seeable across diff SwiftUIs; should be useful if we do multiple screens to display quiz questions
// @Published makes the property automatically update related SwiftUI views
class QuizManager: ObservableObject {
    @Published var quiz: Quiz
    @Published var currentIdx: Int = 0
    @Published var score: Int = 0

    init(quiz: Quiz) {
        self.quiz = quiz
    }

    var currentItem: QuizItem? {
        // guard is a control statement in swift that is meant to exit fast
        guard currentIdx < quiz.items.count else { return nil }
        return quiz.items[currentIdx]
    }

    func submitMCQAnswer(selectedIdx: Int) -> Bool {
        // guard case is specifically for enums
        guard case let .mcq(mcq) = currentItem else { return false }
        let correct = checkMCQ(mcq: mcq, selectedIdx: selectedIdx)
        if correct { score += 1 }
        return correct
    }

    func submitPuzzleAnswer(userConnections: [Connection]) -> Bool {
        guard case let .puzzle(puzzle) = currentItem else { return false }
        let correct = checkPuzzle(userConnections: userConnections, puzzle: puzzle)
        if correct { score += 1 }
        return correct
    }

    func nextItem( {
        currentIdx += 1
    }
}
