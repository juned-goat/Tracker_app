import Foundation

struct MacroBreakdown: Equatable, Sendable {
    let calories: Int
    let proteinGrams: Double
    let carbohydrateGrams: Double
    let fatGrams: Double

    static let zero = MacroBreakdown(
        calories: 0,
        proteinGrams: 0,
        carbohydrateGrams: 0,
        fatGrams: 0
    )

    static func + (lhs: MacroBreakdown, rhs: MacroBreakdown) -> MacroBreakdown {
        MacroBreakdown(
            calories: lhs.calories + rhs.calories,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            carbohydrateGrams: lhs.carbohydrateGrams + rhs.carbohydrateGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams
        )
    }
}
