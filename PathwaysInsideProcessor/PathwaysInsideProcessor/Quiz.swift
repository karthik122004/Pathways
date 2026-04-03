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
        mcqs.map { .mcq($0) } + 
        puzzles.map { .puzzle($0) }
    
    let selected = Array(mixedPool.shuffled().prefix(totalItems))

    return Quiz(items: selected)
}

// ObservableObject makes quizManager seeable across diff SwiftUIs; should be useful if we do multiple screens to display quiz questions
// @Published makes the property automatically update related SwiftUI views
class QuizManager: ObservableObject {
    @Published var quiz: Quiz
    @Published var currentIdx: Int = 0

    // store quizAnswers to enable navigation across questions
    // mcqAnswers stores questionIdx -> selectedIdx
    @Published var mcqAnswers: [Int: Int] = [:]
    @Published var puzzleAnswers: [Int: [Connection]] = [:]
    
    init(quiz: Quiz) {
        self.quiz = quiz
    }

    // Current Item
    
    var currentItem: QuizItem? {
        // guard is a control statement in swift that is meant to exit fast
        guard currentIdx >= 0 && currentIdx < quiz.items.count else { return nil }
        return quiz.items[currentIdx]
    }

    var isFinished: Bool {
        return currentIdx == quiz.items.count - 1
    }

    var totalQuestions: Int {
        return quiz.items.count
    }

    // Navigation

    func goNext() {
        guard currentIdx < quiz.items.count - 1 else { return }
        currentIdx += 1
    }
    
    func goBack() {
        guard currentIdx > 0 else { return }
        currentIdx -= 1
    }
    func goTo(index: Int) {
        guard index >= 0 && index < quiz.items.count else { return }
        currentIdx = index
    }

    // Answer Submission
    func submitMCQAnswer(selectedIdx: Int) {
        // guard case is specifically for enums
        guard case .mcq = currentItem else { return }
        mcqAnswers[currentIdx] = selectedIdx
    }

    func submitPuzzleAnswer(connections: [Connection]) {
        guard case .puzzle = currentItem else { return }
        puzzleAnswers[currentIdx] = connections
    }

    //Answer Retrieval
    func getMCQAnswer(for index: Int) -> Int? {
        return mcqAnswers[index]
    }

    func getPuzzleAnswer(for index: Int) -> [Connection]? {
        return puzzleAnswers[index]
    }

    // Checking Answers
    func isCorrect(at index: Int) -> Bool {
        guard index >= 0 && index < quiz.items.count else { return false }

        let item = quiz.items[index]

        switch item {
            case .mcq(let mcq):
                guard let selected = mcqAnswers[index] else { return false }
                return selected == mcq.correctIdx
            case .puzzle(let puzzle):
                guard let userConnections = puzzleAnswers[index] else { return false }
                return Set(userConnections) == Set(puzzle.correctConnections)
        }
    }

    // Scoring
    var score: Int {
        var total = 0
            for i in 0..<quiz.items.count {
                if isCorrect(at: i) {
                    total += 1
                }
            }
        return total
    }

    var progress: Double {
        guard quiz.items.count > 0 else { return 0 }
        return Double(currentIdx + 1) / Double(quiz.items.count)
    }
}
