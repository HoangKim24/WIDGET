import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Lớp lưu và đọc dữ liệu sự kiện của ứng dụng (lưu trữ cục bộ an toàn, hoạt động 100% offline).
/// Hỗ trợ chia sẻ dữ liệu liên tục với WidgetKit Extension (Màn hình khóa & Màn hình chính) và Shortcuts.
final class SharedDataStore {
    static let appGroupName = "group.com.hoangkim24.lichtuan"

    /// Tự động lấy App Group UserDefaults để chia sẻ với Widget, có fallback an toàn về .standard
    static var defaultUserDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupName) ?? .standard
    }

    static let shared = SharedDataStore(userDefaults: defaultUserDefaults)

    private let eventsKey = "calendarEvents"
    private let encoder = EventCoding.encoder
    private let decoder = EventCoding.decoder
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = defaultUserDefaults) {
        self.userDefaults = userDefaults
    }

    /// Đọc toàn bộ sự kiện đã lưu. Nếu không có dữ liệu thì trả về mảng rỗng.
    func loadEvents() -> [CalendarEvent] {
        if let data = userDefaults.data(forKey: eventsKey),
           let events = try? decoder.decode([CalendarEvent].self, from: data) {
            return events
        }

        // Fallback đọc từ .standard nếu App Group chưa có dữ liệu
        if userDefaults != UserDefaults.standard,
           let data = UserDefaults.standard.data(forKey: eventsKey),
           let events = try? decoder.decode([CalendarEvent].self, from: data) {
            return events
        }

        return []
    }

    /// Lưu danh sách sự kiện xuống bộ nhớ cục bộ của app và kích hoạt Widget cập nhật tức thì.
    func save(events: [CalendarEvent]) {
        guard let data = try? encoder.encode(events) else {
            return
        }

        userDefaults.set(data, forKey: eventsKey)

        // Đồng bộ dự phòng vào .standard
        if userDefaults != UserDefaults.standard {
            UserDefaults.standard.set(data, forKey: eventsKey)
        }

        // Tự động làm mới toàn bộ Widget trên Màn hình khóa & Màn hình chính
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
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
        UserDefaults.standard.removeObject(forKey: eventsKey)

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func normalized(_ event: CalendarEvent) -> CalendarEvent {
        guard event.endDate < event.startDate else { return event }
        var copy = event
        copy.endDate = event.startDate
        return copy
    }
}
