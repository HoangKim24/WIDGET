import Foundation
import WidgetKit

/// Trạng thái đồng bộ hiển thị cho người dùng trên màn hình chính.
enum SyncStatus: Equatable {
    case idle
    case syncing
    case success(Date)
    case failure(String)
}

/// View model tối thiểu cho màn hình CRUD sự kiện của app chính.
///
/// Mỗi thay đổi được lưu cục bộ trước cho phản hồi tức thì, sau đó đẩy lên Gist
/// để widget đọc được cùng dữ liệu mà không cần App Group.
@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []
    @Published private(set) var syncStatus: SyncStatus = .idle

    private let store: SharedDataStore
    private let settings: RemoteSyncSettingsStore
    private let client: GistSyncClient

    init(
        store: SharedDataStore = .shared,
        settings: RemoteSyncSettingsStore = .shared,
        client: GistSyncClient = .shared
    ) {
        self.store = store
        self.settings = settings
        self.client = client
    }

    var isRemoteSyncReady: Bool {
        RemoteSyncConfig.isConfigured && settings.hasToken
    }

    func load() {
        events = store.loadEvents().sorted { $0.startDate < $1.startDate }
    }

    func add(_ event: CalendarEvent) {
        store.add(event: event)
        load()
        syncToRemote()
    }

    func update(_ event: CalendarEvent) {
        store.update(event: event)
        load()
        syncToRemote()
    }

    func delete(_ event: CalendarEvent) {
        store.delete(eventID: event.id)
        load()
        syncToRemote()
    }

    func delete(at offsets: IndexSet) {
        let removedEvents = offsets.map { events[$0] }
        removedEvents.forEach { store.delete(eventID: $0.id) }
        load()
        syncToRemote()
    }

    func clearAll() {
        store.clearAllEvents()
        load()
        syncToRemote()
    }

    /// Đẩy dữ liệu hiện tại lên Gist rồi yêu cầu widget vẽ lại.
    func syncToRemote() {
        guard RemoteSyncConfig.isConfigured else {
            syncStatus = .failure(RemoteSyncError.notConfigured.localizedDescription)
            return
        }

        guard settings.hasToken else {
            syncStatus = .failure(RemoteSyncError.missingToken.localizedDescription)
            return
        }

        let snapshot = events
        let token = settings.token
        syncStatus = .syncing

        Task {
            do {
                try await client.pushEvents(snapshot, token: token)
                syncStatus = .success(Date())
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                syncStatus = .failure(error.localizedDescription)
            }
        }
    }

    /// Kéo dữ liệu từ Gist về máy, dùng khi cài lại app hoặc đổi thiết bị.
    func pullFromRemote() {
        guard RemoteSyncConfig.isConfigured else {
            syncStatus = .failure(RemoteSyncError.notConfigured.localizedDescription)
            return
        }

        syncStatus = .syncing

        Task {
            do {
                let remoteEvents = try await client.fetchEvents()
                store.save(events: remoteEvents)
                load()
                syncStatus = .success(Date())
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                syncStatus = .failure(error.localizedDescription)
            }
        }
    }
}
