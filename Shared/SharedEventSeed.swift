import Foundation

/// Dữ liệu mẫu Tiếng Việt thực tế dùng cho preview và tự động nạp khi cài app.
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

        // T2 (Thứ Hai)
        if let d0 = dates[safe: 0] {
            list.append(CalendarEvent(
                title: "Họp Giao Ban Đầu Tuần",
                startDate: d0.addingTimeInterval(60 * 60 * 8),
                endDate: d0.addingTimeInterval(60 * 60 * 9 + 60 * 30),
                category: .work,
                isRecurringWeekly: true
            ))
            list.append(CalendarEvent(
                title: "Xử Lý Dự Án Mới",
                startDate: d0.addingTimeInterval(60 * 60 * 14),
                endDate: d0.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                category: .work
            ))
        }

        // T3 (Thứ Ba)
        if let d1 = dates[safe: 1] {
            list.append(CalendarEvent(
                title: "Chạy Bộ & Gym",
                startDate: d1.addingTimeInterval(60 * 60 * 6),
                endDate: d1.addingTimeInterval(60 * 60 * 7),
                category: .health,
                isRecurringWeekly: true
            ))
            list.append(CalendarEvent(
                title: "Gặp Khách Hàng",
                startDate: d1.addingTimeInterval(60 * 60 * 9 + 60 * 30),
                endDate: d1.addingTimeInterval(60 * 60 * 11 + 60 * 30),
                category: .work
            ))
            list.append(CalendarEvent(
                title: "Học Tiếng Anh",
                startDate: d1.addingTimeInterval(60 * 60 * 19 + 60 * 30),
                endDate: d1.addingTimeInterval(60 * 60 * 21),
                category: .study
            ))
        }

        // T4 (Thứ Tư)
        if let d2 = dates[safe: 2] {
            list.append(CalendarEvent(
                title: "Báo Cáo Tiến Độ Tuần",
                startDate: d2.addingTimeInterval(60 * 60 * 8 + 60 * 30),
                endDate: d2.addingTimeInterval(60 * 60 * 10 + 60 * 30),
                category: .work
            ))
            list.append(CalendarEvent(
                title: "Đào Tạo Nội Bộ",
                startDate: d2.addingTimeInterval(60 * 60 * 14 + 60 * 30),
                endDate: d2.addingTimeInterval(60 * 60 * 16 + 60 * 30),
                category: .study
            ))
        }

        // T5 (Thứ Năm)
        if let d3 = dates[safe: 3] {
            list.append(CalendarEvent(
                title: "Họp Team Marketing",
                startDate: d3.addingTimeInterval(60 * 60 * 9),
                endDate: d3.addingTimeInterval(60 * 60 * 10 + 60 * 30),
                category: .work
            ))
            list.append(CalendarEvent(
                title: "Tập Yoga Thư Giãn",
                startDate: d3.addingTimeInterval(60 * 60 * 18),
                endDate: d3.addingTimeInterval(60 * 60 * 19 + 60 * 30),
                category: .health,
                hasReminder: true
            ))
        }

        // T6 (Thứ Sáu)
        if let d4 = dates[safe: 4] {
            list.append(CalendarEvent(
                title: "Hoàn Thành Deadline Tuần",
                startDate: d4.addingTimeInterval(60 * 60 * 8 + 60 * 30),
                endDate: d4.addingTimeInterval(60 * 60 * 11 + 60 * 30),
                category: .work
            ))
            list.append(CalendarEvent(
                title: "Đi Siêu Thị Mua Sắm",
                startDate: d4.addingTimeInterval(60 * 60 * 17 + 60 * 30),
                endDate: d4.addingTimeInterval(60 * 60 * 19),
                category: .family
            ))
            list.append(CalendarEvent(
                title: "Cà Phê Cùng Bạn Bè",
                startDate: d4.addingTimeInterval(60 * 60 * 19 + 60 * 30),
                endDate: d4.addingTimeInterval(60 * 60 * 21 + 60 * 30),
                category: .personal,
                hasReminder: true
            ))
        }

        // T7 (Thứ Bảy)
        if let d5 = dates[safe: 5] {
            list.append(CalendarEvent(
                title: "Dọn Dẹp Nhà Cửa",
                startDate: d5.addingTimeInterval(60 * 60 * 8),
                endDate: d5.addingTimeInterval(60 * 60 * 10),
                category: .family
            ))
            list.append(CalendarEvent(
                title: "Đọc Sách & Thư Giãn",
                startDate: d5.addingTimeInterval(60 * 60 * 15),
                endDate: d5.addingTimeInterval(60 * 60 * 17 + 60 * 30),
                category: .study
            ))
        }

        // CN (Chủ Nhật)
        if let d6 = dates[safe: 6] {
            list.append(CalendarEvent(
                title: "Nghỉ Ngơi & Về Quê",
                startDate: Calendar.current.startOfDay(for: d6),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: d6)) ?? d6,
                category: .personal,
                isAllDay: true
            ))
            list.append(CalendarEvent(
                title: "Ăn Tối Cùng Gia Đình",
                startDate: d6.addingTimeInterval(60 * 60 * 18),
                endDate: d6.addingTimeInterval(60 * 60 * 20),
                category: .family,
                hasReminder: true
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
