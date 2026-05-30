import Foundation
@testable import Tracker

struct EmailSignInRequest: Equatable {
    let email: String
    let password: String
}

actor SpyAuthRepository: AuthRepository {
    private(set) var currentSession: UserSession?
    private(set) var emailSignInRequests: [EmailSignInRequest] = []
    private(set) var googleSignInCount = 0
    private(set) var signOutCount = 0

    func currentUserSession() async throws -> UserSession? {
        currentSession
    }

    func signInWithEmail(email: String, password: String) async throws -> UserSession {
        emailSignInRequests.append(EmailSignInRequest(email: email, password: password))
        let session = UserSession(
            userID: "email-user",
            email: email,
            displayName: nil,
            authProvider: .emailPassword
        )
        currentSession = session
        return session
    }

    func signInWithGoogle() async throws -> UserSession {
        googleSignInCount += 1
        let session = UserSession(
            userID: "google-user",
            email: "google@example.com",
            displayName: "Google User",
            authProvider: .google
        )
        currentSession = session
        return session
    }

    func signOut() async throws {
        signOutCount += 1
        currentSession = nil
    }
}

actor SpyEventLogger: EventLogger {
    private(set) var events: [AnalyticsEvent] = []

    var eventNames: [AnalyticsEventName] {
        events.map(\.name)
    }

    func log(_ event: AnalyticsEvent) async {
        events.append(event)
    }
}
