// QuizQuestionsScreen.swift
// PathwaysInsideProcessor
//
// Main quiz screen — shows the current question (MCQ or Puzzle)
// and provides navigation between questions.

import SwiftUI

// MARK: - Quiz Screen

struct QuizScreen: View {
    @ObservedObject var manager: QuizManager

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: manager.progress)
                .padding(.horizontal)
                .padding(.top, 8)

            Text("Question \(manager.currentIdx + 1) of \(manager.totalQuestions)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            Divider().padding(.top, 8)

            // Current question
            ScrollView {
                if let item = manager.currentItem {
                    switch item {
                    case .mcq(let mcq):
                        MCQView(manager: manager, mcq: mcq)
                    case .puzzle(let puzzle):
                        PuzzleView(manager: manager, puzzle: puzzle)
                    }
                }
            }

            Divider()

            // Navigation buttons
            HStack {
                Button(action: { manager.goBack() }) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(manager.currentIdx == 0)

                Spacer()

                NavigationLink("Questions") {
                    QuizMenuView(manager: manager)
                }
                .buttonStyle(.bordered)

                Spacer()

                if manager.isFinished {
                    NavigationLink("Results") {
                        QuizResultsView(manager: manager)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: { manager.goNext() }) {
                        Label("Next", systemImage: "chevron.right")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Question Menu (jump-to)

struct QuizMenuView: View {
    @ObservedObject var manager: QuizManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(0..<manager.totalQuestions, id: \.self) { idx in
                Button(action: {
                    manager.goTo(index: idx)
                    dismiss()
                }) {
                    HStack {
                        let label: String = {
                            switch manager.quiz.items[idx] {
                            case .mcq: return "MCQ"
                            case .puzzle: return "Puzzle"
                            }
                        }()
                        let answered: Bool = {
                            switch manager.quiz.items[idx] {
                            case .mcq:    return manager.getMCQAnswer(for: idx) != nil
                            case .puzzle: return manager.getPuzzleAnswer(for: idx) != nil
                            }
                        }()
                        Text("Q\(idx + 1) · \(label)")
                            .foregroundColor(.primary)
                        Spacer()
                        if answered {
                            Image(systemName: manager.isCorrect(at: idx)
                                  ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(manager.isCorrect(at: idx) ? .green : .red)
                                .font(.subheadline)
                        }
                        if idx == manager.currentIdx {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Jump to Question")
    }
}

// MARK: - Results Screen

struct QuizResultsView: View {
    @ObservedObject var manager: QuizManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Score header ──────────────────────────────────────────
                scoreSummary
                    .padding()

                Divider()

                // ── Per-question review ───────────────────────────────────
                ForEach(0..<manager.totalQuestions, id: \.self) { idx in
                    questionReview(at: idx)
                    if idx < manager.totalQuestions - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Score summary card

    private var scoreSummary: some View {
        let pct = manager.totalQuestions > 0
            ? Int(Double(manager.score) / Double(manager.totalQuestions) * 100)
            : 0
        let isPerfect = manager.score == manager.totalQuestions
        let ringColor: Color = isPerfect ? .yellow : (pct >= 70 ? .green : (pct >= 40 ? .orange : .red))

        return VStack(spacing: 14) {
            Image(systemName: isPerfect ? "star.fill" : "chart.bar.fill")
                .font(.system(size: 52))
                .foregroundColor(isPerfect ? .yellow : .blue)

            Text(isPerfect ? "Perfect Score!" : "Quiz Complete")
                .font(.title2.bold())

            Text("\(manager.score) / \(manager.totalQuestions) correct")
                .font(.title3)
                .foregroundColor(.secondary)

            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(manager.score) / CGFloat(max(1, manager.totalQuestions)))
                    .stroke(ringColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: manager.score)
                VStack(spacing: 0) {
                    Text("\(pct)%")
                        .font(.title3.bold())
                    Text("Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 96, height: 96)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Per-question review row

    @ViewBuilder
    private func questionReview(at idx: Int) -> some View {
        let isCorrect = manager.isCorrect(at: idx)

        VStack(alignment: .leading, spacing: 10) {
            // Question header row
            HStack {
                Text("Q\(idx + 1)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.6))
                    .clipShape(Capsule())

                Group {
                    switch manager.quiz.items[idx] {
                    case .mcq:    Label("Multiple Choice", systemImage: "questionmark.bubble")
                    case .puzzle: Label("Datapath Puzzle", systemImage: "puzzlepiece.extension")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.title3)
            }

            // Question-type body
            switch manager.quiz.items[idx] {
            case .mcq(let mcq):
                mcqReview(mcq: mcq, questionIdx: idx, isCorrect: isCorrect)
            case .puzzle(let puzzle):
                puzzleReview(puzzle: puzzle, questionIdx: idx, isCorrect: isCorrect)
            }
        }
        .padding()
        .background(isCorrect ? Color.green.opacity(0.04) : Color.red.opacity(0.04))
    }

    // MARK: MCQ review

    @ViewBuilder
    private func mcqReview(mcq: MCQ, questionIdx: Int, isCorrect: Bool) -> some View {
        let userAnswer = manager.getMCQAnswer(for: questionIdx)

        // Question prompt
        Text(mcq.prompt)
            .font(.subheadline.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 2)

        if let userIdx = userAnswer {
            // Always show the correct answer
            answerRow(option: mcq.options[mcq.correctIdx], kind: .correct)

            // Show user's answer only if it was wrong
            if userIdx != mcq.correctIdx {
                answerRow(option: mcq.options[userIdx], kind: .wrong)
            }
        } else {
            HStack(spacing: 6) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.secondary)
                Text("Not answered")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // Still show the correct answer
            answerRow(option: mcq.options[mcq.correctIdx], kind: .correct)
        }
    }

    private enum AnswerKind { case correct, wrong }

    @ViewBuilder
    private func answerRow(option: MCQAnswerOption, kind: AnswerKind) -> some View {
        let isCorrect = kind == .correct
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.subheadline)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 3) {
                    // Label + option text on the same line — no deprecated + operator
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(isCorrect ? "Correct:" : "Your answer:")
                            .font(.caption.bold())
                            .foregroundColor(isCorrect ? .green : .red)
                        Text(option.text)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(option.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((isCorrect ? Color.green : Color.red).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: Puzzle review

    @ViewBuilder
    private func puzzleReview(puzzle: Puzzle, questionIdx: Int, isCorrect: Bool) -> some View {
        let userConns  = Set(manager.getPuzzleAnswer(for: questionIdx) ?? [])
        let required   = correctConnections(for: puzzle.id).isEmpty
            ? Set(puzzle.correctConnections)
            : correctConnections(for: puzzle.id)

        let correctMade = userConns.intersection(required).count   // right connections drawn
        let missing     = required.subtracting(userConns).count    // correct ones not drawn
        let wrong       = userConns.subtracting(required).count    // extra wrong ones drawn
        let totalNeeded = required.count

        VStack(alignment: .leading, spacing: 6) {
            // Instruction type + description
            Text(puzzle.instructionType)
                .font(.subheadline.bold())
            Text(puzzle.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Wire count breakdown
            HStack(spacing: 16) {
                statPill(value: "\(correctMade)", label: "Correct", color: .green)
                statPill(value: "\(wrong)",       label: "Wrong",   color: .red)
                statPill(value: "\(missing)",     label: "Missing", color: .orange)
                statPill(value: "\(totalNeeded)", label: "Needed",  color: .secondary)
            }
            .padding(.top, 2)

            // Verdict label
            let verdictMsg: String = {
                if isCorrect           { return "All connections placed correctly" }
                if userConns.isEmpty   { return "Not attempted" }
                if wrong > 0 && missing > 0 { return "\(wrong) wrong, \(missing) missing" }
                if wrong > 0           { return "\(wrong) wrong connection\(wrong == 1 ? "" : "s") drawn" }
                return "\(missing) connection\(missing == 1 ? "" : "s") missing"
            }()

            Label(
                verdictMsg,
                systemImage: isCorrect ? "checkmark.seal.fill" : (userConns.isEmpty ? "minus.circle" : "xmark.seal.fill")
            )
            .font(.caption.bold())
            .foregroundColor(isCorrect ? .green : (userConns.isEmpty ? .secondary : .red))
            .padding(.top, 2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func statPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
