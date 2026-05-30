import Foundation

struct AddMealUseCase: Sendable {
    private let mealRepository: any MealRepository
    private let eventLogger: any EventLogger

    init(mealRepository: any MealRepository, eventLogger: any EventLogger) {
        self.mealRepository = mealRepository
        self.eventLogger = eventLogger
    }

    func execute(_ meal: MealEntry) async throws {
        try await mealRepository.addMeal(meal)
        await eventLogger.log(.init(
            name: .mealAdded,
            properties: ["meal_id": meal.id.uuidString]
        ))
    }
}
