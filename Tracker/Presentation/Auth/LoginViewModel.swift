import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    enum State: Equatable {
        case idle
        case loading
        case failed(String)
    }

    var email = ""
    var password = ""
    private(set) var state: State = .idle

    private let signInWithEmailUseCase: SignInWithEmailUseCase
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    private let onSignedIn: @MainActor (UserSession) -> Void

    init(
        signInWithEmailUseCase: SignInWithEmailUseCase,
        signInWithGoogleUseCase: SignInWithGoogleUseCase,
        onSignedIn: @escaping @MainActor (UserSession) -> Void
    ) {
        self.signInWithEmailUseCase = signInWithEmailUseCase
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.onSignedIn = onSignedIn
    }

    func signInWithEmail() async {
        state = .loading
        do {
            let session = try await signInWithEmailUseCase.execute(email: email, password: password)
            state = .idle
            onSignedIn(session)
        } catch {
            state = .failed("Email sign-in failed.")
        }
    }

    func signInWithGoogle() async {
        state = .loading
        do {
            let session = try await signInWithGoogleUseCase.execute()
            state = .idle
            onSignedIn(session)
        } catch {
            state = .failed("Google sign-in failed.")
        }
    }
}
