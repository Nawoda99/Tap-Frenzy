import SwiftUI
import Combine

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 30) {

            Text("Score: \(score)")
                .font(.largeTitle)
                .bold()

            Text("Time: \(timeRemaining)")
                .font(.title)

            Spacer()

            Button(action: {
                tapButtonPressed()
            }) {
                Text("TAP")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 220, height: 220)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .disabled(gameOver)

            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            guard gameStarted && !gameOver else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            }

            if timeRemaining == 0 {
                endGame()
            }
        }
        .sheet(isPresented: $gameOver) {
            GameOverView(
                score: score,
                highScore: highScore,
                playAgain: restartGame
            )
        }
    }

    func tapButtonPressed() {
        if !gameStarted {
            gameStarted = true
        }

        score += 1
    }

    func endGame() {
        gameOver = true

        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
        gameStarted = false
        gameOver = false
    }
}

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let playAgain: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("GAME OVER")
                .font(.largeTitle)
                .bold()

            Text("Final Score: \(score)")
                .font(.title)

            Text("High Score: \(highScore)")
                .font(.title2)

            Button("Play Again") {
                playAgain()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
