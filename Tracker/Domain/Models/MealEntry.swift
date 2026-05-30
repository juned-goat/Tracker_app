import Foundation

struct MealEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let loggedAt: Date
    let macros: MacroBreakdown

    init(
        id: UUID = UUID(),
        name: String,
        loggedAt: Date,
        macros: MacroBreakdown
    ) {
        self.id = id
        self.name = name
        self.loggedAt = loggedAt
        self.macros = macros
    }
}
