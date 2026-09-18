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
    var hasReminder: Bool

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        category: EventCategory = .other,
        isAllDay: Bool = false,
        isRecurringWeekly: Bool = false,
        hasReminder: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.isAllDay = isAllDay
        self.isRecurringWeekly = isRecurringWeekly
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
        hasReminder = try container.decodeIfPresent(Bool.self, forKey: .hasReminder) ?? false
    }
}
