import Foundation
import Combine
import CoreLocation

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "playHubGameSessions"

    init() {
        load()
    }

    func record(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D?) {
        sessions.insert(GameSession(mode: mode, score: score, coordinate: coordinate), at: 0)
        save()
    }

    func reset() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
        for key in ["tapFrenzyHighScore", "lightItUpHighScore", "quizRushHighScore"] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data) else { return }
        sessions = decoded.sorted { $0.timestamp > $1.timestamp }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
