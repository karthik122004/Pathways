// QuizLogic.swift
// PathwaysInsideProcessor
//
// Backend data models and logic for the quiz system.
// Handles MCQ questions and datapath puzzle questions.

import Foundation
import Combine

// MARK: - MCQ Models

/// One answer choice in a multiple-choice question
struct MCQAnswerOption: Codable {
    let text: String
    let explanation: String
}

/// A multiple-choice question
struct MCQ: Codable {
    let id: Int
    let prompt: String
    let options: [MCQAnswerOption]
    let correctIdx: Int
}

// MARK: - Datapath Puzzle Models

/// An input or output port on a processor component
struct Port: Codable {
    let id: String
    let type: String
}

/// A processor component (ALU, Register File, Data Memory, etc.)
struct Component: Codable {
    let id: String
    let name: String
    let inputs: [Port]
    let outputs: [Port]
}

/// A wire connection between two component ports
struct Connection: Codable, Hashable {
    let fromComponent: String
    let fromPort: String
    let toComponent: String
    let toPort: String
}

/// A datapath puzzle for one instruction type
struct Puzzle: Codable {
    let id: String
    let instructionType: String
    let description: String
    let hint: String
    let components: [Component]
    let correctConnections: [Connection]
}

// MARK: - Loading Helpers

/// Loads MCQ questions from questions.json in the app bundle
func loadMCQs() -> [MCQ] {
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
        print("Could not find questions.json in bundle")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([MCQ].self, from: data)
    } catch {
        print("Error loading MCQs: \(error)")
        return []
    }
}

/// Loads puzzle questions from puzzles.json in the app bundle
func loadPuzzles() -> [Puzzle] {
    guard let url = Bundle.main.url(forResource: "puzzles", withExtension: "json") else {
        print("Could not find puzzles.json in bundle")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Puzzle].self, from: data)
    } catch {
        print("Error loading puzzles: \(error)")
        return []
    }
}

let allMCQs: [MCQ] = loadMCQs()
let allPuzzles: [Puzzle] = loadPuzzles()

// MARK: - Answer Checking

/// Returns true if the selected index matches the correct answer
func checkMCQ(mcq: MCQ, selectedIdx: Int) -> Bool {
    return selectedIdx == mcq.correctIdx
}

/// Returns true if the user's connections match the correct solution exactly
func checkPuzzle(userConnections: [Connection], puzzle: Puzzle) -> Bool {
    return Set(userConnections) == Set(puzzle.correctConnections)
}

// MARK: - Quiz Assembly

/// A quiz item is either an MCQ or a datapath puzzle
enum QuizItem {
    case mcq(MCQ)
    case puzzle(Puzzle)
}

/// A quiz is an ordered list of quiz items
struct Quiz {
    let items: [QuizItem]
}

/// Builds a randomised quiz of the given length from the available question pools
func generateQuiz(mcqs: [MCQ], puzzles: [Puzzle], totalItems: Int) -> Quiz {
    let pool: [QuizItem] = mcqs.map { .mcq($0) } + puzzles.map { .puzzle($0) }
    let selected = Array(pool.shuffled().prefix(totalItems))
    return Quiz(items: selected)
}

// MARK: - Quiz Manager

/// Manages quiz state and navigation across all SwiftUI views
@MainActor
class QuizManager: ObservableObject {
    @Published var quiz: Quiz
    @Published var currentIdx: Int = 0

    /// MCQ answers: questionIndex -> selectedOptionIndex
    @Published var mcqAnswers: [Int: Int] = [:]
    /// Puzzle answers: questionIndex -> user-drawn connections
    @Published var puzzleAnswers: [Int: [Connection]] = [:]

    init(quiz: Quiz) {
        self.quiz = quiz
    }

    // MARK: Current Item

    var currentItem: QuizItem? {
        guard currentIdx >= 0 && currentIdx < quiz.items.count else { return nil }
        return quiz.items[currentIdx]
    }

    var isFinished: Bool { currentIdx == quiz.items.count - 1 }
    var totalQuestions: Int { quiz.items.count }

    // MARK: Navigation

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

    // MARK: Answer Submission

    func submitMCQAnswer(selectedIdx: Int) {
        guard case .mcq = currentItem else { return }
        // Answers lock after the first submission
        guard mcqAnswers[currentIdx] == nil else { return }
        mcqAnswers[currentIdx] = selectedIdx
    }

    func submitPuzzleAnswer(connections: [Connection]) {
        guard case .puzzle = currentItem else { return }
        puzzleAnswers[currentIdx] = connections
    }

    // MARK: Answer Retrieval

    func getMCQAnswer(for index: Int) -> Int? { mcqAnswers[index] }
    func getPuzzleAnswer(for index: Int) -> [Connection]? { puzzleAnswers[index] }

    // MARK: Scoring

    func isCorrect(at index: Int) -> Bool {
        guard index >= 0 && index < quiz.items.count else { return false }
        switch quiz.items[index] {
        case .mcq(let mcq):
            guard let selected = mcqAnswers[index] else { return false }
            return selected == mcq.correctIdx
        case .puzzle(let puzzle):
            guard let userConns = puzzleAnswers[index] else { return false }
            // Exact match: user must draw ALL correct connections and NO wrong ones.
            // Drawing extra distractor connections counts as incorrect.
            let correct = correctConnections(for: puzzle.id)
            let required: Set<Connection> = correct.isEmpty
                ? Set(puzzle.correctConnections)   // fallback to JSON
                : correct
            return Set(userConns) == required
        }
    }

    var score: Int {
        (0..<quiz.items.count).filter { isCorrect(at: $0) }.count
    }

    var progress: Double {
        guard quiz.items.count > 0 else { return 0 }
        return Double(currentIdx + 1) / Double(quiz.items.count)
    }
}
