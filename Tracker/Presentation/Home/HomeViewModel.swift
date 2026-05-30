import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var session: UserSession
    private(set) var progress: DailyProgress?
    private(set) var errorMessage: String?

    private let loadDailyProgressUseCase: LoadDailyProgressUseCase
    private let addMealUseCase: AddMealUseCase
    private let onSignOut: @MainActor () -> Void

    init(
        session: UserSession,
        loadDailyProgressUseCase: LoadDailyProgressUseCase,
        addMealUseCase: AddMealUseCase,
        onSignOut: @escaping @MainActor () -> Void
    ) {
        self.session = session
        self.loadDailyProgressUseCase = loadDailyProgressUseCase
        self.addMealUseCase = addMealUseCase
        self.onSignOut = onSignOut
    }

    func loadToday() async {
        do {
            progress = try await loadDailyProgressUseCase.execute(for: Date())
            errorMessage = nil
        } catch {
            errorMessage = "Unable to load daily progress."
        }
    }

    func addSampleMeal() async {
        let meal = MealEntry(
            name: "Sample Meal",
            loggedAt: Date(),
            macros: MacroBreakdown(
                calories: 420,
                proteinGrams: 28,
                carbohydrateGrams: 45,
                fatGrams: 14
            )
        )

        do {
            try await addMealUseCase.execute(meal)
            await loadToday()
        } catch {
            errorMessage = "Unable to add meal."
        }
    }

    func signOut() {
        onSignOut()
    }
}
