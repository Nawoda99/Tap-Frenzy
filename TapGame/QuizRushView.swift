import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.18), Color(uiColor: .systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch viewModel.state {
            case .loading:
                loadingView
            case .failed(let message):
                errorView(message: message)
            case .loaded:
                questionView
            case .finished:
                resultView
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.questions.isEmpty {
                await viewModel.load()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 18) {
            ProgressView().controlSize(.large).tint(.purple)
            Text("Fetching your questions…")
                .font(.headline)
            Text("Open Trivia DB")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn't Load Quiz", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }

    private var questionView: some View {
        VStack(spacing: 20) {
            HStack {
                Label(viewModel.progressText, systemImage: "list.number")
                Spacer()
                Label("\(viewModel.streak)", systemImage: "flame.fill")
                    .foregroundStyle(viewModel.streak > 1 ? .orange : .secondary)
                Spacer()
                Label("\(viewModel.score)", systemImage: "star.fill")
            }
            .font(.subheadline.bold())

            ProgressView(value: Double(viewModel.questionIndex + 1), total: Double(max(1, viewModel.questions.count)))
                .tint(.purple)

            if let question = viewModel.currentQuestion {
                VStack(spacing: 8) {
                    Text(question.displayCategory.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(.purple)
                    Text(question.difficulty.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text(question.displayQuestion)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    ForEach(viewModel.answers, id: \.self) { answer in
                        Button { viewModel.submit(answer) } label: {
                            HStack {
                                Text(answer)
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                answerIcon(for: answer)
                            }
                            .foregroundStyle(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(answerColor(for: answer), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.purple.opacity(0.25)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(24)
        .modifier(ShakeEffect(shakes: viewModel.shakeCount))
        .animation(.easeInOut(duration: 0.2), value: viewModel.feedback)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 14)
            Text("Quiz Complete!").font(.largeTitle.bold())
            Text("\(viewModel.score) points").font(.title)
            Text("Best: \(viewModel.highScore)").foregroundStyle(.secondary)
            Button("Play Again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .controlSize(.large)
        }
    }

    @ViewBuilder
    private func answerIcon(for answer: String) -> some View {
        if viewModel.selectedAnswer == answer {
            Image(systemName: viewModel.feedback == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(viewModel.feedback == .correct ? .green : .red)
        }
    }

    private func answerColor(for answer: String) -> Color {
        guard viewModel.selectedAnswer == answer else { return Color(uiColor: .secondarySystemBackground) }
        return viewModel.feedback == .correct ? .green.opacity(0.25) : .red.opacity(0.25)
    }
}

private struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat

    init(shakes: Int) {
        self.shakes = shakes
        animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 8 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
