import SwiftUI

struct Question {
    let text: String
    let options: [String]
    let answer: String
}

let sampleQuestions = [
    Question(text: "What is the capital of France?",
             options: ["Berlin", "Madrid", "Paris", "Rome"],
             answer: "Paris"),
    
    Question(text: "What is 2 + 2?",
             options: ["3", "4", "5", "6"],
             answer: "4")
]

struct ContentView: View {
    @State private var currentQuestionIndex = 0
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var points = 0

    let questions = sampleQuestions

    var body: some View {
        let question = questions[currentQuestionIndex]

        VStack(spacing: 20) {
            Text(question.text)
                .font(.title)
                .multilineTextAlignment(.center)

            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    checkAnswer(option)
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if showResult {
                if isCorrect {
                    VStack {
                        Text("✅ Correct!")
                            .font(.headline)
                            .foregroundColor(.green)
                        //                        Button("Increase Score"){
                        //                            incrementPoints()
                        //                        }
                        //Text("\(incrementPoints())")
                        Text("Score: \(points)")
                                    .onAppear {
                                        incrementPoints()
                                    }
                    }
                } else {
                    VStack {
                        Text("❌ Wrong")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                
                Button("Next Question") {
                                    nextQuestion()
                                }
                                .padding(.top, 10)
            }

        }
        .padding()
    }

    func checkAnswer(_ selected: String) {
        let correct = questions[currentQuestionIndex].answer
        isCorrect = (selected == correct)
        showResult = true
    }

    func nextQuestion() {
        currentQuestionIndex = (currentQuestionIndex + 1) % questions.count
        showResult = false
    }
    
    func incrementPoints() {
        points += 1
    }
}
