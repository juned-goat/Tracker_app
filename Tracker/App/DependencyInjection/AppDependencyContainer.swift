import Foundation
import SwiftUI

struct AppDependencyContainer: Sendable {
    let authRepository: any AuthRepository
    let mealRepository: any MealRepository
    let eventLogger: any EventLogger

    static func live() -> AppDependencyContainer {
        let eventLogger = FirebaseEventLogger()
        return AppDependencyContainer(
            authRepository: FirebaseAuthRepository(),
            mealRepository: InMemoryMealRepository(),
            eventLogger: eventLogger
        )
    }

    var getCurrentSessionUseCase: GetCurrentSessionUseCase {
        GetCurrentSessionUseCase(authRepository: authRepository)
    }

    var signInWithEmailUseCase: SignInWithEmailUseCase {
        SignInWithEmailUseCase(authRepository: authRepository, eventLogger: eventLogger)
    }

    var signInWithGoogleUseCase: SignInWithGoogleUseCase {
        SignInWithGoogleUseCase(authRepository: authRepository, eventLogger: eventLogger)
    }

    var signOutUseCase: SignOutUseCase {
        SignOutUseCase(authRepository: authRepository)
    }

    var addMealUseCase: AddMealUseCase {
        AddMealUseCase(mealRepository: mealRepository, eventLogger: eventLogger)
    }

    var loadDailyProgressUseCase: LoadDailyProgressUseCase {
        LoadDailyProgressUseCase(mealRepository: mealRepository, eventLogger: eventLogger)
    }
}

private struct AppDependencyContainerKey: EnvironmentKey {
    static let defaultValue = AppDependencyContainer.live()
}

extension EnvironmentValues {
    var appDependencies: AppDependencyContainer {
        get { self[AppDependencyContainerKey.self] }
        set { self[AppDependencyContainerKey.self] = newValue }
    }
}
