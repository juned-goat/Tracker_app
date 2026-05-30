import Foundation
@testable import Tracker

struct EmailSignInRequest: Equatable {
    let email: String
    let password: String
}

actor MockAuthRepository: AuthRepository {
    private(set) var currentSession: UserSession?
    private(set) var emailSignInRequests: [EmailSignInRequest] = []
    private(set) var googleSignInCount = 0
    private(set) var signOutCount = 0

    init(currentSession: UserSession? = nil) {
        self.currentSession = currentSession
    }

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

actor MockFirebaseAuthClient: FirebaseAuthClient {
    private(set) var currentUserValue: FirebaseAuthUser?
    private(set) var emailUser: FirebaseAuthUser
    private(set) var googleUser: FirebaseAuthUser
    private(set) var emailSignInRequests: [EmailSignInRequest] = []
    private(set) var googleSignInCount = 0
    private(set) var signOutCount = 0

    init(
        currentUser: FirebaseAuthUser? = nil,
        emailUser: FirebaseAuthUser = FirebaseAuthUser(
            userID: "email-user",
            email: "email@example.com",
            displayName: nil,
            providerIDs: ["password"]
        ),
        googleUser: FirebaseAuthUser = FirebaseAuthUser(
            userID: "google-user",
            email: "google@example.com",
            displayName: "Google User",
            providerIDs: ["google.com"]
        )
    ) {
        self.currentUserValue = currentUser
        self.emailUser = emailUser
        self.googleUser = googleUser
    }

    func currentUser() async throws -> FirebaseAuthUser? {
        currentUserValue
    }

    func signInWithEmail(email: String, password: String) async throws -> FirebaseAuthUser {
        emailSignInRequests.append(EmailSignInRequest(email: email, password: password))
        currentUserValue = emailUser
        return emailUser
    }

    func signInWithGoogle() async throws -> FirebaseAuthUser {
        googleSignInCount += 1
        currentUserValue = googleUser
        return googleUser
    }

    func signOut() async throws {
        signOutCount += 1
        currentUserValue = nil
    }
}

actor MockEventLogger: EventLogger {
    private(set) var events: [AnalyticsEvent] = []

    var eventNames: [AnalyticsEventName] {
        events.map(\.name)
    }

    func log(_ event: AnalyticsEvent) async {
        events.append(event)
    }
}
