import XCTest

final class CalendarEventTests: XCTestCase {
    func testCalendarEventCodableRoundTrip() throws {
        let event = CalendarEvent(
            title: "Morning standup",
            startDate: Date(timeIntervalSince1970: 1_000),
            endDate: Date(timeIntervalSince1970: 1_600),
            category: .work,
            isAllDay: false
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(event)
        let decoded = try decoder.decode(CalendarEvent.self, from: data)

        XCTAssertEqual(decoded, event)
    }
}
