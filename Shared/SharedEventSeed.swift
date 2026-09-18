import Foundation

/// Dữ liệu mẫu ban đầu (đã được dọn sạch theo yêu cầu người dùng).
enum SharedEventSeed {
    static var sampleWeekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    static var sampleEvents: [CalendarEvent] {
        return []
    }
}