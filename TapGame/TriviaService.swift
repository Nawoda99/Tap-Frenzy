import Foundation

enum TriviaServiceError: LocalizedError {
    case invalidResponse
    case apiError(Int)
    case incompleteRound

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The trivia server returned an invalid response."
        case .apiError(let code):
            return "The trivia server could not create a quiz (code \(code))."
        case .incompleteRound:
            return "The server returned fewer than ten questions. Please retry."
        }
    }
}

struct TriviaService {
    private let endpoint = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    func fetchQuestions() async throws -> [TriviaQuestion] {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaServiceError.invalidResponse
        }

        let payload = try JSONDecoder().decode(TriviaResponse.self, from: data)
        guard payload.responseCode == 0 else {
            throw TriviaServiceError.apiError(payload.responseCode)
        }
        guard payload.results.count == 10 else {
            throw TriviaServiceError.incompleteRound
        }
        return payload.results
    }
}
