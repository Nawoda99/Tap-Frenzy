import SwiftUI
import Combine

struct LightItUpView: View {
    @EnvironmentObject private var sessions: SessionStore
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = LightItUpVM()
    @State private var roundLength = 60
    @State private var showingSettings = false
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 14), count: viewModel.level.columns)
    }

    var body: some View {
        ZStack {
            if viewModel.isFinished {
                ResultView(mode: .lightItUp, score: viewModel.score, best: viewModel.highScore, playAgain: viewModel.restart)
            } else {
                gameContent
            }

            if viewModel.levelFlash {
                viewModel.level.color.opacity(0.28).ignoresSafeArea()
                Text("LEVEL \(viewModel.level.rawValue)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: viewModel.level.color, radius: 18)
            }
        }
        .navigationTitle("Light It Up")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingSettings = true } label: { Image(systemName: "gearshape.fill") }
                    .disabled(viewModel.isPlaying)
            }
        }
        .onReceive(clock) { viewModel.update(at: $0) }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished { sessions.record(mode: .lightItUp, score: viewModel.score, coordinate: location.currentLocation?.coordinate) }
        }
        .sheet(isPresented: $showingSettings) { RoundSettingsView(roundLength: $roundLength) }
    }

    private var gameContent: some View {
        VStack(spacing: 18) {
            HStack {
                ScoreBadge(label: "Score", value: "\(viewModel.score)")
                ScoreBadge(label: "Level", value: "\(viewModel.level.rawValue)")
                ScoreBadge(label: "Time", value: "\(viewModel.timeRemaining)")
            }
            HStack {
                Text("Best \(viewModel.highScore)").bold()
                Spacer()
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                        .foregroundStyle(index < viewModel.lives ? .red : .secondary)
                }
            }
            Spacer(minLength: 4)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.cards.indices, id: \.self) { index in
                    Button { viewModel.tapCard(at: index) } label: {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(viewModel.cards[index].isLit ? viewModel.level.color.gradient : Color.secondary.opacity(0.18).gradient)
                            .overlay {
                                Image(systemName: viewModel.cards[index].isLit ? "bolt.fill" : "circle.fill")
                                    .font(.title)
                                    .foregroundStyle(viewModel.cards[index].isLit ? .white : .secondary.opacity(0.25))
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .scaleEffect(viewModel.cards[index].isLit ? 1.06 : 1)
                            .shadow(color: viewModel.cards[index].isLit ? viewModel.level.color.opacity(0.85) : .clear, radius: 16)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.isPlaying)
                }
            }
            .animation(.spring(response: 0.25), value: viewModel.cards.map(\.isLit))
            Spacer(minLength: 4)
            if !viewModel.isPlaying {
                Button("Start \(roundLength)-Second Round") { viewModel.start(roundLength: roundLength) }
                    .buttonStyle(.borderedProminent).controlSize(.large).tint(viewModel.level.color)
            } else {
                Text("Tap only the glowing cards").foregroundStyle(.secondary)
            }
        }
        .padding(20)
    }
}

private struct RoundSettingsView: View {
    @Binding var roundLength: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Picker("Round length", selection: $roundLength) {
                    Text("30 seconds").tag(30); Text("60 seconds").tag(60); Text("90 seconds").tag(90)
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Round Settings")
            .toolbar { Button("Done") { dismiss() } }
        }
        .presentationDetents([.medium])
    }
}
