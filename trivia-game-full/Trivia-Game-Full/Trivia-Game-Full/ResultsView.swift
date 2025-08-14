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

    @Environment(\.dismiss) private var dismiss

    private var best: HighScore? {
        HighScoreStore.get(mode: mode, difficulty: difficulty)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Game Over")
                .font(.largeTitle.bold())

            Text("You scored")
                .font(.headline)

            Text("\(score)")
                .font(.system(size: 56, weight: .heavy, design: .rounded))

            if let best {
                VStack(spacing: 2) {
                    Text("Best: \(best.value)")
                        .font(.headline)
                    Text(best.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No high score yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                Button("Play Again") {
                    onPlayAgain()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                Button("Home") {
                    dismiss()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.top, 4)
        }
        .padding()
        .foregroundColor(.white)
    }
}

