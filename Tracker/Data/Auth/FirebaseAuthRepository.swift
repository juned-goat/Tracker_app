import Foundation

final class FirebaseAuthRepository: AuthRepository, @unchecked Sendable {
    private let authClient: any FirebaseAuthClient

    init(authClient: any FirebaseAuthClient = DefaultFirebaseAuthClient()) {
        self.authClient = authClient
    }

    func currentUserSession() async throws -> UserSession? {
        try await authClient.currentUser().map(Self.makeSession)
    }

    func signInWithEmail(email: String, password: String) async throws -> UserSession {
        do {
            let user = try await authClient.signInWithEmail(email: email, password: password)
            return Self.makeSession(from: user)
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    func signInWithGoogle() async throws -> UserSession {
        do {
            let user = try await authClient.signInWithGoogle()
            return Self.makeSession(from: user)
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    func signOut() async throws {
        do {
            try await authClient.signOut()
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    private static func makeSession(from user: FirebaseAuthUser) -> UserSession {
        UserSession(
            userID: user.userID,
            email: user.email,
            displayName: user.displayName,
            authProvider: authProvider(for: user)
        )
    }

    private static func authProvider(for user: FirebaseAuthUser) -> AuthProvider {
        if user.providerIDs.contains("google.com") {
            return .google
        }

        return .emailPassword
    }
}
