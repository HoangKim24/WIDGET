import Foundation

/// Lớp lưu và đọc dữ liệu sự kiện của app chính.
///
/// Trước đây lớp này ghi vào UserDefaults của App Group để widget đọc chung.
/// Apple ID miễn phí không được cấp capability App Groups, nên bản này lưu
/// cục bộ trong sandbox của app và việc chia sẻ với widget do `GistSyncClient`
/// đảm nhiệm thông qua một Gist trên GitHub.
final class SharedDataStore {
    static let shared = SharedDataStore()

    private let eventsKey = "calendarEvents"
    private let encoder = EventCoding.encoder
    private let decoder = EventCoding.decoder
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Đọc toàn bộ sự kiện đã lưu. Nếu không có dữ liệu thì trả về mảng rỗng.
    func loadEvents() -> [CalendarEvent] {
        guard let data = userDefaults.data(forKey: eventsKey) else {
            return []
        }

        do {
            return try decoder.decode([CalendarEvent].self, from: data)
        } catch {
            return []
        }
    }

    /// Lưu danh sách sự kiện xuống bộ nhớ cục bộ của app.
    func save(events: [CalendarEvent]) {
        guard let data = try? encoder.encode(events) else {
            return
        }

        userDefaults.set(data, forKey: eventsKey)
    }

    /// Thêm một sự kiện mới vào danh sách hiện có.
    func add(event: CalendarEvent) {
        var events = loadEvents()
        events.append(normalized(event))
        events.sort { $0.startDate < $1.startDate }
        save(events: events)
    }

    /// Cập nhật một sự kiện theo id. Nếu không tìm thấy thì không làm gì.
    func update(event: CalendarEvent) {
        var events = loadEvents()
        guard let index = events.firstIndex(where: { $0.id == event.id }) else {
            return
        }

        events[index] = normalized(event)
        events.sort { $0.startDate < $1.startDate }
        save(events: events)
    }

    /// Xóa một sự kiện theo id.
    func delete(eventID: UUID) {
        let remainingEvents = loadEvents().filter { $0.id != eventID }
        save(events: remainingEvents)
    }

    /// Xóa toàn bộ dữ liệu hiện có trong bộ nhớ cục bộ của app.
    func clearAllEvents() {
        userDefaults.removeObject(forKey: eventsKey)
    }

    private func normalized(_ event: CalendarEvent) -> CalendarEvent {
        guard event.endDate >= event.startDate else {
            return CalendarEvent(
                id: event.id,
                title: event.title,
                startDate: event.startDate,
                endDate: event.startDate,
                category: event.category,
                isAllDay: event.isAllDay
            )
        }

        return event
    }
}
