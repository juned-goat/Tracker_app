import Foundation

protocol AuthRepository: Sendable {
    func currentUserSession() async throws -> UserSession?
    func signInWithEmail(email: String, password: String) async throws -> UserSession
    func signInWithGoogle() async throws -> UserSession
    func signOut() async throws
}
