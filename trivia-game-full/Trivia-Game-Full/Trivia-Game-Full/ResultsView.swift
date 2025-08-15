//
//  ResultsView.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import SwiftUI

struct ResultsView: View {
    let score: Int
    let mode: GameMode
    let difficulty: GameSettings.DifficultyFilter
    var onPlayAgain: () -> Void
    
    @State private var isAnimating = false

    @Environment(\.dismiss) private var dismiss

    private var best: HighScore? {
        HighScoreStore.get(mode: mode, difficulty: difficulty)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Title with emoji and animation similar to HomeView
            Text("🎉 Game Over! 🎉")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.3), radius: 5, x: 2, y: 2)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear { isAnimating = true }

            Text("You scored")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.orange)

            Text("\(score)")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(.orange)

            // High score display with updated styling
            VStack(spacing: 8) {
                if let best {
                    Text("⭐️ Best Score: \(best.value)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text(best.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                } else {
                    Text("🌟 Set Your First High Score!")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(10)

            // Buttons with updated styling
            HStack(spacing: 12) {
                Button("Play Again 🎲") {
                    onPlayAgain()
                }
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

                Button("Home 🏠") {
                    dismiss()
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.orange.opacity(0.7), .yellow.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 4)
            
            Spacer()
            
            // Footer with fun icon
            Text("🎱 Thanks for Playing!")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.orange.opacity(0.8))
        }
        .padding()
    }
}

