//
//  HomeView.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
// hi

import SwiftUI

struct HomeView: View {
    @State private var settings = GameSettings()
    @State private var go = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Playful background gradient
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Title with emoji and animation
                    Text("🎮 Fun Trivia! 🎯")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.3), radius: 5, x: 2, y: 2)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear { isAnimating = true }
                    
                    // Mode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Your Adventure!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Picker("Mode", selection: $settings.mode) {
                            ForEach(GameMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Difficulty
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pick Your Challenge!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Picker("Difficulty", selection: $settings.difficulty) {
                            ForEach(GameSettings.DifficultyFilter.allCases) { d in
                                Text(d.title).tag(d)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Questions count with fun emoji
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How Many Questions? 🤔")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Stepper(value: Binding(
                            get: { settings.numberOfQuestions ?? settings.mode.defaultQuestionCount },
                            set: { newVal in settings.numberOfQuestions = newVal }
                        ), in: 5...30, step: 1) {
                            Text("✨ Questions: \(settings.numberOfQuestions ?? settings.mode.defaultQuestionCount)")
                                .font(.system(size: 18, design: .rounded))
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // High score with star emoji
                    VStack(spacing: 4) {
                        if let hs = HighScoreStore.get(mode: settings.mode, difficulty: settings.difficulty) {
                            Text("⭐️ Best Score: \(hs.value)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                            Text(hs.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 16, design: .rounded))
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
                    
                    // Start button with gradient and animation
                    NavigationLink(value: settings) {
                        Text("Let's Play! 🎲")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
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
                    }
                    .padding(.top, 4)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Spacer()
                    
                    // Footer with fun icon
                    Text("🎱 Ready for Some Fun? Let's Go!")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                }
                .padding()
                .navigationDestination(for: GameSettings.self) { s in
                    GameView(settings: s)
                }
            }
        }
    }
}
