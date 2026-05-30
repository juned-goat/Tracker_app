import Foundation

actor InMemoryMealRepository: MealRepository {
    private var meals: [MealEntry]
    private let calendar: Calendar

    init(meals: [MealEntry] = [], calendar: Calendar = .current) {
        self.meals = meals
        self.calendar = calendar
    }

    func meals(for date: Date) async throws -> [MealEntry] {
        meals
            .filter { calendar.isDate($0.loggedAt, inSameDayAs: date) }
            .sorted { $0.loggedAt < $1.loggedAt }
    }

    func addMeal(_ meal: MealEntry) async throws {
        meals.append(meal)
    }
}
