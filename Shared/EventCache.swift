import Foundation

/// Bộ nhớ đệm nằm trong sandbox của từng process.
///
/// App chính và widget mỗi bên giữ một bản sao riêng, không dùng chung App Group.
/// Dữ liệu thật được đồng bộ qua Gist, cache chỉ để hiển thị ngay khi mở
/// và để widget vẫn có nội dung khi mất mạng.
struct EventCache {
    static let widget = EventCache(fileName: "cached-events-widget.json")

    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    /// Dùng Application Support thay vì Caches vì iOS có thể xoá Caches bất cứ lúc nào.
    private var fileURL: URL? {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory.appendingPathComponent(fileName)
    }

    /// Ngày giờ cache được ghi lần cuối, dùng để giới hạn số lần gọi mạng.
    var lastUpdated: Date? {
        guard
            let fileURL,
            let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        else {
            return nil
        }

        return attributes[.modificationDate] as? Date
    }

    func load() -> [CalendarEvent] {
        guard
            let fileURL,
            let data = try? Data(contentsOf: fileURL),
            let events = try? EventCoding.decoder.decode([CalendarEvent].self, from: data)
        else {
            return []
        }

        return events.sorted { $0.startDate < $1.startDate }
    }

    func save(_ events: [CalendarEvent]) {
        guard
            let fileURL,
            let data = try? EventCoding.encoder.encode(events.sorted { $0.startDate < $1.startDate })
        else {
            return
        }

        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        guard let fileURL else {
            return
        }

        try? FileManager.default.removeItem(at: fileURL)
    }

    /// Cache đã quá cũ so với khoảng thời gian tối thiểu giữa hai lần gọi mạng.
    func isStale(now: Date = Date(), interval: TimeInterval = RemoteSyncConfig.minimumFetchInterval) -> Bool {
        guard let lastUpdated else {
            return true
        }

        return now.timeIntervalSince(lastUpdated) >= interval
    }
}
