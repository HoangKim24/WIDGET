import Foundation
import Combine

/// View model quản lý danh sách sự kiện trên thiết bị (hoàn toàn offline và an toàn).
@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []

    private let store: SharedDataStore

    init(store: SharedDataStore = .shared) {
        self.store = store
        purgeSampleSeedEvents()
        load()
    }

    /// Tự động dọn sạch các dữ liệu mẫu cũ trên máy của người dùng khi nâng cấp app
    private func purgeSampleSeedEvents() {
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
}
