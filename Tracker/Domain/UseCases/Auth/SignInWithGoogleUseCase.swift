import Foundation

struct SignInWithGoogleUseCase: Sendable {
    private let authRepository: any AuthRepository
    private let eventLogger: any EventLogger

    init(authRepository: any AuthRepository, eventLogger: any EventLogger) {
        self.authRepository = authRepository
        self.eventLogger = eventLogger
    }

    func execute() async throws -> UserSession {
        await eventLogger.log(.init(
            name: .signInStarted,
            properties: ["provider": AuthProvider.google.rawValue]
        ))

        do {
            let session = try await authRepository.signInWithGoogle()
            await eventLogger.log(.init(
                name: .signInSucceeded,
                properties: ["provider": session.authProvider.rawValue]
            ))
            return session
        } catch {
            await eventLogger.log(.init(
                name: .signInFailed,
                properties: ["provider": AuthProvider.google.rawValue]
            ))
            throw error
        }
    }
}
