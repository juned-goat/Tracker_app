import Testing
@testable import Tracker

struct EventLoggerTests {
    @Test func compositeLoggerForwardsEventsToEveryProvider() async {
        let firstLogger = MockEventLogger()
        let secondLogger = MockEventLogger()
        let logger = CompositeEventLogger(loggers: [firstLogger, secondLogger])
        let event = AnalyticsEvent(name: .mealAdded, properties: ["meal_id": "123"])

        await logger.log(event)

        #expect(await firstLogger.events == [event])
        #expect(await secondLogger.events == [event])
    }
}
