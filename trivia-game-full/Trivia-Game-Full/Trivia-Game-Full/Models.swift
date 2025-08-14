//
//  Models.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import Foundation

// What your UI uses
struct Question: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let options: [String]
    let answer: String
}

// OpenTDB-style payload (your data.txt looks like this)
struct OpenTDBResponse: Decodable {
    let response_code: Int
    let results: [OTDBQuestion]
}

struct OTDBQuestion: Decodable {
    let category: String
    let type: String      // "multiple" or "boolean"
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// Game modes & settings
enum GameMode: String, CaseIterable, Identifiable {
    case classic
    case timed
    case suddenDeath
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .classic: return "Classic"
        case .timed: return "Timed"
        case .suddenDeath: return "Sudden Death"
        }
    }
    var defaultQuestionCount: Int {
        switch self {
        case .classic: return 10
        case .timed: return 10
        case .suddenDeath: return 15
        }
    }
    var timePerQuestion: Int? {        // seconds
        switch self {
        case .timed: return 15
        default: return nil
        }
    }
    var startingLives: Int {
        switch self {
        case .suddenDeath: return 1
        default: return 3
        }
    }
}

struct GameSettings: Equatable, Hashable {   // add Hashable
    var mode: GameMode = .classic
    var difficulty: DifficultyFilter = .all
    var numberOfQuestions: Int? = nil

    enum DifficultyFilter: String, CaseIterable, Identifiable, Hashable { // add Hashable
        case all, easy, medium, hard
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }
}

// Simple high score record
struct HighScore: Codable, Equatable {
    var mode: String
    var difficulty: String
    var value: Int
    var date: Date
}
