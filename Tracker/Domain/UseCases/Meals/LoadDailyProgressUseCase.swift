import Foundation

struct LoadDailyProgressUseCase: Sendable {
    private let mealRepository: any MealRepository
    private let eventLogger: any EventLogger

    init(mealRepository: any MealRepository, eventLogger: any EventLogger) {
        self.mealRepository = mealRepository
        self.eventLogger = eventLogger
    }

    func execute(for date: Date) async throws -> DailyProgress {
        let meals = try await mealRepository.meals(for: date)
        await eventLogger.log(.init(name: .dailyProgressViewed))
        return DailyProgress(date: date, meals: meals)
    }
}
