import Foundation
import Testing
@testable import Tracker

struct MealUseCaseTests {
    @Test func loadingDailyProgressAggregatesMacrosForRequestedDay() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 5, day: 30, hour: 12)))
        let yesterday = try #require(calendar.date(from: DateComponents(year: 2026, month: 5, day: 29, hour: 12)))
        let repository = InMemoryMealRepository(meals: [
            MealEntry(
                name: "Breakfast",
                loggedAt: today,
                macros: MacroBreakdown(calories: 300, proteinGrams: 20, carbohydrateGrams: 35, fatGrams: 9)
            ),
            MealEntry(
                name: "Lunch",
                loggedAt: today,
                macros: MacroBreakdown(calories: 500, proteinGrams: 35, carbohydrateGrams: 55, fatGrams: 18)
            ),
            MealEntry(
                name: "Yesterday",
                loggedAt: yesterday,
                macros: MacroBreakdown(calories: 900, proteinGrams: 60, carbohydrateGrams: 90, fatGrams: 25)
            )
        ], calendar: calendar)
        let logger = MockEventLogger()
        let useCase = LoadDailyProgressUseCase(mealRepository: repository, eventLogger: logger)

        let progress = try await useCase.execute(for: today)

        #expect(progress.meals.map(\.name) == ["Breakfast", "Lunch"])
        #expect(progress.totalMacros.calories == 800)
        #expect(progress.totalMacros.proteinGrams == 55)
        #expect(progress.totalMacros.carbohydrateGrams == 90)
        #expect(progress.totalMacros.fatGrams == 27)
        #expect(await logger.eventNames == [.dailyProgressViewed])
    }

    @Test func addingMealPersistsThroughRepositoryAndLogsEvent() async throws {
        let repository = InMemoryMealRepository()
        let logger = MockEventLogger()
        let useCase = AddMealUseCase(mealRepository: repository, eventLogger: logger)
        let meal = MealEntry(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Dinner",
            loggedAt: Date(),
            macros: MacroBreakdown(calories: 650, proteinGrams: 42, carbohydrateGrams: 70, fatGrams: 22)
        )

        try await useCase.execute(meal)

        #expect(try await repository.meals(for: meal.loggedAt) == [meal])
        #expect(await logger.eventNames == [.mealAdded])
    }
}
