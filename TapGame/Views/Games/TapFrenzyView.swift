import SwiftUI
import Combine

struct TapFrenzyView: View {
    @EnvironmentObject private var sessions: SessionStore
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = TapFrenzyVM()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if viewModel.isFinished {
                ResultView(mode: .tapFrenzy, score: viewModel.score, best: viewModel.highScore, playAgain: viewModel.restart)
            } else {
                VStack(spacing: 24) {
                    HStack {
                        ScoreBadge(label: "Score", value: "\(viewModel.score)")
                        ScoreBadge(label: "Best", value: "\(viewModel.highScore)")
                        ScoreBadge(label: "Time", value: "\(viewModel.timeRemaining)")
                    }
                    Spacer()
                    Button(action: viewModel.tap) {
                        Text(viewModel.isPlaying ? "TAP" : "START")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 230, height: 230)
                            .background(Color.blue.gradient)
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.5), radius: 20, y: 8)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("The timer starts with your first tap.").foregroundStyle(.secondary)
                }
                .padding(24)
            }
        }
        .navigationTitle("Tap Frenzy")
        .onReceive(timer) { _ in viewModel.tick() }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished { sessions.record(mode: .tapFrenzy, score: viewModel.score, coordinate: location.currentLocation?.coordinate) }
        }
    }
}
