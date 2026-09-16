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
            // Nạp dữ liệu mẫu ban đầu để người dùng thấy ngay hiệu ứng lịch
            let sampleEvents = SharedEventSeed.sampleEvents
            store.save(events: sampleEvents)
            events = sampleEvents.sorted { $0.startDate < $1.startDate }
        } else {
            events = loaded.sorted { $0.startDate < $1.startDate }
        }
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
        store.delete(eventID: event.id)
        load()
    }

    func delete(at offsets: IndexSet) {
        let removedEvents = offsets.map { events[$0] }
        removedEvents.forEach { store.delete(eventID: $0.id) }
        load()
    }

    func clearAll() {
        store.clearAllEvents()
        events = []
    }
}
