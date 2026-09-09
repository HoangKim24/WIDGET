import XCTest

final class RemoteSyncTests: XCTestCase {
    func testEventCodingRoundTripThroughJSONString() throws {
        let events = [
            CalendarEvent(
                title: "Hop nhom",
                startDate: Date(timeIntervalSince1970: 1_700_000_000),
                endDate: Date(timeIntervalSince1970: 1_700_003_600),
                category: .work,
                isAllDay: false
            ),
            CalendarEvent(
                title: "Nghi le",
                startDate: Date(timeIntervalSince1970: 1_700_086_400),
                endDate: Date(timeIntervalSince1970: 1_700_172_800),
                category: .family,
                isAllDay: true
            )
        ]

        let json = try EventCoding.jsonString(from: events)
        let decoded = try EventCoding.events(fromJSON: json)

        XCTAssertEqual(decoded, events)
    }

    func testEventsFromInvalidJSONThrows() {
        XCTAssertThrowsError(try EventCoding.events(fromJSON: "khong phai json"))
    }

    func testRemoteSyncConfigReportsMissingGistID() {
        // Gist ID để rỗng trong repo, người dùng tự điền trên máy mình.
        XCTAssertEqual(RemoteSyncConfig.isConfigured, !RemoteSyncConfig.gistID.isEmpty)

        if RemoteSyncConfig.gistID.isEmpty {
            XCTAssertNil(RemoteSyncConfig.gistEndpoint)
        } else {
            XCTAssertNotNil(RemoteSyncConfig.gistEndpoint)
        }
    }

    func testEventCacheSavesAndLoadsEvents() {
        let cache = EventCache(fileName: "unit-test-events-\(UUID().uuidString).json")
        defer { cache.clear() }

        XCTAssertTrue(cache.load().isEmpty)

        let events = [
            CalendarEvent(
                title: "Muon hon",
                startDate: Date(timeIntervalSince1970: 2_000),
                endDate: Date(timeIntervalSince1970: 3_000)
            ),
            CalendarEvent(
                title: "Som hon",
                startDate: Date(timeIntervalSince1970: 1_000),
                endDate: Date(timeIntervalSince1970: 1_500)
            )
        ]

        cache.save(events)
        let loaded = cache.load()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded.first?.title, "Som hon", "Cache phải trả về danh sách đã sắp xếp theo thời gian bắt đầu")
    }

    func testEventCacheIsStaleWhenEmpty() {
        let cache = EventCache(fileName: "unit-test-stale-\(UUID().uuidString).json")
        defer { cache.clear() }

        XCTAssertTrue(cache.isStale(), "Chưa có cache thì luôn cần gọi mạng")

        cache.save([])
        XCTAssertFalse(cache.isStale(interval: 60 * 60))
        XCTAssertTrue(cache.isStale(now: Date().addingTimeInterval(60 * 60 * 2), interval: 60 * 60))
    }

    func testSharedDataStoreUsesInjectedDefaults() throws {
        let suiteName = "unit-test-store-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SharedDataStore(userDefaults: defaults)
        XCTAssertTrue(store.loadEvents().isEmpty)

        let event = CalendarEvent(
            title: "Kiem tra",
            startDate: Date(timeIntervalSince1970: 5_000),
            endDate: Date(timeIntervalSince1970: 6_000)
        )

        store.add(event: event)
        XCTAssertEqual(store.loadEvents(), [event])

        store.delete(eventID: event.id)
        XCTAssertTrue(store.loadEvents().isEmpty)
    }
}
