import FirebaseAnalytics
import Foundation

struct FirebaseEventLogger: EventLogger {
    func log(_ event: AnalyticsEvent) async {
        Analytics.logEvent(event.name.rawValue, parameters: event.properties)
    }
}
