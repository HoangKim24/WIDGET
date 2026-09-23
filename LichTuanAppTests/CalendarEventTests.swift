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

    func testRecurringAndReminderFields() throws {
        let event = CalendarEvent(
            title: "Học Yoga hàng tuần",
            startDate: Date(timeIntervalSince1970: 10_000),
            endDate: Date(timeIntervalSince1970: 13_600),
            category: .health,
            isAllDay: false,
            isRecurringWeekly: true,
            hasReminder: true
        )

        let json = try EventCoding.jsonString(from: [event])
        let decoded = try EventCoding.events(fromJSON: json)

        XCTAssertEqual(decoded.count, 1)
        XCTAssertTrue(decoded[0].isRecurringWeekly)
        XCTAssertTrue(decoded[0].hasReminder)
    }

    func testScheduleTextParser() {
        let sample = """
        Thứ 2:
        - 08:00 - 10:00: Đi làm
        T3:
        - 14:00 - 16:00: Họp team
        CN:
        - Cả ngày: Nghỉ ngơi
        """

        let parsed = ScheduleTextParser.parse(text: sample)
        XCTAssertGreaterThanOrEqual(parsed.count, 3)

        let first = parsed[0]
        XCTAssertEqual(first.dayName, "T2")
        XCTAssertEqual(first.startHour, 8)
        XCTAssertEqual(first.endHour, 10)
        XCTAssertEqual(first.title, "Đi làm")

        let last = parsed.last!
        XCTAssertEqual(last.dayName, "CN")
        XCTAssertTrue(last.isAllDay)
        XCTAssertEqual(last.title, "Nghỉ ngơi")
    }

    func testICSGeneration() {
        let event = CalendarEvent(
            title: "Họp Định Kỳ",
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_003_600),
            category: .work,
            isAllDay: false,
            isRecurringWeekly: true
        )

        let ics = CalendarExportManager.generateICS(from: [event])
        XCTAssertTrue(ics.contains("BEGIN:VCALENDAR"))
        XCTAssertTrue(ics.contains("END:VCALENDAR"))
        XCTAssertTrue(ics.contains("BEGIN:VEVENT"))
        XCTAssertTrue(ics.contains("SUMMARY:Họp Định Kỳ"))
        XCTAssertTrue(ics.contains("RRULE:FREQ=WEEKLY"))
        XCTAssertTrue(ics.contains("END:VEVENT"))
    }

    func testBackupJSONFileCreationAndRestore() throws {
        let events = [
            CalendarEvent(
                title: "Tập Gym",
                startDate: Date(timeIntervalSince1970: 10_000),
                endDate: Date(timeIntervalSince1970: 13_600),
                category: .health,
                isAllDay: false,
                isRecurringWeekly: false,
                hasReminder: true
            )
        ]

        let fileURL = try XCTUnwrap(CalendarExportManager.createTempBackupJSONFile(from: events))
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let data = try Data(contentsOf: fileURL)
        let jsonStr = try XCTUnwrap(String(data: data, encoding: .utf8))
        let restored = try EventCoding.events(fromJSON: jsonStr)

        XCTAssertEqual(restored.count, 1)
        XCTAssertEqual(restored[0].title, "Tập Gym")
        XCTAssertEqual(restored[0].category, .health)
        XCTAssertEqual(restored[0].hasReminder, true)
    }
}
