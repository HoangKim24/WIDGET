import Foundation
import Combine

/// View model quản lý danh sách sự kiện trên thiết bị (hoàn toàn offline và an toàn).
@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []

    private let store: SharedDataStore

    init(store: SharedDataStore = .shared) {
        self.store = store
        load()
    }

    func load() {
        let loaded = store.loadEvents()
        if loaded.isEmpty {
            // Tự động nạp bộ lịch mẫu Tiếng Việt chuẩn chỉnh nếu máy chưa có sự kiện nào
            let samples = SharedEventSeed.sampleEvents
            for ev in samples {
                store.add(event: ev)
            }
            events = samples.sorted { $0.startDate < $1.startDate }
            return
        }
        events = loaded.sorted { $0.startDate < $1.startDate }
    }

    /// Khôi phục hoặc nạp nhanh bộ lịch mẫu Tiếng Việt để test thử giao diện
    func loadSampleEvents() {
        NotificationManager.shared.cancelAllNotifications()
        store.clearAllEvents()
        let samples = SharedEventSeed.sampleEvents
        for ev in samples {
            store.add(event: ev)
        }
        load()
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
