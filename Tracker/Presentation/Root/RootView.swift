import SwiftUI

struct RootView: View {
    @Environment(\.appDependencies) private var dependencies
    @State private var viewModel: RootViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(for: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                let createdViewModel = RootViewModel(
                    getCurrentSessionUseCase: dependencies.getCurrentSessionUseCase,
                    signOutUseCase: dependencies.signOutUseCase,
                    signInWithEmailUseCase: dependencies.signInWithEmailUseCase,
                    signInWithGoogleUseCase: dependencies.signInWithGoogleUseCase,
                    loadDailyProgressUseCase: dependencies.loadDailyProgressUseCase,
                    addMealUseCase: dependencies.addMealUseCase
                )
                viewModel = createdViewModel
                await createdViewModel.loadSession()
            }
        }
    }

    @ViewBuilder
    private func content(for viewModel: RootViewModel) -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .signedOut:
            LoginView(viewModel: viewModel.makeLoginViewModel())
        case .signedIn(let session):
            HomeView(viewModel: viewModel.makeHomeViewModel(for: session))
        case .failed(let message):
            ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle", description: Text(message))
        }
    }
}

#Preview {
    RootView()
        .environment(\.appDependencies, .live())
}
