import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let best: Int
    let playAgain: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.title) — beat that!"
    }

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 66))
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 14)
            Text("Round Complete!").font(.largeTitle.bold())
            HStack {
                ScoreBadge(label: "Score", value: "\(score)", icon: "star.fill")
                ScoreBadge(label: "Best", value: "\(best)", icon: "crown.fill")
            }
            Button("Play Again", action: playAgain)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            ShareLink(item: shareText) {
                Label("Share Your Score", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
