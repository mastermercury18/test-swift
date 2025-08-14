//
//  GameViewModel.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    // Inputs
    let settings: GameSettings

    // Data
    @Published private(set) var questions: [Question] = []
    @Published private(set) var index: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var lives: Int
    @Published private(set) var isGameOver: Bool = false

    // Per-question
    @Published var hasAnswered = false
    @Published var selectedOption: String? = nil
    @Published private(set) var isCorrect = false

    // Timer (Timed mode)
    @Published private(set) var timeRemaining: Int = 0
    private var timer: Timer?

    // Derived
    var currentQuestion: Question? {
        (0..<questions.count).contains(index) ? questions[index] : nil
    }
    var totalQuestions: Int { questions.count }
    var timeLimit: Int? { settings.mode.timePerQuestion }

    init(settings: GameSettings) {
        self.settings = settings
        self.lives = settings.mode.startingLives
        // ❗️Do NOT call startGame() here. We'll start from the View via .task.
    }

    deinit { timer?.invalidate() }

    // Public entry point you can call after the view appears
    func startGame() {
        // Load and trim to requested count
        var loaded = QuestionLoader.loadFromBundle(
            onlyMultiple: true,
            difficulty: settings.difficulty
        )
        loaded.shuffle()
        let count = settings.numberOfQuestions ?? settings.mode.defaultQuestionCount
        if loaded.count > count { loaded = Array(loaded.prefix(count)) }
        questions = loaded

        index = 0
        score = 0
        lives = settings.mode.startingLives
        isGameOver = questions.isEmpty
        hasAnswered = false
        selectedOption = nil
        isCorrect = false

        resetTimer()
    }

    func answer(_ option: String) {
        guard !hasAnswered, let q = currentQuestion else { return }
        hasAnswered = true
        selectedOption = option
        isCorrect = (option == q.answer)
        if isCorrect { score += 1 } else { lives -= 1 }
        stopTimer()

        // Sudden death ends instantly on wrong
        if settings.mode == .suddenDeath, !isCorrect {
            finishGame()
        } else if lives <= 0 {
            finishGame()
        }
    }

    func nextQuestion() {
        guard !isGameOver else { return }

        // If time ran out and user hasn't answered, treat as wrong
        if !hasAnswered, settings.mode.timePerQuestion != nil {
            lives -= 1
            if lives <= 0 { finishGame(); return }
        }

        hasAnswered = false
        selectedOption = nil
        isCorrect = false

        if index + 1 < questions.count {
            index += 1
            resetTimer()
        } else {
            finishGame()
        }
    }

    func tick() {
        guard let _ = settings.mode.timePerQuestion, !hasAnswered else { return }
        timeRemaining = max(0, timeRemaining - 1)
        if timeRemaining == 0 {
            // Auto-advance on timeout
            hasAnswered = false
            stopTimer()
            nextQuestion()
        }
    }

    func resetGame() {
        startGame()
    }

    // MARK: - Private
    private func finishGame() {
        stopTimer()
        isGameOver = true
        HighScoreStore.save(score, mode: settings.mode, difficulty: settings.difficulty)
    }

    private func resetTimer() {
        stopTimer()
        if let limit = timeLimit {
            timeRemaining = limit
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.tick() }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
