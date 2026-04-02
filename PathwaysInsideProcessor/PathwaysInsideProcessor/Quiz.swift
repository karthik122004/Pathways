import foundation

// MCQs are easier to design so they are up here first
struct MCQ: Codable {
    let id: Int
    let prompt: String
    let options: [MCQAnswerOption]
    let correctIdx: Int
}

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

let allMCQs = loadMCQs(from: "mcqs.json")
print("Loaded \(allMCQs.count) questions")

struct MCQAnswerOption: Codable {
    let text: String
    let explanation: String
}

// used on UI SIDE to check user inputs
func checkMCQ(mcq: MCQ, selectedIdx: Int) -> Bool {
    return selectedIdx == mcq.correctIdx
}

// DATAPATH PUZZLES are quite a bit more involved
struct Component: Codable {
    let id: String
    let name: String
    let inputs: [Port]
    let outputs: [Port]
}

struct Port: Codable{
    let id: String
    let type: String
}

struct Connection: Codable, Hashable {
    let fromComponent: String
    let fromPort: String
    let toComponent: String
    let toPort: String
}

struct Puzzle: Codable{
    let components: [Component]
    let correctConnections: [Connection]
}


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

// we have the quiz components, now we have to organize them to build an actual quiz
enum QuizItem {
    case mcq(MCQ)
    case puzzle(Puzzle)
}

struct Quiz {
    let items: [QuizItem]
}

func generateQuiz(mcqs: [MCQ], puzzles: [Puzzle], totalItems: Int) -> Quiz {
    let mixedPool: [QuizItem] = 
        allMCQs.map { .mcq($0) } + 
        allPuzzles.map { .puzzle($0) }
    
    let selected = Array(mixedPool.shuffled().prefix(totalItems))

    return Quiz(items: selected)
}

