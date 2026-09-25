import Foundation
import Combine

/// View model quản lý danh sách sự kiện trên thiết bị (hoàn toàn offline và an toàn).
@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []

    private let store: SharedDataStore

    init(store: SharedDataStore = .shared) {
        self.store = store
        migrateLegacySeedEventsOnce()
        load()
    }

    /// Đảm bảo chỉ dọn sạch các dữ liệu mẫu cũ đúng 1 lần duy nhất, không quét xóa sự kiện thật của người dùng
    private func migrateLegacySeedEventsOnce() {
        let migrationKey = "hasMigratedLegacySeedDataV1"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        UserDefaults.standard.set(true, forKey: migrationKey)

        let sampleTitles: Set<String> = [
            "Họp Giao Ban Đầu Tuần",
            "Xử Lý Dự Án Mới",
            "Chạy Bộ & Gym",
            "Gặp Khách Hàng",
            "Học Tiếng Anh",
            "Báo Cáo Tiến Độ Tuần",
            "Đào Tạo Nội Bộ",
            "Hoàn Thành Deadline Tuần",
            "Đi Siêu Thị Mua Sắm",
            "Cà Phê Cùng Bạn Bè",
            "Dọn Dẹp & Nấu Ăn",
            "Tập Yoga Thư Giãn",
            "Ăn Tối Cùng Gia Đình"
        ]
        let existing = store.loadEvents()
        let filtered = existing.filter { !sampleTitles.contains($0.title) }
        if filtered.count != existing.count {
            store.save(events: filtered)
        }
    }

    func load() {
        let loaded = store.loadEvents()
        events = loaded.sorted { $0.startDate < $1.startDate }
    }

    func add(_ event: CalendarEvent) {
        store.add(event: event)
        load()
    }

    func update(_ event: CalendarEvent) {
        store.update(event: event)
        load()
    }

    func delete(_ event: CalendarEvent) {
        if event.hasReminder {
            NotificationManager.shared.cancelNotification(for: event.id)
        }
        store.delete(eventID: event.id)
        load()
    }

    func delete(at offsets: IndexSet) {
        let removedEvents = offsets.map { events[$0] }
        removedEvents.forEach {
            if $0.hasReminder {
                NotificationManager.shared.cancelNotification(for: $0.id)
            }
            store.delete(eventID: $0.id)
        }
        load()
    }

    func clearAll() {
        NotificationManager.shared.cancelAllNotifications()
        store.clearAllEvents()
        events = []
    }

    /// Kiểm tra xem sự kiện có bị trùng lặp với danh sách hiện tại hay không
    func isDuplicate(event: CalendarEvent) -> Bool {
        events.contains { $0.isDuplicate(of: event) }
    }

    /// Nạp hàng loạt sự kiện mới (từ Lịch iPhone, OCR hoặc file nhập) - có tùy chọn bỏ qua trùng lặp
    func importEvents(_ newEvents: [CalendarEvent], skipDuplicates: Bool = true) {
        var current = store.loadEvents()
        var addedCount = 0

        for ev in newEvents {
            if skipDuplicates && current.contains(where: { $0.isDuplicate(of: ev) }) {
                continue
            }
            current.append(ev)
            addedCount += 1
            if ev.hasReminder {
                NotificationManager.shared.scheduleNotification(for: ev)
            }
        }

        if addedCount > 0 {
            current.sort { $0.startDate < $1.startDate }
            store.save(events: current)
            load()
        }
    }

    /// Khôi phục dữ liệu từ chuỗi JSON sao lưu
    func restoreEvents(from jsonString: String) throws -> Int {
        let restored = try EventCoding.events(fromJSON: jsonString)
        for ev in restored {
            store.add(event: ev)
            if ev.hasReminder {
                NotificationManager.shared.scheduleNotification(for: ev)
            }
        }
        load()
        return restored.count
    }
}
