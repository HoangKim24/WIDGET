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

    func testMultiDayEventOccurs() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: today)!

        let multiDayEvent = CalendarEvent(
            title: "Hội Thảo 3 Ngày",
            startDate: today,
            endDate: dayAfterTomorrow,
            category: .work
        )

        // Phải xảy ra trong cả ngày hôm nay, ngày mai và ngày kia
        XCTAssertTrue(multiDayEvent.occurs(on: today, calendar: calendar))
        XCTAssertTrue(multiDayEvent.occurs(on: tomorrow, calendar: calendar))
        XCTAssertTrue(multiDayEvent.occurs(on: dayAfterTomorrow, calendar: calendar))
        // Không xảy ra sau ngày kết thúc
        XCTAssertFalse(multiDayEvent.occurs(on: threeDaysLater, calendar: calendar))
    }

    func testScheduleTextParserWordBoundaryRobustness() {
        let text = """
        Thứ 2:
        - 08:00 - 09:00: Uống thuốc và ăn sáng
        T3:
        - 14:00 - 16:00: Học CNTT
        T4:
        - 18:00 - 19:00: Ăn món Huế
        """

        let parsed = ScheduleTextParser.parse(text: text)
        XCTAssertEqual(parsed.count, 3)

        // Không bị nhận nhầm "thuốc" thành T5
        XCTAssertEqual(parsed[0].dayName, "T2")
        XCTAssertTrue(parsed[0].title.contains("Uống thuốc"))

        // Không bị nhận nhầm "CNTT" thành CN
        XCTAssertEqual(parsed[1].dayName, "T3")
        XCTAssertTrue(parsed[1].title.contains("Học CNTT"))

        // Không bị nhận nhầm "món" thành T2 (mon)
        XCTAssertEqual(parsed[2].dayName, "T4")
        XCTAssertTrue(parsed[2].title.contains("Ăn món Huế"))
    }

    func testDateTimeUtilsWeekdayAndWeekCalculations() {
        let calendar = Calendar.current
        let today = Date()

        // Kiểm tra startOfWeek luôn rơi vào Thứ 2 (weekday 2)
        let monday = calendar.startOfWeek(for: today)
        XCTAssertEqual(calendar.component(.weekday, from: monday), 2)

        // Kiểm tra weekDays luôn trả về đúng 7 ngày liên tiếp từ Thứ 2 đến Chủ Nhật
        let days = calendar.weekDays(for: today)
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days[0].vietnameseWeekdayShort, "T2")
        XCTAssertEqual(days[6].vietnameseWeekdayShort, "CN")

        // Kiểm tra offset tên thứ tiếng Việt
        XCTAssertEqual(DateTimeUtils.vietnameseWeekdayName(for: 0), "T2")
        XCTAssertEqual(DateTimeUtils.vietnameseWeekdayName(for: 6), "CN")
    }

    func testEventCategoryInferenceAndContrast() {
        // Kiểm tra suy luận danh mục thông minh
        XCTAssertEqual(EventCategory.infer(from: "Họp giao ban sprint"), .work)
        XCTAssertEqual(EventCategory.infer(from: "Khám sức khỏe tổng quát"), .health)
        XCTAssertEqual(EventCategory.infer(from: "Ôn thi cuối kỳ và làm bài tập"), .study)
        XCTAssertEqual(EventCategory.infer(from: "Đón con và đi chợ"), .family)
        XCTAssertEqual(EventCategory.infer(from: "Cà phê cuối tuần cùng bạn"), .personal)
        XCTAssertEqual(EventCategory.infer(from: "Một sự kiện ngẫu nhiên"), .other)

        // Kiểm tra độ tương phản màu chữ (học tập và sức khỏe là màu sáng nên cần chữ đen)
        XCTAssertTrue(EventCategory.study.isLightColor)
        XCTAssertTrue(EventCategory.health.isLightColor)
        XCTAssertFalse(EventCategory.work.isLightColor)
    }

    func testCalendarEventDuplicateDetection() {
        let baseDate = Date()
        let event1 = CalendarEvent(
            title: "Họp Ban Giám Đốc",
            startDate: baseDate,
            endDate: baseDate.addingTimeInterval(3600),
            category: .work
        )

        let duplicateEvent = CalendarEvent(
            title: "Họp Ban Giám Đốc",
            startDate: baseDate.addingTimeInterval(20), // Cách nhau 20 giây (dưới 60s)
            endDate: baseDate.addingTimeInterval(3610),
            category: .work
        )

        let differentEvent = CalendarEvent(
            title: "Họp Ban Giám Đốc",
            startDate: baseDate.addingTimeInterval(120), // Cách nhau 2 phút (> 60s)
            endDate: baseDate.addingTimeInterval(3720),
            category: .work
        )

        XCTAssertTrue(event1.isDuplicate(of: duplicateEvent))
        XCTAssertFalse(event1.isDuplicate(of: differentEvent))
    }

    func testSharedDataStoreNormalizationPreservesFields() {
        let suiteName = "unit-test-store-norm-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SharedDataStore(userDefaults: defaults)

        let invalidEndEvent = CalendarEvent(
            title: "Sự kiện thời gian lỗi",
            startDate: Date(timeIntervalSince1970: 5000),
            endDate: Date(timeIntervalSince1970: 1000), // Kết thúc trước khi bắt đầu
            category: .study,
            isAllDay: false,
            isRecurringWeekly: true,
            recurrenceEndDate: Date(timeIntervalSince1970: 20000),
            hasReminder: true
        )

        store.add(event: invalidEndEvent)
        let saved = store.loadEvents()
        XCTAssertEqual(saved.count, 1)

        let normalized = saved[0]
        XCTAssertEqual(normalized.startDate, normalized.endDate) // Đã sửa endDate = startDate
        XCTAssertTrue(normalized.isRecurringWeekly) // Giữ nguyên trường lặp lại
        XCTAssertTrue(normalized.hasReminder) // Giữ nguyên trường nhắc nhở
        XCTAssertEqual(normalized.category, .study)
    }

    func testNaturalLanguagePromptToCalendarMultiDay() {
        let prompt = "Sáng 2-4-6 tập gym 6h đến 7h, tối thứ 3 học tiếng Anh 19h, thứ 7 cả ngày đi chơi"
        let parsed = ScheduleTextParser.parse(text: prompt)

        // Phải nhận diện được 5 sự kiện: 3 sự kiện gym (T2, T4, T6), 1 học tiếng Anh (T3), 1 đi chơi (T7)
        XCTAssertEqual(parsed.count, 5)

        // Kiểm tra gym T2, T4, T6
        let gymEvents = parsed.filter { $0.title.contains("Tập gym") }
        XCTAssertEqual(gymEvents.count, 3)
        let gymDays = Set(gymEvents.map { $0.dayOffset })
        XCTAssertEqual(gymDays, Set([0, 2, 4])) // T2, T4, T6
        XCTAssertEqual(gymEvents[0].startHour, 6)
        XCTAssertEqual(gymEvents[0].endHour, 7)
        XCTAssertEqual(gymEvents[0].category, .health)

        // Kiểm tra tiếng Anh tối T3
        let englishEvents = parsed.filter { $0.title.contains("Học tiếng Anh") }
        XCTAssertEqual(englishEvents.count, 1)
        XCTAssertEqual(englishEvents[0].dayOffset, 1) // T3
        XCTAssertEqual(englishEvents[0].startHour, 19)
        XCTAssertEqual(englishEvents[0].category, .study)

        // Kiểm tra T7 cả ngày đi chơi
        let weekendEvents = parsed.filter { $0.title.contains("Đi chơi") }
        XCTAssertEqual(weekendEvents.count, 1)
        XCTAssertEqual(weekendEvents[0].dayOffset, 5) // T7
        XCTAssertTrue(weekendEvents[0].isAllDay)
        XCTAssertEqual(weekendEvents[0].category, .personal)
    }

    func testNaturalLanguageSingleHourAndPeriodAdjustment() {
        let text = "T2 lúc 7h tối ăn cơm cùng gia đình, T5 vào 2h chiều họp dự án"
        let parsed = ScheduleTextParser.parse(text: text)

        XCTAssertEqual(parsed.count, 2)

        // 7h tối -> 19h, danh mục gia đình
        let dinner = parsed.first { $0.dayOffset == 0 }!
        XCTAssertEqual(dinner.startHour, 19)
        XCTAssertEqual(dinner.category, .family)

        // 2h chiều -> 14h, danh mục công việc
        let meeting = parsed.first { $0.dayOffset == 3 }!
        XCTAssertEqual(meeting.startHour, 14)
        XCTAssertEqual(meeting.category, .work)
    }
}
