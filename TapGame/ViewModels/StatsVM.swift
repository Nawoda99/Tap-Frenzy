import Foundation
import Combine

@MainActor
final class StatsVM: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    var totalGames: Int { sessions.count }
    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }
    var recentSessions: [GameSession] { Array(sessions.prefix(8)) }

    func update(with sessions: [GameSession]) {
        self.sessions = sessions
    }

    func best(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }
}
