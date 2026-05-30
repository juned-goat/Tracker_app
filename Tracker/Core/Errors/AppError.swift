import Foundation

enum AppError: Error, Equatable, Sendable {
    case authenticationFailed(String)
    case persistenceFailed(String)
    case unsupportedProvider(AuthProvider)
    case unknown(String)
}
