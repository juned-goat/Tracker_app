import Testing
@testable import Tracker

struct FirebaseAuthRepositoryTests {
    @Test func currentSessionMapsFirebaseUserToEmailPasswordSession() async throws {
        let client = MockFirebaseAuthClient(currentUser: .emailUser)
        let repository = FirebaseAuthRepository(authClient: client)

        let session = try await repository.currentUserSession()

        #expect(session == UserSession(
            userID: "email-user",
            email: "email@example.com",
            displayName: "Email User",
            authProvider: .emailPassword
        ))
    }

    @Test func googleSignInMapsGoogleProviderToGoogleSession() async throws {
        let client = MockFirebaseAuthClient(googleUser: .googleUser)
        let repository = FirebaseAuthRepository(authClient: client)

        let session = try await repository.signInWithGoogle()

        #expect(session.authProvider == .google)
        #expect(session.userID == "google-user")
        #expect(await client.googleSignInCount == 1)
    }

    @Test func emailSignInDelegatesCredentialsToFirebaseClient() async throws {
        let client = MockFirebaseAuthClient(emailUser: .emailUser)
        let repository = FirebaseAuthRepository(authClient: client)

        let session = try await repository.signInWithEmail(
            email: "email@example.com",
            password: "secret"
        )

        #expect(session.authProvider == .emailPassword)
        #expect(await client.emailSignInRequests == [
            EmailSignInRequest(email: "email@example.com", password: "secret")
        ])
    }

    @Test func signOutDelegatesToFirebaseClient() async throws {
        let client = MockFirebaseAuthClient()
        let repository = FirebaseAuthRepository(authClient: client)

        try await repository.signOut()

        #expect(await client.signOutCount == 1)
    }
}

private extension FirebaseAuthUser {
    static let emailUser = FirebaseAuthUser(
        userID: "email-user",
        email: "email@example.com",
        displayName: "Email User",
        providerIDs: ["password"]
    )

    static let googleUser = FirebaseAuthUser(
        userID: "google-user",
        email: "google@example.com",
        displayName: "Google User",
        providerIDs: ["google.com"]
    )
}
