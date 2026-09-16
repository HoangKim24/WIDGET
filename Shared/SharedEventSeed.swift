import Foundation

/// Dữ liệu mẫu dùng cho preview và khởi tạo ban đầu khi chưa có sự kiện thật.
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
        let dates = sampleWeekDates

        return [
            CalendarEvent(
                title: "Họp kế hoạch tuần mới",
                startDate: dates[safe: 0]?.addingTimeInterval(60 * 60 * 9) ?? Date(),
                endDate: dates[safe: 0]?.addingTimeInterval(60 * 60 * 10) ?? Date(),
                category: .work
            ),
            CalendarEvent(
                title: "Cafe cùng bạn bè",
                startDate: dates[safe: 1]?.addingTimeInterval(60 * 60 * 18) ?? Date(),
                endDate: dates[safe: 1]?.addingTimeInterval(60 * 60 * 19) ?? Date(),
                category: .personal
            ),
            CalendarEvent(
                title: "Tập gym & chạy bộ",
                startDate: dates[safe: 2]?.addingTimeInterval(60 * 60 * 7) ?? Date(),
                endDate: dates[safe: 2]?.addingTimeInterval(60 * 60 * 8) ?? Date(),
                category: .health
            ),
            CalendarEvent(
                title: "Học bài & ôn tập",
                startDate: dates[safe: 3]?.addingTimeInterval(60 * 60 * 20) ?? Date(),
                endDate: dates[safe: 3]?.addingTimeInterval(60 * 60 * 21) ?? Date(),
                category: .study
            ),
            CalendarEvent(
                title: "Bữa tối gia đình",
                startDate: dates[safe: 4]?.addingTimeInterval(60 * 60 * 19) ?? Date(),
                endDate: dates[safe: 4]?.addingTimeInterval(60 * 60 * 21) ?? Date(),
                category: .family
            ),
            CalendarEvent(
                title: "Mua sắm cuối tuần",
                startDate: dates[safe: 5]?.addingTimeInterval(60 * 60 * 10) ?? Date(),
                endDate: dates[safe: 5]?.addingTimeInterval(60 * 60 * 12) ?? Date(),
                category: .other
            ),
            CalendarEvent(
                title: "Nghỉ ngơi & thư giãn",
                startDate: Calendar.current.startOfDay(for: dates[safe: 6] ?? Date()),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: dates[safe: 6] ?? Date())) ?? Date(),
                category: .personal,
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
