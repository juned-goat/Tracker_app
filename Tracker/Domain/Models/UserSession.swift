import Foundation

struct UserSession: Equatable, Sendable {
    let userID: String
    let email: String?
    let displayName: String?
    let authProvider: AuthProvider
}

enum AuthProvider: String, Equatable, Sendable {
    case emailPassword
    case google
    case apple
}
