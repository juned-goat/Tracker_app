import Foundation

protocol EventLogger: Sendable {
    func log(_ event: AnalyticsEvent) async
}

struct CompositeEventLogger: EventLogger {
    private let loggers: [any EventLogger]

    init(loggers: [any EventLogger]) {
        self.loggers = loggers
    }

    func log(_ event: AnalyticsEvent) async {
        for logger in loggers {
            await logger.log(event)
        }
    }
}

struct NoOpEventLogger: EventLogger {
    func log(_ event: AnalyticsEvent) async {}
}
