import SwiftUI

struct QuizRushView: View {
    @EnvironmentObject private var sessions: SessionStore
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = QuizRushVM()

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.18), Color(uiColor: .systemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            switch viewModel.state {
            case .loading: loadingView
            case .failed(let message): errorView(message)
            case .loaded: questionView
            case .finished:
                ResultView(mode: .quizRush, score: viewModel.score, best: viewModel.highScore) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task { if viewModel.questions.isEmpty { await viewModel.load() } }
        .onChange(of: viewModel.state) { oldState, newState in
            if newState == .finished, oldState != .finished {
                sessions.record(mode: .quizRush, score: viewModel.score, coordinate: location.currentLocation?.coordinate)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large).tint(.purple)
            Text("Fetching your questions…").font(.headline)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn't Load Quiz", systemImage: "wifi.exclamationmark")
        } description: { Text(message) } actions: {
            Button("Retry") { Task { await viewModel.load() } }
                .buttonStyle(.borderedProminent).tint(.purple)
        }
    }

    private var questionView: some View {
        VStack(spacing: 18) {
            HStack {
                Label(viewModel.progressText, systemImage: "list.number")
                Spacer()
                Label("\(viewModel.streak)", systemImage: "flame.fill")
                Spacer()
                Label("\(viewModel.score)", systemImage: "star.fill")
            }
            .font(.subheadline.bold())
            ProgressView(value: Double(viewModel.questionIndex + 1), total: Double(max(1, viewModel.questions.count))).tint(.purple)
            if let question = viewModel.currentQuestion {
                Text(question.displayCategory.uppercased()).font(.caption.bold()).foregroundStyle(.purple)
                Spacer(minLength: 0)
                Text(question.displayQuestion)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    ForEach(viewModel.answers, id: \.self) { answer in
                        Button { viewModel.submit(answer) } label: {
                            HStack {
                                Text(answer).font(.headline).multilineTextAlignment(.leading)
                                Spacer()
                                if viewModel.selectedAnswer == answer {
                                    Image(systemName: viewModel.feedback == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding().frame(maxWidth: .infinity, minHeight: 58)
                            .background(answerColor(answer), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.purple.opacity(0.25)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(22)
        .modifier(QuizShakeEffect(shakes: viewModel.shakeCount))
        .animation(.easeInOut(duration: 0.2), value: viewModel.feedback)
    }

    private func answerColor(_ answer: String) -> Color {
        guard viewModel.selectedAnswer == answer else { return Color(uiColor: .secondarySystemBackground) }
        return viewModel.feedback == .correct ? .green.opacity(0.25) : .red.opacity(0.25)
    }
}

private struct QuizShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat
    init(shakes: Int) { self.shakes = shakes; animatableData = CGFloat(shakes) }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(animatableData * .pi * 4), y: 0))
    }
}
