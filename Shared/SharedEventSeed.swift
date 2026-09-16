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
        var list: [CalendarEvent] = []

        // Mon (index 0)
        if let d0 = dates[safe: 0] {
            list.append(CalendarEvent(
                title: "Do exe",
                startDate: d0.addingTimeInterval(60 * 60 * 8),
                endDate: d0.addingTimeInterval(60 * 60 * 10),
                category: .family
            ))
            list.append(CalendarEvent(
                title: "Relax",
                startDate: d0.addingTimeInterval(60 * 60 * 10),
                endDate: d0.addingTimeInterval(60 * 60 * 10 + 60 * 20),
                category: .health
            ))
        }

        // Tue (index 1)
        if let d1 = dates[safe: 1] {
            list.append(CalendarEvent(
                title: "Wake up and gym",
                startDate: d1.addingTimeInterval(60 * 60 * 5 + 60 * 30),
                endDate: d1.addingTimeInterval(60 * 60 * 10),
                category: .personal
            ))
            list.append(CalendarEvent(
                title: "Lunch with Jo",
                startDate: d1.addingTimeInterval(60 * 60 * 12),
                endDate: d1.addingTimeInterval(60 * 60 * 13),
                category: .health
            ))
            list.append(CalendarEvent(
                title: "Meetings",
                startDate: d1.addingTimeInterval(60 * 60 * 13 + 60 * 30),
                endDate: d1.addingTimeInterval(60 * 60 * 14),
                category: .study
            ))
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d1.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                endDate: d1.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        // Wed (index 2)
        if let d2 = dates[safe: 2] {
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d2.addingTimeInterval(60 * 60 * 10 + 60 * 30),
                endDate: d2.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        // Thu (index 3)
        if let d3 = dates[safe: 3] {
            list.append(CalendarEvent(
                title: "Meetings",
                startDate: d3.addingTimeInterval(60 * 60 * 13 + 60 * 30),
                endDate: d3.addingTimeInterval(60 * 60 * 14),
                category: .study
            ))
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d3.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                endDate: d3.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        // Fri (index 4)
        if let d4 = dates[safe: 4] {
            list.append(CalendarEvent(
                title: "Shopee",
                startDate: d4.addingTimeInterval(60 * 60 * 14),
                endDate: d4.addingTimeInterval(60 * 60 * 15),
                category: .family
            ))
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d4.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                endDate: d4.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        // Sat (index 5)
        if let d5 = dates[safe: 5] {
            list.append(CalendarEvent(
                title: "Meetings",
                startDate: d5.addingTimeInterval(60 * 60 * 13 + 60 * 30),
                endDate: d5.addingTimeInterval(60 * 60 * 14),
                category: .study
            ))
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d5.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                endDate: d5.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        // Sun (index 6)
        if let d6 = dates[safe: 6] {
            list.append(CalendarEvent(
                title: "8/3",
                startDate: Calendar.current.startOfDay(for: d6),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: d6)) ?? d6,
                category: .personal,
                isAllDay: true
            ))
            list.append(CalendarEvent(
                title: "Reviewing KPIs",
                startDate: d6.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                endDate: d6.addingTimeInterval(60 * 60 * 17),
                category: .work
            ))
        }

        return list
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
