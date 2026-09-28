import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject private var store: SessionStore
    @StateObject private var viewModel = StatsVM()

    var body: some View {
        ScrollView {
            if viewModel.sessions.isEmpty {
                ContentUnavailableView("No Games Yet", systemImage: "chart.bar", description: Text("Complete a game to build your stats."))
                    .padding(.top, 80)
            } else {
                VStack(spacing: 20) {
                    HStack {
                        ScoreBadge(label: "Games", value: "\(viewModel.totalGames)")
                        ScoreBadge(label: "Total points", value: "\(viewModel.totalScore)")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Bests").font(.headline)
                        ForEach(GameMode.allCases) { mode in
                            HStack {
                                Label(mode.title, systemImage: mode.icon)
                                Spacer()
                                Text("\(viewModel.best(for: mode))").bold()
                            }
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scores by Mode").font(.headline)
                        Chart(viewModel.sessions) { session in
                            BarMark(x: .value("Mode", session.mode.title), y: .value("Score", session.score))
                                .foregroundStyle(by: .value("Mode", session.mode.title))
                                .position(by: .value("Game", session.id.uuidString))
                        }
                        .frame(height: 230)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recent Games").font(.headline).padding(.bottom, 6)
                        ForEach(viewModel.recentSessions) { session in
                            HStack {
                                Image(systemName: session.mode.icon).foregroundStyle(.purple)
                                VStack(alignment: .leading) {
                                    Text(session.mode.title).bold()
                                    Text(session.timestamp, style: .relative).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(session.score)").font(.title3.bold())
                            }
                            .padding(.vertical, 7)
                            if session.id != viewModel.recentSessions.last?.id { Divider() }
                        }
                    }
                    .cardStyle()
                }
                .padding(20)
            }
        }
        .navigationTitle("Stats")
        .onAppear { viewModel.update(with: store.sessions) }
        .onChange(of: store.sessions) { _, sessions in viewModel.update(with: sessions) }
    }
}

private extension View {
    func cardStyle() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}
