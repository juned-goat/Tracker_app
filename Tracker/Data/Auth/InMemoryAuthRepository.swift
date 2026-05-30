import Foundation

actor InMemoryAuthRepository: AuthRepository {
    private var currentSession: UserSession?

    func currentUserSession() async throws -> UserSession? {
        currentSession
    }

    func signInWithEmail(email: String, password: String) async throws -> UserSession {
        let session = UserSession(
            userID: "local-email-user",
            email: email,
            displayName: nil,
            authProvider: .emailPassword
        )
        currentSession = session
        return session
    }

    func signInWithGoogle() async throws -> UserSession {
        let session = UserSession(
            userID: "local-google-user",
            email: "google-user@example.com",
            displayName: "Google User",
            authProvider: .google
        )
        currentSession = session
        return session
    }

    func signOut() async throws {
        currentSession = nil
    }
}
