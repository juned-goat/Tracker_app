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

    private(set) var state: State = .loading

    init(
        getCurrentSessionUseCase: GetCurrentSessionUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.getCurrentSessionUseCase = getCurrentSessionUseCase
        self.signOutUseCase = signOutUseCase
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

    func signOut() async {
        do {
            try await signOutUseCase.execute()
            state = .signedOut
        } catch {
            state = .failed("Unable to sign out.")
        }
    }
}
