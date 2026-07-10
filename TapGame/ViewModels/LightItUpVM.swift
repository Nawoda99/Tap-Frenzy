import SwiftUI
import Combine

struct LightCard: Identifiable {
    let id = UUID()
    var isLit = false
}

enum GameLevel: Int, CaseIterable {
    case one = 1, two, three, four
    var cardCount: Int { [3, 4, 6, 9][rawValue - 1] }
    var columns: Int { [3, 2, 3, 3][rawValue - 1] }
    var litDuration: TimeInterval { [1.5, 1.2, 1.0, 0.8][rawValue - 1] }
    var litCount: Int { self == .four ? 2 : 1 }
    var color: Color { [.cyan, .green, .orange, .pink][rawValue - 1] }
}

@MainActor
final class LightItUpVM: ObservableObject {
    @Published private(set) var cards = (0..<3).map { _ in LightCard() }
    @Published private(set) var score = 0
    @Published private(set) var lives = 3
    @Published private(set) var elapsed = 0
    @Published private(set) var level = GameLevel.one
    @Published private(set) var isPlaying = false
    @Published private(set) var isFinished = false
    @Published private(set) var levelFlash = false
    @Published private(set) var highScore = UserDefaults.standard.integer(forKey: "lightItUpHighScore")
    var roundLength = 60

    private var nextLightTime = Date.distantFuture
    private var roundStartDate = Date()

    var timeRemaining: Int { max(0, roundLength - elapsed) }

    func start(roundLength: Int) {
        self.roundLength = roundLength
        score = 0
        lives = 3
        elapsed = 0
        level = .one
        isFinished = false
        rebuildCards()
        roundStartDate = Date()
        isPlaying = true
        nextLightTime = Date()
    }

    func update(at now: Date) {
        guard isPlaying else { return }
        elapsed = max(0, Int(now.timeIntervalSince(roundStartDate)))
        updateLevel()
        if elapsed >= roundLength {
            finish()
        } else if now >= nextLightTime {
            lightNewCards()
            nextLightTime = now.addingTimeInterval(level.litDuration)
        }
    }

    func tapCard(at index: Int) {
        guard isPlaying, cards.indices.contains(index) else { return }
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            lives = max(0, lives - 1)
            if lives == 0 { finish() }
        }
    }

    func restart() {
        score = 0
        lives = 3
        elapsed = 0
        level = .one
        isFinished = false
        rebuildCards()
    }

    private func updateLevel() {
        let segment = Double(roundLength) / 4
        let raw = min(4, Int(Double(elapsed) / segment) + 1)
        guard let newLevel = GameLevel(rawValue: raw), newLevel != level else { return }
        level = newLevel
        rebuildCards()
        levelFlash = true
        nextLightTime = Date()
        Task {
            try? await Task.sleep(for: .milliseconds(650))
            levelFlash = false
        }
    }

    private func rebuildCards() {
        cards = (0..<level.cardCount).map { _ in LightCard() }
    }

    private func lightNewCards() {
        let misses = cards.filter(\.isLit).count
        if misses > 0 {
            lives = max(0, lives - misses)
            if lives == 0 { finish(); return }
        }
        cards.indices.forEach { cards[$0].isLit = false }
        cards.indices.shuffled().prefix(level.litCount).forEach { cards[$0].isLit = true }
    }

    private func finish() {
        guard isPlaying else { return }
        isPlaying = false
        isFinished = true
        cards.indices.forEach { cards[$0].isLit = false }
        highScore = max(highScore, score)
        UserDefaults.standard.set(highScore, forKey: "lightItUpHighScore")
    }
}
