import SwiftUI

struct HomeTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("PLAYHUB").font(.caption.bold()).foregroundStyle(.purple)
                    Text("Choose your game").font(.largeTitle.bold())
                    Text("Three challenges. One place for every score.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink { TapFrenzyView() } label: {
                    GameModeCard(mode: .tapFrenzy, subtitle: "Tap as fast as you can", color: .blue)
                }
                NavigationLink { LightItUpView() } label: {
                    GameModeCard(mode: .lightItUp, subtitle: "Catch the glowing cards", color: .orange)
                }
                NavigationLink { QuizRushView() } label: {
                    GameModeCard(mode: .quizRush, subtitle: "Ten live trivia questions", color: .purple)
                }
            }
            .padding(20)
        }
        .navigationTitle("Home")
    }
}

private struct GameModeCard: View {
    let mode: GameMode
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: mode.icon)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title).font(.title3.bold()).foregroundStyle(.primary)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}
