import Testing
@testable import Tracker

struct AuthUseCaseTests {
    @Test func emailSignInDelegatesToRepositoryAndLogsLifecycleEvents() async throws {
        let repository = MockAuthRepository()
        let logger = MockEventLogger()
        let useCase = SignInWithEmailUseCase(authRepository: repository, eventLogger: logger)

        let session = try await useCase.execute(email: "test@example.com", password: "secret")

        #expect(session.authProvider == .emailPassword)
        #expect(await repository.emailSignInRequests == [
            EmailSignInRequest(email: "test@example.com", password: "secret")
        ])
        #expect(await logger.eventNames == [.signInStarted, .signInSucceeded])
    }

    @Test func googleSignInDelegatesToRepositoryAndLogsLifecycleEvents() async throws {
        let repository = MockAuthRepository()
        let logger = MockEventLogger()
        let useCase = SignInWithGoogleUseCase(authRepository: repository, eventLogger: logger)

        let session = try await useCase.execute()

        #expect(session.authProvider == .google)
        #expect(await repository.googleSignInCount == 1)
        #expect(await logger.eventNames == [.signInStarted, .signInSucceeded])
    }
}
