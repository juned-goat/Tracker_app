import Testing
@testable import Tracker

struct AppDependencyContainerTests {
    @Test func liveContainerCreatesUseCasesWithoutExternalServices() async throws {
        let container = AppDependencyContainer.live()

        let session = try await container.signInWithEmailUseCase.execute(
            email: "juned@example.com",
            password: "password"
        )

        #expect(session.email == "juned@example.com")
        #expect(session.authProvider == .emailPassword)
    }
}
