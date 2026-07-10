import Foundation
import Combine

@MainActor
final class QuizRushViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case loaded
        case failed(String)
        case finished
    }

    enum AnswerFeedback: Equatable {
        case none
        case correct
        case wrong
    }

    @Published private(set) var state: ViewState = .loading
    @Published private(set) var questions: [TriviaQuestion] = []
    @Published private(set) var questionIndex = 0
    @Published private(set) var answers: [String] = []
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var highScore = UserDefaults.standard.integer(forKey: "quizRushHighScore")
    @Published private(set) var feedback: AnswerFeedback = .none
    @Published private(set) var selectedAnswer: String?
    @Published private(set) var shakeCount = 0

    private let service: TriviaService
    private var isAnswerLocked = false

    init(service: TriviaService = TriviaService()) {
        self.service = service
    }

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(questionIndex) else { return nil }
        return questions[questionIndex]
    }

    var progressText: String {
        "\(min(questionIndex + 1, questions.count)) of \(questions.count)"
    }

    func load() async {
        state = .loading
        score = 0
        streak = 0
        questionIndex = 0
        feedback = .none
        selectedAnswer = nil
        isAnswerLocked = false

        do {
            questions = try await service.fetchQuestions()
            prepareCurrentQuestion()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func submit(_ answer: String) {
        guard !isAnswerLocked, let question = currentQuestion else { return }
        isAnswerLocked = true
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
            prepareCurrentQuestion()
        } else {
            highScore = max(highScore, score)
            UserDefaults.standard.set(highScore, forKey: "quizRushHighScore")
            state = .finished
        }
    }

    private func prepareCurrentQuestion() {
        answers = currentQuestion?.allAnswers ?? []
        feedback = .none
        selectedAnswer = nil
        isAnswerLocked = false
    }
}
