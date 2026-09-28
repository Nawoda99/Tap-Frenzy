import Foundation
import Combine

@MainActor
final class TapFrenzyVM: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var timeRemaining = 10
    @Published private(set) var isPlaying = false
    @Published private(set) var isFinished = false
    @Published private(set) var highScore = UserDefaults.standard.integer(forKey: "tapFrenzyHighScore")

    func tap() {
        if !isPlaying { isPlaying = true }
        guard !isFinished else { return }
        score += 1
    }

    func tick() {
        guard isPlaying, !isFinished else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 { finish() }
    }

    func restart() {
        score = 0
        timeRemaining = 10
        isPlaying = false
        isFinished = false
    }

    private func finish() {
        isPlaying = false
        isFinished = true
        highScore = max(highScore, score)
        UserDefaults.standard.set(highScore, forKey: "tapFrenzyHighScore")
    }
}
