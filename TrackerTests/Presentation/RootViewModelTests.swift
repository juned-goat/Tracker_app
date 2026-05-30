import Testing
@testable import Tracker

struct RootViewModelTests {
    @MainActor
    @Test func loadSessionMovesToSignedOutWhenNoSessionExists() async {
        let dependencies = RootViewModelTestDependencies()
        let viewModel = dependencies.makeRootViewModel()

        await viewModel.loadSession()

        #expect(viewModel.state == .signedOut)
    }

    @MainActor
    @Test func loadSessionMovesToSignedInWhenSessionExists() async {
        let dependencies = RootViewModelTestDependencies(session: .emailSession)
        let viewModel = dependencies.makeRootViewModel()

        await viewModel.loadSession()

        #expect(viewModel.state == .signedIn(.emailSession))
    }

    @MainActor
    @Test func didSignInMovesToSignedIn() {
        let viewModel = RootViewModelTestDependencies().makeRootViewModel()

        viewModel.didSignIn(.googleSession)

        #expect(viewModel.state == .signedIn(.googleSession))
    }

    @MainActor
    @Test func signOutClearsSessionAndMovesToSignedOut() async {
        let dependencies = RootViewModelTestDependencies(session: .emailSession)
        let viewModel = dependencies.makeRootViewModel()

        await viewModel.signOut()

        #expect(viewModel.state == .signedOut)
        #expect(await dependencies.authRepository.signOutCount == 1)
    }

    @MainActor
    @Test func createsLoginViewModelThatCanSignInThroughRootFlow() async {
        let dependencies = RootViewModelTestDependencies()
        let viewModel = dependencies.makeRootViewModel()
        let loginViewModel = viewModel.makeLoginViewModel()

        loginViewModel.email = "email@example.com"
        loginViewModel.password = "secret"
        await loginViewModel.signInWithEmail()

        #expect(viewModel.state == .signedIn(.emailSession))
    }

    @MainActor
    @Test func createsHomeViewModelThatCanSignOutThroughRootFlow() async {
        let dependencies = RootViewModelTestDependencies(session: .emailSession)
        let viewModel = dependencies.makeRootViewModel()
        let homeViewModel = viewModel.makeHomeViewModel(for: .emailSession)

        homeViewModel.signOut()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.state == .signedOut)
    }
}

@MainActor
private struct RootViewModelTestDependencies {
    let authRepository: MockAuthRepository
    let mealRepository: InMemoryMealRepository
    let eventLogger: MockEventLogger

    init(session: UserSession? = nil) {
        authRepository = MockAuthRepository(currentSession: session)
        mealRepository = InMemoryMealRepository()
        eventLogger = MockEventLogger()
    }

    func makeRootViewModel() -> RootViewModel {
        RootViewModel(
            getCurrentSessionUseCase: GetCurrentSessionUseCase(authRepository: authRepository),
            signOutUseCase: SignOutUseCase(authRepository: authRepository),
            signInWithEmailUseCase: SignInWithEmailUseCase(
                authRepository: authRepository,
                eventLogger: eventLogger
            ),
            signInWithGoogleUseCase: SignInWithGoogleUseCase(
                authRepository: authRepository,
                eventLogger: eventLogger
            ),
            loadDailyProgressUseCase: LoadDailyProgressUseCase(
                mealRepository: mealRepository,
                eventLogger: eventLogger
            ),
            addMealUseCase: AddMealUseCase(
                mealRepository: mealRepository,
                eventLogger: eventLogger
            )
        )
    }
}

private extension UserSession {
    static let emailSession = UserSession(
        userID: "email-user",
        email: "email@example.com",
        displayName: nil,
        authProvider: .emailPassword
    )

    static let googleSession = UserSession(
        userID: "google-user",
        email: "google@example.com",
        displayName: "Google User",
        authProvider: .google
    )
}
