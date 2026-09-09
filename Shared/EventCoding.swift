import Foundation

/// Bộ mã hóa/giải mã dùng chung cho mọi nơi đọc ghi sự kiện,
/// bảo đảm app chính và widget luôn hiểu cùng một định dạng JSON.
enum EventCoding {
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// Chuyển danh sách sự kiện thành chuỗi JSON để đẩy lên Gist.
    static func jsonString(from events: [CalendarEvent]) throws -> String {
        let data = try encoder.encode(events)
        guard let text = String(data: data, encoding: .utf8) else {
            throw RemoteSyncError.encodingFailed
        }

        return text
    }

    /// Đọc danh sách sự kiện từ chuỗi JSON tải về.
    static func events(fromJSON text: String) throws -> [CalendarEvent] {
        guard let data = text.data(using: .utf8) else {
            throw RemoteSyncError.encodingFailed
        }

        return try decoder.decode([CalendarEvent].self, from: data)
    }
}
