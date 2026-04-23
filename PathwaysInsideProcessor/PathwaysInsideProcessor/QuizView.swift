// QuizView.swift
// PathwaysInsideProcessor
//
// Entry screen for the quiz — lets the user choose quiz length.
// Navigates full-screen via NavigationLink (no sheet).

import SwiftUI

struct QuizSelectionView: View {
    // Adding a new quiz length only requires appending to this array —
    // the ForEach loop below renders however many entries are present.
    let availableCounts = [10, 20, 30]

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose a Quiz Length")
                .font(.title2.bold())
                .padding(.top, 24)

            Text("Each quiz draws from both multiple-choice and datapath puzzle question pools.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ForEach(availableCounts, id: \.self) { count in
                NavigationLink(destination: QuizConfirmationView(count: count)) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "checklist")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(count)-Question Quiz")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("MCQ + Datapath puzzle mix")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("Quiz")
    }
}
