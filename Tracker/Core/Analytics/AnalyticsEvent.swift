import Foundation

struct AnalyticsEvent: Equatable, Sendable {
    let name: AnalyticsEventName
    let properties: [String: String]

    init(name: AnalyticsEventName, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

enum AnalyticsEventName: String, Equatable, Sendable {
    case appLaunched = "app_launched"
    case signInStarted = "sign_in_started"
    case signInSucceeded = "sign_in_succeeded"
    case signInFailed = "sign_in_failed"
    case mealAdded = "meal_added"
    case dailyProgressViewed = "daily_progress_viewed"
}
