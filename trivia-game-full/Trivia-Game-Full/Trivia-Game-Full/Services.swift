//
//  Services.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

import Foundation

// HTML entity decoding (fixes &quot;, &#039;, etc.)
extension String {
    var htmlDecoded: String {
        guard let data = data(using: .utf8) else { return self }
        if let attr = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) { return attr.string }
        return self
    }
}

// Loads questions from bundled data.txt (OpenTDB shape)
enum QuestionLoader {
    static func loadFromBundle(filename: String = "data", ext: String = "txt",
                               onlyMultiple: Bool = true,
                               difficulty: GameSettings.DifficultyFilter = .all) -> [Question] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("❌ Could not find \(filename).\(ext) in bundle.")
            return []
        }
        do {
            let payload = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(OpenTDBResponse.self, from: payload)
            let filtered = decoded.results.filter { q in
                let isMultiOK = onlyMultiple ? (q.type == "multiple") : true
                let diffOK: Bool = {
                    switch difficulty {
                    case .all: return true
                    default:    return q.difficulty.lowercased() == difficulty.rawValue
                    }
                }()
                return isMultiOK && diffOK
            }
            return filtered.map { q in
                let text = q.question.htmlDecoded
                let answer = q.correct_answer.htmlDecoded
                let options = ([q.correct_answer] + q.incorrect_answers)
                    .map { $0.htmlDecoded }
                    .shuffled()
                return Question(text: text, options: options, answer: answer)
            }
        } catch {
            print("❌ Parse error: \(error.localizedDescription)")
            return []
        }
    }
}

// Super-simple persistence (UserDefaults)
enum HighScoreStore {
    private static func key(mode: GameMode, difficulty: GameSettings.DifficultyFilter) -> String {
        "highscore.\(mode.rawValue).\(difficulty.rawValue)"
    }

    static func save(_ value: Int, mode: GameMode, difficulty: GameSettings.DifficultyFilter) {
        let record = HighScore(mode: mode.rawValue, difficulty: difficulty.rawValue, value: value, date: Date())
        if let data = try? JSONEncoder().encode(record) {
            UserDefaults.standard.set(data, forKey: key(mode: mode, difficulty: difficulty))
        }
    }
    static func get(mode: GameMode, difficulty: GameSettings.DifficultyFilter) -> HighScore? {
        guard let data = UserDefaults.standard.data(forKey: key(mode: mode, difficulty: difficulty)),
              let record = try? JSONDecoder().decode(HighScore.self, from: data) else { return nil }
        return record
    }
}
