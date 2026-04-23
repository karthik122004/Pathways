// mcqView.swift
// PathwaysInsideProcessor
//
// Renders a multiple-choice question during the quiz.
// Answers lock after the first tap — cannot be changed afterwards.

import SwiftUI

struct MCQView: View {
    @ObservedObject var manager: QuizManager
    let mcq: MCQ

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mcq.prompt)
                .font(.headline)
                .padding(.bottom, 4)

            let answered = manager.getMCQAnswer(for: manager.currentIdx)

            ForEach(0..<mcq.options.count, id: \.self) { idx in
                let isSelected  = answered == idx
                let isCorrect   = idx == mcq.correctIdx
                let isAnswered  = answered != nil

                // Border and background tint are invisible before answering,
                // then immediately reveal correct (green) / wrong (red) feedback.
                let borderColor: Color = {
                    guard isAnswered else { return .clear }
                    if isCorrect { return .green }
                    if isSelected { return .red }
                    return .clear
                }()
                let bgColor: Color = {
                    guard isAnswered else { return Color.gray.opacity(0.10) }
                    if isCorrect { return Color.green.opacity(0.12) }
                    if isSelected { return Color.red.opacity(0.12) }
                    return Color.gray.opacity(0.06)
                }()

                Button(action: {
                    // Guard here acts as a first-pass lock; .disabled(isAnswered) below
                    // is a second layer that also prevents the tap animation from firing.
                    guard answered == nil else { return }
                    manager.submitMCQAnswer(selectedIdx: idx)
                }) {
                    HStack(spacing: 10) {
                        // Status icon
                        Group {
                            if isAnswered {
                                if isCorrect {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if isSelected {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color.secondary.opacity(0.4))
                                }
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.system(size: 18))
                        .frame(width: 24)

                        Text(mcq.options[idx].text)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(
                                isAnswered
                                    ? (isCorrect ? .green : (isSelected ? .red : Color.primary.opacity(0.45)))
                                    : .primary
                            )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(bgColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isAnswered)  // prevents tap animation after answer is locked
                // value: isAnswered means the animation only fires on the single state
                // transition (unanswered → answered), not on every re-render.
                .animation(.easeInOut(duration: 0.2), value: isAnswered)

                // Explanation — shown for correct answer and user's wrong pick
                if isAnswered && (isSelected || isCorrect) {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: isCorrect ? "lightbulb.fill" : "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(isCorrect ? .green : .red)
                            .padding(.top, 1)
                        Text(mcq.options[idx].explanation)
                            .font(.caption)
                            .foregroundColor(isCorrect ? .green : .red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                }
            }

            if let _ = answered {
                // "Answer locked" badge
                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text("Answer locked")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
        .padding()
    }
}
