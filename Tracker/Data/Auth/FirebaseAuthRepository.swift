import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

final class FirebaseAuthRepository: AuthRepository, @unchecked Sendable {
    private let auth: Auth

    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    func currentUserSession() async throws -> UserSession? {
        auth.currentUser.map(Self.makeSession)
    }

    func signInWithEmail(email: String, password: String) async throws -> UserSession {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return Self.makeSession(from: result.user)
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    func signInWithGoogle() async throws -> UserSession {
        guard FirebaseApp.app()?.options.clientID != nil else {
            throw AppError.authenticationFailed("Google sign-in is missing CLIENT_ID in GoogleService-Info.plist.")
        }

        guard let presentingViewController = await UIApplication.shared.topMostViewController else {
            throw AppError.authenticationFailed("Unable to find a view controller for Google sign-in.")
        }

        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw AppError.authenticationFailed("Google sign-in did not return an ID token.")
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )
            let authResult = try await auth.signIn(with: credential)
            return Self.makeSession(from: authResult.user)
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    func signOut() async throws {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            throw AppError.authenticationFailed(error.localizedDescription)
        }
    }

    private static func makeSession(from user: User) -> UserSession {
        UserSession(
            userID: user.uid,
            email: user.email,
            displayName: user.displayName,
            authProvider: authProvider(for: user)
        )
    }

    private static func authProvider(for user: User) -> AuthProvider {
        if user.providerData.contains(where: { $0.providerID == GoogleAuthProviderID }) {
            return .google
        }

        return .emailPassword
    }
}
