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
    @State private var isAnimating = false

    init(settings: GameSettings) {
        self.settings = settings
        _vm = StateObject(wrappedValue: GameViewModel(settings: settings))
    }

    var body: some View {
        ZStack {
            // Playful background gradient similar to HomeView
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
        .onAppear { isAnimating = true }
    }

    private var content: some View {
        VStack(spacing: 24) {
            // Header (score, lives, progress) with updated styling
            HStack {
                Text("Score: \(vm.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Spacer()
                LivesView(lives: vm.lives)
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(10)

            HStack {
                Text("Q \(vm.index + 1)/\(vm.totalQuestions)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Spacer()
                if let limit = settings.mode.timePerQuestion {
                    TimeBar(remaining: vm.timeRemaining, total: limit)
                        .frame(width: 140)
                }
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(10)

            // Question with updated styling
            if let q = vm.currentQuestion {
                Text(q.text)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .foregroundColor(.orange)

                // Options with updated styling
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
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                }
            } else {
                Text("Loading…")
                    .font(.system(size: 18, design: .rounded))
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .foregroundColor(.orange)
            }
            Spacer()
        }
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
            ForEach(0..<max(lives, 0), id: \.self) { _ in 
                Text("❤️")
                    .font(.title3)
            }
        }
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
                    .foregroundColor(.orange)
                    .fontWeight(.bold)
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
            .cornerRadius(12)
            .foregroundColor(foregroundColor)
    }
    
    private var background: some View {
        Group {
            switch state {
            case .neutral: 
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .correct: Color.green.opacity(0.7)
            case .wrong:   Color.red.opacity(0.7)
            case .dimmed:  Color.white.opacity(0.3)
            }
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .neutral, .dimmed: return .orange
        case .correct, .wrong: return .white
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

