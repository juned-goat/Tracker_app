import Foundation

struct DailyProgress: Equatable, Sendable {
    let date: Date
    let meals: [MealEntry]
    let totalMacros: MacroBreakdown

    init(date: Date, meals: [MealEntry]) {
        self.date = date
        self.meals = meals
        self.totalMacros = meals.reduce(.zero) { $0 + $1.macros }
    }
}
