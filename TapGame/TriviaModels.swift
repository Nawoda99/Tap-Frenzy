import Foundation

struct TriviaResponse: Decodable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Decodable, Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    var displayQuestion: String { question.decodingHTMLEntities() }
    var displayCategory: String { category.decodingHTMLEntities() }
    var displayCorrectAnswer: String { correctAnswer.decodingHTMLEntities() }
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).map { $0.decodingHTMLEntities() }.shuffled()
    }
}

private extension String {
    func decodingHTMLEntities() -> String {
        guard let data = data(using: .utf8),
              let decoded = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ).string else {
            return self
        }
        return decoded
    }
}
