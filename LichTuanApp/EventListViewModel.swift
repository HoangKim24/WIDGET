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
        let hasCleanedLegacySeedKey = "hasCleanedLegacySeed_v2"
        let hasCleaned = UserDefaults.standard.bool(forKey: hasCleanedLegacySeedKey)
        if !hasCleaned {
            // Tự động dọn sạch các sự kiện mẫu (Do exe, Relax...) đã từng bị nạp trước đây
            store.clearAllEvents()
            UserDefaults.standard.set(true, forKey: hasCleanedLegacySeedKey)
            events = []
            return
        }

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
