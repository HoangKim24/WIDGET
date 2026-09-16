import Foundation

enum EventCodingError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Không thể mã hóa hoặc giải mã dữ liệu sự kiện."
        }
    }
}

/// Bộ mã hóa/giải mã dùng chung cho mọi nơi đọc ghi sự kiện.
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

    /// Chuyển danh sách sự kiện thành chuỗi JSON.
    static func jsonString(from events: [CalendarEvent]) throws -> String {
        let data = try encoder.encode(events)
        guard let text = String(data: data, encoding: .utf8) else {
            throw EventCodingError.encodingFailed
        }

        return text
    }

    /// Đọc danh sách sự kiện từ chuỗi JSON.
    static func events(fromJSON text: String) throws -> [CalendarEvent] {
        guard let data = text.data(using: .utf8) else {
            throw EventCodingError.encodingFailed
        }

        return try decoder.decode([CalendarEvent].self, from: data)
    }
}
