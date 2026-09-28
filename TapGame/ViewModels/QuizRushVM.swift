import Foundation
import Combine

@MainActor
final class QuizRushVM: ObservableObject {
    enum ViewState: Equatable { case loading, loaded, failed(String), finished }
    enum Feedback: Equatable { case none, correct, wrong }

    @Published private(set) var state: ViewState = .loading
    @Published private(set) var questions: [TriviaQuestion] = []
    @Published private(set) var questionIndex = 0
    @Published private(set) var answers: [String] = []
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var feedback: Feedback = .none
    @Published private(set) var selectedAnswer: String?
    @Published private(set) var shakeCount = 0
    @Published private(set) var highScore = UserDefaults.standard.integer(forKey: "quizRushHighScore")

    private let api = TriviaAPI()
    private var answerLocked = false

    var currentQuestion: TriviaQuestion? {
        questions.indices.contains(questionIndex) ? questions[questionIndex] : nil
    }
    var progressText: String { "\(min(questionIndex + 1, questions.count)) of \(questions.count)" }

    func load() async {
        state = .loading
        score = 0
        streak = 0
        questionIndex = 0
        do {
            questions = try await api.fetchQuestions()
            prepareQuestion()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func submit(_ answer: String) {
        guard !answerLocked, let question = currentQuestion else { return }
        answerLocked = true
        selectedAnswer = answer
        if answer == question.displayCorrectAnswer {
            streak += 1
            score += 10 + max(0, streak - 1) * 2
            feedback = .correct
        } else {
            streak = 0
            score = max(0, score - 2)
            shakeCount += 1
            feedback = .wrong
        }
        Task {
            try? await Task.sleep(for: .milliseconds(550))
            advance()
        }
    }

    private func advance() {
        if questionIndex + 1 < questions.count {
            questionIndex += 1
            prepareQuestion()
        } else {
            highScore = max(highScore, score)
            UserDefaults.standard.set(highScore, forKey: "quizRushHighScore")
            state = .finished
        }
    }

    private func prepareQuestion() {
        answers = currentQuestion?.allAnswers ?? []
        feedback = .none
        selectedAnswer = nil
        answerLocked = false
    }
}
