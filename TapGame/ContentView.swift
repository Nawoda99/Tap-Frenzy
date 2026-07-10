import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.indigo.opacity(0.9), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Spacer()

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.yellow)
                        .shadow(color: .yellow.opacity(0.8), radius: 18)

                    Text("Tap Games")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Choose your challenge")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    NavigationLink {
                        TapFrenzyView()
                    } label: {
                        ModeButton(title: "Tap Frenzy", subtitle: "Tap as fast as you can", icon: "hand.tap.fill", color: .blue)
                    }

                    NavigationLink {
                        LightItUpView()
                    } label: {
                        ModeButton(title: "Light It Up", subtitle: "Catch the glowing cards", icon: "lightbulb.fill", color: .orange)
                    }

                    NavigationLink {
                        QuizRushView()
                    } label: {
                        ModeButton(title: "Quiz Rush", subtitle: "Ten live trivia questions", icon: "brain.head.profile.fill", color: .purple)
                    }

                    Spacer()
                }
                .padding(24)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct ModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 52, height: 52)
                .background(color.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.title2.bold())
                Text(subtitle).font(.subheadline).opacity(0.7)
            }

            Spacer()
            Image(systemName: "chevron.right").font(.headline)
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(color.opacity(0.6), lineWidth: 1))
    }
}

#Preview {
    ContentView()
}
