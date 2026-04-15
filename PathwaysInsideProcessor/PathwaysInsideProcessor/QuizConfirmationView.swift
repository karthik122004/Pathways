// QuizConfirmationView.swift
// PathwaysInsideProcessor
//
// Asks the user to confirm their chosen quiz length before starting.
// Pushed as a full-screen navigation destination (no sheet wrapper needed).

import SwiftUI

struct QuizConfirmationView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text("Ready for \(count) Questions?")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                summaryRow(icon: "questionmark.bubble.fill",
                           text: "Mix of multiple-choice and datapath puzzle questions",
                           color: .blue)
                summaryRow(icon: "lock.fill",
                           text: "Answers lock after first selection — choose carefully",
                           color: .orange)
                summaryRow(icon: "chart.bar.fill",
                           text: "Full review with explanations shown at the end",
                           color: .green)
            }
            .padding(.horizontal)

            NavigationLink {
                let quiz = generateQuiz(mcqs: allMCQs, puzzles: allPuzzles, totalItems: count)
                let manager = QuizManager(quiz: quiz)
                QuizScreen(manager: manager)
            } label: {
                Label("Start Quiz", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Confirm Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summaryRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
