import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable, Hashable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tapFrenzy: "Tap Frenzy"
        case .lightItUp: "Light It Up"
        case .quizRush: "Quiz Rush"
        }
    }

    var icon: String {
        switch self {
        case .tapFrenzy: "hand.tap.fill"
        case .lightItUp: "lightbulb.fill"
        case .quizRush: "questionmark.bubble.fill"
        }
    }
}
