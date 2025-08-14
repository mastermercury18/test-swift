//
//  HomeView.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import SwiftUI

struct HomeView: View {
    @State private var settings = GameSettings()
    @State private var go = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Trivia Game")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                // Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mode").font(.headline)
                    Picker("Mode", selection: $settings.mode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Difficulty
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty").font(.headline)
                    Picker("Difficulty", selection: $settings.difficulty) {
                        ForEach(GameSettings.DifficultyFilter.allCases) { d in
                            Text(d.title).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Questions count (optional)
                Stepper(value: Binding(
                    get: { settings.numberOfQuestions ?? settings.mode.defaultQuestionCount },
                    set: { newVal in settings.numberOfQuestions = newVal }
                ), in: 5...30, step: 1) {
                    Text("Questions: \(settings.numberOfQuestions ?? settings.mode.defaultQuestionCount)")
                }
                
                // High score
                VStack(spacing: 4) {
                    if let hs = HighScoreStore.get(mode: settings.mode, difficulty: settings.difficulty) {
                        Text("Best: \(hs.value)")
                            .font(.headline)
                        Text(hs.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No high score yet").foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                NavigationLink(value: settings) {
                    Text("Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 4)
                
                Spacer()
                
                Text("Questions are loaded locally from data.txt")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationDestination(for: GameSettings.self) { s in
                GameView(settings: s)
            }
        }
    }
}
