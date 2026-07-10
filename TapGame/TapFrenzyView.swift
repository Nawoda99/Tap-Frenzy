import SwiftUI
import Combine

struct TapFrenzyView: View {
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameStarted = false
    @State private var showingResult = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                StatView(label: "SCORE", value: "\(score)")
                Spacer()
                StatView(label: "BEST", value: "\(highScore)")
                Spacer()
                StatView(label: "TIME", value: "\(timeRemaining)")
            }

            Spacer()

            Button(action: tapped) {
                Text(gameStarted ? "TAP" : "START")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 230, height: 230)
                    .background(Color.blue.gradient)
                    .clipShape(Circle())
                    .shadow(color: .blue.opacity(0.5), radius: 20, y: 8)
            }
            .buttonStyle(.plain)

            Spacer()
            Text("The timer starts with your first tap.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("Tap Frenzy")
        .onReceive(timer) { _ in tick() }
        .alert("Time's Up!", isPresented: $showingResult) {
            Button("Play Again", action: restart)
        } message: {
            Text("Score: \(score)  •  Best: \(highScore)")
        }
    }

    private func tapped() {
        if !gameStarted { gameStarted = true }
        score += 1
    }

    private func tick() {
        guard gameStarted, !showingResult else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 {
            gameStarted = false
            highScore = max(highScore, score)
            showingResult = true
        }
    }

    private func restart() {
        score = 0
        timeRemaining = 10
        gameStarted = false
    }
}

struct StatView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
            Text(value).font(.title2.monospacedDigit().bold())
        }
    }
}
