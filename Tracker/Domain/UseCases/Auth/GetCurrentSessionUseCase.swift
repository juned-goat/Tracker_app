import Foundation

struct GetCurrentSessionUseCase: Sendable {
    private let authRepository: any AuthRepository

    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async throws -> UserSession? {
        try await authRepository.currentUserSession()
    }
}
