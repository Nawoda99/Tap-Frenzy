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

struct LightItUpView: View {
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @State private var cards = (0..<3).map { _ in LightCard() }
    @State private var score = 0
    @State private var lives = 3
    @State private var elapsed = 0
    @State private var roundLength = 60
    @State private var level = GameLevel.one
    @State private var isPlaying = false
    @State private var showingResult = false
    @State private var showingSettings = false
    @State private var levelFlash = false
    @State private var nextLightTime = Date.distantFuture

    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var timeRemaining: Int { max(0, roundLength - elapsed) }
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 14), count: level.columns)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    StatView(label: "SCORE", value: "\(score)")
                    Spacer()
                    StatView(label: "LEVEL", value: "\(level.rawValue)")
                    Spacer()
                    StatView(label: "TIME", value: "\(timeRemaining)")
                }

                HStack {
                    Label("Best \(highScore)", systemImage: "trophy.fill")
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundStyle(index < lives ? .red : .secondary)
                        }
                    }
                }
                .font(.subheadline.bold())

                Spacer(minLength: 8)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(cards.indices, id: \.self) { index in
                        Button { cardTapped(at: index) } label: {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cards[index].isLit ? level.color.gradient : Color.secondary.opacity(0.18).gradient)
                                .overlay {
                                    Image(systemName: cards[index].isLit ? "bolt.fill" : "circle.fill")
                                        .font(.title)
                                        .foregroundStyle(cards[index].isLit ? .white : .secondary.opacity(0.25))
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .scaleEffect(cards[index].isLit ? 1.06 : 1)
                                .shadow(color: cards[index].isLit ? level.color.opacity(0.85) : .clear, radius: 16)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isPlaying)
                    }
                }
                .animation(.spring(response: 0.25), value: cards.map(\.isLit))

                Spacer(minLength: 8)

                if !isPlaying {
                    Button("Start Round", action: startRound)
                        .font(.headline)
                        .buttonStyle(.borderedProminent)
                        .tint(level.color)
                        .controlSize(.large)
                } else {
                    Text("Tap only the glowing cards")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)

            if levelFlash {
                level.color.opacity(0.28).ignoresSafeArea()
                Text("LEVEL \(level.rawValue)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: level.color, radius: 18)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Light It Up")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingSettings = true } label: { Image(systemName: "gearshape.fill") }
                    .disabled(isPlaying)
            }
        }
        .onReceive(clock) { now in updateGame(at: now) }
        .sheet(isPresented: $showingSettings) {
            SettingsView(roundLength: $roundLength)
        }
        .alert(lives == 0 ? "Out of Lives!" : "Round Complete!", isPresented: $showingResult) {
            Button("Play Again", action: resetRound)
        } message: {
            Text("Score: \(score)  •  Best: \(highScore)")
        }
    }

    private func startRound() {
        score = 0
        lives = 3
        elapsed = 0
        level = .one
        rebuildCards()
        roundStartDate = Date()
        isPlaying = true
        nextLightTime = Date()
    }

    private func updateGame(at now: Date) {
        guard isPlaying else { return }
        let newElapsed = roundLength - timeRemainingFromDates(now)
        if newElapsed != elapsed {
            elapsed = newElapsed
            updateLevel()
        }
        if elapsed >= roundLength {
            finishRound()
        } else if now >= nextLightTime {
            lightNewCards()
            nextLightTime = now.addingTimeInterval(level.litDuration)
        }
    }

    private func timeRemainingFromDates(_ now: Date) -> Int {
        max(0, roundLength - Int(now.timeIntervalSince(roundStartDate)))
    }

    @State private var roundStartDate = Date()

    private func updateLevel() {
        let segment = Double(roundLength) / 4.0
        let raw = min(4, Int(Double(elapsed) / segment) + 1)
        guard let newLevel = GameLevel(rawValue: raw), newLevel != level else { return }
        level = newLevel
        rebuildCards()
        showLevelFlash()
        nextLightTime = Date()
    }

    private func rebuildCards() {
        cards = (0..<level.cardCount).map { _ in LightCard() }
    }

    private func lightNewCards() {
        let missed = cards.filter(\.isLit).count
        if missed > 0 {
            lives = max(0, lives - missed)
            if lives == 0 { finishRound(); return }
        }
        for index in cards.indices { cards[index].isLit = false }
        for index in cards.indices.shuffled().prefix(level.litCount) { cards[index].isLit = true }
    }

    private func cardTapped(at index: Int) {
        guard cards.indices.contains(index) else { return }
        if cards[index].isLit {
            score += 1
            withAnimation { cards[index].isLit = false }
        } else {
            lives = max(0, lives - 1)
            if lives == 0 { finishRound() }
        }
    }

    private func showLevelFlash() {
        withAnimation { levelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation { levelFlash = false }
        }
    }

    private func finishRound() {
        guard isPlaying else { return }
        isPlaying = false
        cards.indices.forEach { cards[$0].isLit = false }
        highScore = max(highScore, score)
        showingResult = true
    }

    private func resetRound() {
        score = 0
        lives = 3
        elapsed = 0
        level = .one
        rebuildCards()
    }
}

private struct SettingsView: View {
    @Binding var roundLength: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Round length") {
                    Picker("Duration", selection: $roundLength) {
                        Text("30 seconds").tag(30)
                        Text("60 seconds").tag(60)
                        Text("90 seconds").tag(90)
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Settings")
            .toolbar { Button("Done") { dismiss() } }
        }
        .presentationDetents([.medium])
    }
}
