import Testing
@testable import Tracker

struct AppDependencyContainerTests {
    @Test func containerCreatesUseCasesWithInjectedMocks() async throws {
        let container = AppDependencyContainer(
            authRepository: MockAuthRepository(),
            mealRepository: InMemoryMealRepository(),
            eventLogger: MockEventLogger()
        )

        let session = try await container.signInWithEmailUseCase.execute(
            email: "juned@example.com",
            password: "password"
        )

        #expect(session.email == "juned@example.com")
        #expect(session.authProvider == .emailPassword)
    }
}
