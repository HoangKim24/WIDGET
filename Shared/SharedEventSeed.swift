import Foundation

/// Dữ liệu mẫu dùng cho preview và test UI khi chưa có sự kiện thật.
enum SharedEventSeed {
    static var sampleWeekDates: [Date] {
        let calendar = Calendar.autoupdatingCurrent
        let weekStart = WeekTimelineBuilder.startOfWeek(containing: .now, calendar: calendar)

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    static var sampleEvents: [CalendarEvent] {
        let dates = sampleWeekDates

        return [
            CalendarEvent(
                title: "Design review with product and engineering",
                startDate: dates[safe: 0]?.addingTimeInterval(60 * 60 * 9) ?? .now,
                endDate: dates[safe: 0]?.addingTimeInterval(60 * 60 * 10) ?? .now,
                category: .work
            ),
            CalendarEvent(
                title: "Coffee with Minh",
                startDate: dates[safe: 1]?.addingTimeInterval(60 * 60 * 18) ?? .now,
                endDate: dates[safe: 1]?.addingTimeInterval(60 * 60 * 19) ?? .now,
                category: .personal
            ),
            CalendarEvent(
                title: "Gym + mobility",
                startDate: dates[safe: 2]?.addingTimeInterval(60 * 60 * 7) ?? .now,
                endDate: dates[safe: 2]?.addingTimeInterval(60 * 60 * 8) ?? .now,
                category: .health
            ),
            CalendarEvent(
                title: "SwiftUI chapter reading",
                startDate: dates[safe: 3]?.addingTimeInterval(60 * 60 * 20) ?? .now,
                endDate: dates[safe: 3]?.addingTimeInterval(60 * 60 * 21) ?? .now,
                category: .study
            ),
            CalendarEvent(
                title: "Family dinner",
                startDate: dates[safe: 4]?.addingTimeInterval(60 * 60 * 19) ?? .now,
                endDate: dates[safe: 4]?.addingTimeInterval(60 * 60 * 21) ?? .now,
                category: .family
            ),
            CalendarEvent(
                title: "Grocery and errands",
                startDate: dates[safe: 5]?.addingTimeInterval(60 * 60 * 11) ?? .now,
                endDate: dates[safe: 5]?.addingTimeInterval(60 * 60 * 12) ?? .now,
                category: .other
            ),
            CalendarEvent(
                title: "All-day planning block",
                startDate: Calendar.autoupdatingCurrent.startOfDay(for: dates[safe: 6] ?? .now),
                endDate: Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: Calendar.autoupdatingCurrent.startOfDay(for: dates[safe: 6] ?? .now)) ?? .now,
                category: .work,
                isAllDay: true
            )
        ]
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
