import Foundation

/// View model tối thiểu cho màn hình CRUD sự kiện của app chính.
@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []

    func load() {
        events = SharedDataStore.shared.loadEvents().sorted { $0.startDate < $1.startDate }
    }

    func add(_ event: CalendarEvent) {
        SharedDataStore.shared.add(event: event)
        load()
    }

    func update(_ event: CalendarEvent) {
        SharedDataStore.shared.update(event: event)
        load()
    }

    func delete(_ event: CalendarEvent) {
        SharedDataStore.shared.delete(eventID: event.id)
        load()
    }

    func delete(at offsets: IndexSet) {
        offsets.map { events[$0] }.forEach { delete($0) }
    }

    func clearAll() {
        SharedDataStore.shared.clearAllEvents()
        load()
    }
}
