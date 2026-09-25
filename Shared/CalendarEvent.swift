import Foundation

/// Dữ liệu một sự kiện lịch đơn lẻ, lưu cục bộ và đồng bộ lên Gist.
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var category: EventCategory
    var isAllDay: Bool
    var isRecurringWeekly: Bool
    var recurrenceEndDate: Date? // Khóa ngày dừng lặp (nếu có)
    var hasReminder: Bool

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        category: EventCategory = .other,
        isAllDay: Bool = false,
        isRecurringWeekly: Bool = false,
        recurrenceEndDate: Date? = nil,
        hasReminder: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.isAllDay = isAllDay
        self.isRecurringWeekly = isRecurringWeekly
        self.recurrenceEndDate = recurrenceEndDate
        self.hasReminder = hasReminder
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case startDate
        case endDate
        case category
        case isAllDay
        case isRecurringWeekly
        case recurrenceEndDate
        case hasReminder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        category = try container.decodeIfPresent(EventCategory.self, forKey: .category) ?? .other
        isAllDay = try container.decode(Bool.self, forKey: .isAllDay)
        isRecurringWeekly = try container.decodeIfPresent(Bool.self, forKey: .isRecurringWeekly) ?? false
        recurrenceEndDate = try container.decodeIfPresent(Date.self, forKey: .recurrenceEndDate)
        hasReminder = try container.decodeIfPresent(Bool.self, forKey: .hasReminder) ?? false
    }

    /// Kiểm tra xem sự kiện có diễn ra vào ngày `targetDate` hay không (tính cả lặp lại hàng tuần, sự kiện kéo dài nhiều ngày và khóa giới hạn lặp)
    func occurs(on targetDate: Date, calendar: Calendar = .current) -> Bool {
        let targetStart = calendar.startOfDay(for: targetDate)
        let eventStart = calendar.startOfDay(for: startDate)
        let eventEnd = calendar.startOfDay(for: endDate)

        // 1. Kiểm tra sự kiện diễn ra trong ngày hoặc kéo dài qua nhiều ngày
        if targetStart >= eventStart && targetStart <= eventEnd {
            return true
        }

        // 2. Kiểm tra sự kiện lặp lại hàng tuần
        guard isRecurringWeekly else { return false }

        // Không diễn ra trước ngày bắt đầu
        if targetDate < eventStart {
            return false
        }

        // Khóa lặp: Nếu có ngày kết thúc lặp và targetDate vượt quá ngày đó thì dừng
        if let recurrenceEndDate = recurrenceEndDate {
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: recurrenceEndDate) ?? recurrenceEndDate
            if targetDate > endOfDay {
                return false
            }
        }

        let targetWeekday = calendar.component(.weekday, from: targetDate)
        let startWeekday = calendar.component(.weekday, from: startDate)
        return targetWeekday == startWeekday
    }
}
