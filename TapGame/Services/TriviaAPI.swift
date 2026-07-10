import Foundation

enum TriviaAPIError: LocalizedError {
    case invalidResponse
    case apiError(Int)
    case incompleteRound

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The trivia server returned an invalid response."
        case .apiError(let code): "The trivia server could not create a quiz (code \(code))."
        case .incompleteRound: "The server returned fewer than ten questions. Please retry."
        }
    }
}

struct TriviaAPI {
    private let endpoint = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    func fetchQuestions() async throws -> [TriviaQuestion] {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else { throw TriviaAPIError.invalidResponse }
        let payload = try JSONDecoder().decode(TriviaResponse.self, from: data)
        guard payload.responseCode == 0 else { throw TriviaAPIError.apiError(payload.responseCode) }
        guard payload.results.count == 10 else { throw TriviaAPIError.incompleteRound }
        return payload.results
    }
}
