import XCTest

final class CalendarEventTests: XCTestCase {
    func testCalendarEventCodableRoundTrip() throws {
        let event = CalendarEvent(
            title: "Họp dự án mới",
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

    func testEventCodingJsonRoundTrip() throws {
        let events = [
            CalendarEvent(
                title: "Sinh nhật bạn thân",
                startDate: Date(timeIntervalSince1970: 1_700_000_000),
                endDate: Date(timeIntervalSince1970: 1_700_003_600),
                category: .personal,
                isAllDay: false
            )
        ]

        let json = try EventCoding.jsonString(from: events)
        let decoded = try EventCoding.events(fromJSON: json)

        XCTAssertEqual(decoded, events)
    }

    func testSharedDataStoreCRUD() throws {
        let suiteName = "unit-test-store-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SharedDataStore(userDefaults: defaults)
        XCTAssertTrue(store.loadEvents().isEmpty)

        let event = CalendarEvent(
            title: "Deadline nộp đồ án",
            startDate: Date(timeIntervalSince1970: 5_000),
            endDate: Date(timeIntervalSince1970: 6_000),
            category: .study
        )

        store.add(event: event)
        XCTAssertEqual(store.loadEvents(), [event])

        store.delete(eventID: event.id)
        XCTAssertTrue(store.loadEvents().isEmpty)
    }
}
