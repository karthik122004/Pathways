// HomeView.swift
// PathwaysInsideProcessor
//
// Root screen of the app — entry point for all features.

import SwiftUI

struct HomeView: View {
    var body: some View {
        // NavigationStack is declared here once so every pushed view automatically
        // inherits the nav bar. Declaring it deeper (inside each feature) would
        // require each screen to manage its own stack.
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // App identity header
                VStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("Pathways")
                        .font(.largeTitle.bold())
                    Text("Inside the Processor")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                // Feature entry points — each NavigationLink pushes its destination
                // onto the shared NavigationStack declared above.
                VStack(spacing: 16) {
                    NavigationLink(destination: PuzzleSelectionView()) {
                        HomeButton(title: "Datapath Puzzle",
                                   subtitle: "Wire up the processor yourself",
                                   icon: "puzzlepiece.extension",
                                   color: .orange)
                    }

                    NavigationLink(destination: QuizSelectionView()) {
                        HomeButton(title: "Take Quiz",
                                   subtitle: "Test your knowledge",
                                   icon: "checklist",
                                   color: .green)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Pathways")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Home Button

// Extracted as a private struct so HomeView's body stays readable
// and additional home buttons can be added without duplicating layout.
private struct HomeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
            // Chevron signals to the user that this row navigates somewhere.
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
}
