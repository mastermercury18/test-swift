//
//  GameView.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import SwiftUI

struct GameView: View {
    let settings: GameSettings
    @StateObject private var vm: GameViewModel

    init(settings: GameSettings) {
        self.settings = settings
        _vm = StateObject(wrappedValue: GameViewModel(settings: settings))
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.6), .blue.opacity(0.6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            if vm.isGameOver {
                ResultsView(score: vm.score,
                            mode: settings.mode,
                            difficulty: settings.difficulty) {
                    vm.startGame() // Play Again
                }
                .padding()
            } else {
                content
                    .padding()
            }
        }
        .navigationTitle("Trivia")
        // ✅ Start AFTER the view appears to avoid "state changed during update"
        .task {
            if vm.totalQuestions == 0 {
                vm.startGame()
            }
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            // Header (score, lives, progress)
            HStack {
                Text("Score: \(vm.score)").font(.headline)
                Spacer()
                LivesView(lives: vm.lives)
            }

            HStack {
                Text("Q \(vm.index + 1)/\(vm.totalQuestions)")
                    .font(.subheadline).foregroundColor(.secondary)
                Spacer()
                if let limit = settings.mode.timePerQuestion {
                    TimeBar(remaining: vm.timeRemaining, total: limit)
                        .frame(width: 140)
                }
            }

            // Question
            if let q = vm.currentQuestion {
                Text(q.text)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                // Options
                VStack(spacing: 12) {
                    ForEach(Array(q.options.enumerated()), id: \.offset) { _, option in
                        Button {
                            vm.answer(option)
                            Haptics.feedback(success: option == q.answer) // no-op on macOS
                        } label: {
                            AnswerRow(text: option,
                                      state: rowState(for: option, correct: q.answer))
                        }
                        .disabled(vm.hasAnswered) // prevent double taps
                    }
                }
                .padding(.top, 6)

                if vm.hasAnswered {
                    Button("Next") { vm.nextQuestion() }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.6)))
                        .cornerRadius(12)
                        .padding(.top, 6)
                }
            } else {
                Text("Loading…").padding()
            }
            Spacer()
        }
        .foregroundColor(.white)
    }

    private func rowState(for option: String, correct: String) -> AnswerRow.State {
        if !vm.hasAnswered { return .neutral }
        if option == correct { return .correct }
        if option == vm.selectedOption { return .wrong }
        return .dimmed
    }
}

// MARK: - Small components

struct LivesView: View {
    let lives: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(lives, 0), id: \.self) { _ in Text("❤️") }
        }
        .font(.title3)
        .accessibilityLabel("\(lives) lives")
    }
}

struct TimeBar: View {
    let remaining: Int
    let total: Int
    var progress: Double { total == 0 ? 0 : Double(remaining) / Double(total) }
    var body: some View {
        ProgressView(value: progress)
            .tint(.green)
            .overlay(
                Text("\(remaining)s")
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
}

struct AnswerRow: View {
    enum State { case neutral, correct, wrong, dimmed }
    let text: String
    let state: State
    var body: some View {
        Text(text)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.25)))
            .cornerRadius(12)
    }
    private var background: some View {
        Group {
            switch state {
            case .neutral: Color.white.opacity(0.15)
            case .correct: Color.green.opacity(0.55)
            case .wrong:   Color.red.opacity(0.55)
            case .dimmed:  Color.white.opacity(0.07)
            }
        }
    }
}


//// MARK: - iOS Preview
//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            GameView(settings: GameSettings())
//        }
//        .previewDevice("iPhone 16")   // <- force iOS device in the preview
//    }
//}

