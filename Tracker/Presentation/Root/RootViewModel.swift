import Foundation
import Observation

@Observable
@MainActor
final class RootViewModel {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn(UserSession)
        case failed(String)
    }

    private let getCurrentSessionUseCase: GetCurrentSessionUseCase
    private let signOutUseCase: SignOutUseCase
    private let signInWithEmailUseCase: SignInWithEmailUseCase
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    private let loadDailyProgressUseCase: LoadDailyProgressUseCase
    private let addMealUseCase: AddMealUseCase

    private(set) var state: State = .loading

    init(
        getCurrentSessionUseCase: GetCurrentSessionUseCase,
        signOutUseCase: SignOutUseCase,
        signInWithEmailUseCase: SignInWithEmailUseCase,
        signInWithGoogleUseCase: SignInWithGoogleUseCase,
        loadDailyProgressUseCase: LoadDailyProgressUseCase,
        addMealUseCase: AddMealUseCase
    ) {
        self.getCurrentSessionUseCase = getCurrentSessionUseCase
        self.signOutUseCase = signOutUseCase
        self.signInWithEmailUseCase = signInWithEmailUseCase
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.loadDailyProgressUseCase = loadDailyProgressUseCase
        self.addMealUseCase = addMealUseCase
    }

    func loadSession() async {
        do {
            if let session = try await getCurrentSessionUseCase.execute() {
                state = .signedIn(session)
            } else {
                state = .signedOut
            }
        } catch {
            state = .failed("Unable to load session.")
        }
    }

    func didSignIn(_ session: UserSession) {
        state = .signedIn(session)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            signInWithEmailUseCase: signInWithEmailUseCase,
            signInWithGoogleUseCase: signInWithGoogleUseCase,
            onSignedIn: didSignIn
        )
    }

    func makeHomeViewModel(for session: UserSession) -> HomeViewModel {
        HomeViewModel(
            session: session,
            loadDailyProgressUseCase: loadDailyProgressUseCase,
            addMealUseCase: addMealUseCase,
            onSignOut: {
                Task { await self.signOut() }
            }
        )
    }

    func signOut() async {
        do {
            try await signOutUseCase.execute()
            state = .signedOut
        } catch {
            state = .failed("Unable to sign out.")
        }
    }
}
