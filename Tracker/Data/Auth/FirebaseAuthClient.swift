import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

struct FirebaseAuthUser: Equatable, Sendable {
    let userID: String
    let email: String?
    let displayName: String?
    let providerIDs: [String]
}

protocol FirebaseAuthClient: Sendable {
    func currentUser() async throws -> FirebaseAuthUser?
    func signInWithEmail(email: String, password: String) async throws -> FirebaseAuthUser
    func signInWithGoogle() async throws -> FirebaseAuthUser
    func signOut() async throws
}

final class DefaultFirebaseAuthClient: FirebaseAuthClient, @unchecked Sendable {
    private let auth: Auth
    private let firebaseAppProvider: @Sendable () -> FirebaseApp?
    private let topMostViewControllerProvider: @MainActor @Sendable () -> UIViewController?

    init(
        auth: Auth = Auth.auth(),
        firebaseAppProvider: @escaping @Sendable () -> FirebaseApp? = { FirebaseApp.app() },
        topMostViewControllerProvider: @escaping @MainActor @Sendable () -> UIViewController? = {
            UIApplication.shared.topMostViewController
        }
    ) {
        self.auth = auth
        self.firebaseAppProvider = firebaseAppProvider
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }

    func currentUser() async throws -> FirebaseAuthUser? {
        auth.currentUser.map(Self.makeUser)
    }

    func signInWithEmail(email: String, password: String) async throws -> FirebaseAuthUser {
        let result = try await auth.signIn(withEmail: email, password: password)
        return Self.makeUser(from: result.user)
    }

    @MainActor
    func signInWithGoogle() async throws -> FirebaseAuthUser {
        guard firebaseAppProvider()?.options.clientID != nil else {
            throw AppError.authenticationFailed("Google sign-in is missing CLIENT_ID in GoogleService-Info.plist.")
        }

        guard let presentingViewController = topMostViewControllerProvider() else {
            throw AppError.authenticationFailed("Unable to find a view controller for Google sign-in.")
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AppError.authenticationFailed("Google sign-in did not return an ID token.")
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: signInResult.user.accessToken.tokenString
        )
        let authResult = try await auth.signIn(with: credential)
        return Self.makeUser(from: authResult.user)
    }

    func signOut() async throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    private static func makeUser(from user: User) -> FirebaseAuthUser {
        FirebaseAuthUser(
            userID: user.uid,
            email: user.email,
            displayName: user.displayName,
            providerIDs: user.providerData.map(\.providerID)
        )
    }
}
