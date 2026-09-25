import Foundation
import SwiftUI

/// Tiện ích chuẩn hóa xử lý ngày tháng, thứ trong tuần và định dạng giờ cho toàn bộ app.
/// Sử dụng các DateFormatter tĩnh được khởi tạo 1 lần để tối ưu hiệu năng (tránh khởi tạo lại trong vòng lặp SwiftUI).
enum DateTimeUtils {

    // MARK: - Formatters Tĩnh Tối Ưu Hiệu Năng

    /// Định dạng giờ phút: 08:00, 14:30
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    /// Định dạng ngày tháng ngắn: 25/09
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()

    /// Định dạng năm: 2026
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    /// Định dạng thứ và ngày tiếng Việt: Thứ Năm, 25/09
    static let fullVietnameseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, dd/MM"
        return formatter
    }()

    /// Định dạng ngày màn hình khóa iPhone: Thứ Năm, 25 thg 9
    static let lockScreenDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d 'thg' M"
        return formatter
    }()

    // MARK: - Chuyển Đổi Thứ Tiếng Việt Chuẩn

    /// Tên thứ viết tắt tiếng Việt chuẩn (T2, T3, T4, T5, T6, T7, CN)
    static func vietnameseWeekdayShort(for date: Date, calendar: Calendar = .current) -> String {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return "CN"
        case 2: return "T2"
        case 3: return "T3"
        case 4: return "T4"
        case 5: return "T5"
        case 6: return "T6"
        case 7: return "T7"
        default: return ""
        }
    }

    /// Tên thứ theo offset từ Thứ 2 (0 = T2, 1 = T3, ..., 6 = CN)
    static func vietnameseWeekdayName(for offset: Int) -> String {
        switch offset {
        case 0: return "T2"
        case 1: return "T3"
        case 2: return "T4"
        case 3: return "T5"
        case 4: return "T6"
        case 5: return "T7"
        case 6: return "CN"
        default: return ""
        }
    }
}

// MARK: - Tiện Ích Mở Rộng Calendar
extension Calendar {

    /// Lấy thời điểm bắt đầu ngày Thứ 2 của tuần chứa `date`
    func startOfWeek(for date: Date = Date()) -> Date {
        let dayStart = startOfDay(for: date)
        let weekday = component(.weekday, from: dayStart)
        let daysFromMonday = (weekday + 5) % 7
        return self.date(byAdding: .day, value: -daysFromMonday, to: dayStart) ?? dayStart
    }

    /// Lấy danh sách 7 ngày trong tuần (Thứ 2 -> Chủ Nhật), có thể bù trừ số tuần (offsetWeeks)
    func weekDays(for date: Date = Date(), offsetWeeks: Int = 0) -> [Date] {
        let monday = startOfWeek(for: date)
        let targetMonday = self.date(byAdding: .day, value: offsetWeeks * 7, to: monday) ?? monday
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: targetMonday) }
    }
}

// MARK: - Tiện Ích Mở Rộng Date
extension Date {
    /// Tên thứ ngắn tiếng Việt ("T2" -> "CN")
    var vietnameseWeekdayShort: String {
        DateTimeUtils.vietnameseWeekdayShort(for: self)
    }

    /// Chuỗi ngày tháng ngắn ("25/09")
    var shortDateString: String {
        DateTimeUtils.shortDateFormatter.string(from: self)
    }

    /// Chuỗi thứ ngày đầy đủ ("Thứ Năm, 25/09")
    var vietnameseFullDateString: String {
        DateTimeUtils.fullVietnameseDateFormatter.string(from: self).capitalized
    }

    /// Chuỗi giờ phút ("08:30")
    var timeString: String {
        DateTimeUtils.timeFormatter.string(from: self)
    }
}

// MARK: - Tiện Ích Mở Rộng CalendarEvent
extension CalendarEvent {
    /// Chuỗi hiển thị khung giờ chuẩn hóa (ví dụ: "08:00–10:00" hoặc "Cả ngày")
    var formattedTimeRange: String {
        if isAllDay { return "Cả ngày" }
        return "\(startDate.timeString)–\(endDate.timeString)"
    }

    /// Kiểm tra xem 2 sự kiện có bị trùng lặp thời gian và tiêu đề (trong vòng 60 giây)
    func isDuplicate(of other: CalendarEvent) -> Bool {
        title == other.title &&
        abs(startDate.timeIntervalSince(other.startDate)) < 60 &&
        abs(endDate.timeIntervalSince(other.endDate)) < 60
    }
}
