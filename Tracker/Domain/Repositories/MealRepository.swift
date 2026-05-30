import Foundation

protocol MealRepository: Sendable {
    func meals(for date: Date) async throws -> [MealEntry]
    func addMeal(_ meal: MealEntry) async throws
}
