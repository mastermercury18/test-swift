import SwiftUI

// MARK: - UI Model
struct Question: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let options: [String]
    let answer: String
}

// MARK: - OpenTDB JSON types (what your data.txt looks like)
struct OpenTDBResponse: Decodable {
    let response_code: Int
    let results: [OTDBQuestion]
}

struct OTDBQuestion: Decodable {
    let category: String
    let type: String        // "multiple" or "boolean"
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// MARK: - HTML entity decoding
extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        if let attr = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return attr.string
        }
        return self
    }
}

// MARK: - ViewModel (loads from bundle)
@MainActor
final class TriviaViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var error: String? = nil
    @Published var isLoading = false

    func loadFromBundle(filename: String = "data_file", ext: String = "txt") {
        isLoading = true
        error = nil
        questions = []
        defer { isLoading = false }

        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            error = "Couldn't find \(filename).\(ext) in app bundle."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(OpenTDBResponse.self, from: data)

            let mapped = decoded.results.map { q in
                let text = q.question.htmlDecoded
                let answer = q.correct_answer.htmlDecoded
                let allOptions = ([q.correct_answer] + q.incorrect_answers)
                    .map { $0.htmlDecoded }
                    .shuffled()
                return Question(text: text, options: allOptions, answer: answer)
            }

            // If you only want multiple-choice (exclude True/False), uncomment:
            // self.questions = mapped.filter { $0.options.count > 2 }
            self.questions = mapped
        } catch {
            self.error = "Failed to parse data_file.txt: \(error.localizedDescription)"
        }
    }
}

// MARK: - View
struct ContentView: View {
    @StateObject private var vm = TriviaViewModel()

    @State private var currentQuestionIndex = 0
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var points = 0

    var body: some View {
        Group {
            if vm.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading questions…")
                }
                .padding()
            } else if let error = vm.error {
                VStack(spacing: 16) {
                    Text(error).multilineTextAlignment(.center)
                    Button("Retry") {
                        vm.loadFromBundle()
                    }
                }
                .padding()
            } else if vm.questions.isEmpty {
                VStack(spacing: 16) {
                    Text("No questions found.")
                    Button("Load Questions") {
                        vm.loadFromBundle()
                    }
                }
                .padding()
            } else {
                gameView
            }
        }
        .onAppear {
            // Load once when the view appears
            if vm.questions.isEmpty { vm.loadFromBundle() }
        }
    }

    private var gameView: some View {
        let question = vm.questions[currentQuestionIndex]

        return VStack(spacing: 20) {
            // Header
            HStack {
                Text("Score: \(points)")
                    .font(.headline)
                Spacer()
                Text("Q \(currentQuestionIndex + 1)/\(vm.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Question
            Text(question.text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { _, option in
                    Button {
                        checkAnswer(option)
                    } label: {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(showResult) // prevent double taps
                }
            }

            // Result
            if showResult {
                if isCorrect {
                    Text("✅ Correct!")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    VStack(spacing: 4) {
                        Text("❌ Wrong")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text("Answer: \(question.answer)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Button("Next Question") {
                    nextQuestion()
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .animation(.default, value: showResult)
    }

    // MARK: - Game Logic
    private func checkAnswer(_ selected: String) {
        guard !showResult else { return }
        let correct = vm.questions[currentQuestionIndex].answer
        let wasCorrect = (selected == correct)
        isCorrect = wasCorrect
        showResult = true
        if wasCorrect { points += 1 } // update score on the tap event
    }

    private func nextQuestion() {
        guard !vm.questions.isEmpty else { return }
        currentQuestionIndex = (currentQuestionIndex + 1) % vm.questions.count
        showResult = false
        isCorrect = false
    }
}
