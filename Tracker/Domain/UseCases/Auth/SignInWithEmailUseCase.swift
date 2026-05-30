import Foundation

struct SignInWithEmailUseCase: Sendable {
    private let authRepository: any AuthRepository
    private let eventLogger: any EventLogger

    init(authRepository: any AuthRepository, eventLogger: any EventLogger) {
        self.authRepository = authRepository
        self.eventLogger = eventLogger
    }

    func execute(email: String, password: String) async throws -> UserSession {
        await eventLogger.log(.init(
            name: .signInStarted,
            properties: ["provider": AuthProvider.emailPassword.rawValue]
        ))

        do {
            let session = try await authRepository.signInWithEmail(email: email, password: password)
            await eventLogger.log(.init(
                name: .signInSucceeded,
                properties: ["provider": session.authProvider.rawValue]
            ))
            return session
        } catch {
            await eventLogger.log(.init(
                name: .signInFailed,
                properties: ["provider": AuthProvider.emailPassword.rawValue]
            ))
            throw error
        }
    }
}
