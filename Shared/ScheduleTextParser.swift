import Foundation

/// Bộ phân tích văn bản lịch trình thông minh tiếng Việt từ tin nhắn Zalo, Ghi chú, Messenger...
struct ScheduleTextParser {
    struct ParsedItem: Identifiable {
        let id = UUID()
        var dayOffset: Int // 0 = T2, 1 = T3, ..., 6 = CN
        var dayName: String
        var startHour: Int
        var startMinute: Int
        var endHour: Int
        var endMinute: Int
        var title: String
        var category: EventCategory
        var isAllDay: Bool
        var isSelected: Bool = true
    }

    /// Phân tích văn bản tự do thành danh sách các mục sự kiện
    static func parse(text: String, referenceDate: Date = Date()) -> [ParsedItem] {
        var results: [ParsedItem] = []
        let lines = text.components(separatedBy: .newlines)

        var currentDayOffset: Int? = nil

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            // 1. Kiểm tra dòng này có chứa tiêu đề ngày (Thứ 2, T3, CN...) không
            if let detectedDay = detectDayOfWeek(in: trimmed) {
                currentDayOffset = detectedDay

                // Kiểm tra xem trên cùng dòng có kèm luôn giờ và việc không (ví dụ: "T2 8h-10h Đi làm")
                if let item = parseTimeAndTitle(from: trimmed, dayOffset: detectedDay) {
                    results.append(item)
                }
                continue
            }

            // 2. Nếu dòng hiện tại là nội dung công việc thuộc ngày trước đó đã bắt gặp
            if let dayOffset = currentDayOffset {
                if let item = parseTimeAndTitle(from: trimmed, dayOffset: dayOffset) {
                    results.append(item)
                }
            }
        }

        return results
    }

    /// Nhận diện ngày trong tuần
    private static func detectDayOfWeek(in text: String) -> Int? {
        let lower = text.lowercased()

        // Thứ 2
        if containsAny(lower, ["thứ 2", "thứ hai", "thu 2", "thu hai", "t2", "mon", "monday"]) { return 0 }
        // Thứ 3
        if containsAny(lower, ["thứ 3", "thứ ba", "thu 3", "thu ba", "t3", "tue", "tuesday"]) { return 1 }
        // Thứ 4
        if containsAny(lower, ["thứ 4", "thứ tư", "thu 4", "thu tu", "t4", "wed", "wednesday"]) { return 2 }
        // Thứ 5
        if containsAny(lower, ["thứ 5", "thứ năm", "thu 5", "thu nam", "t5", "thu", "thursday"]) { return 3 }
        // Thứ 6
        if containsAny(lower, ["thứ 6", "thứ sáu", "thu 6", "thu sau", "t6", "fri", "friday"]) { return 4 }
        // Thứ 7
        if containsAny(lower, ["thứ 7", "thứ bảy", "thu 7", "thu bay", "t7", "sat", "saturday"]) { return 5 }
        // Chủ nhật
        if containsAny(lower, ["chủ nhật", "chu nhat", "cn", "sun", "sunday"]) { return 6 }

        return nil
    }

    private static func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        for kw in keywords {
            // Kiểm tra ranh giới từ để tránh nhầm (ví dụ "t2" trong "part2")
            if text.contains(kw) {
                return true
            }
        }
        return false
    }

    /// Bóc tách giờ bắt đầu, giờ kết thúc và tên công việc
    private static func parseTimeAndTitle(from text: String, dayOffset: Int) -> ParsedItem? {
        // Mẫu regex tìm khung giờ: ví dụ 08:00 - 10:00, 8h-10h, 8h30 - 10h15, 8g-10g, 8:00 đến 10:00
        let pattern = #"(\d{1,2})[hH:gG]?(\d{2})?\s*[-–—đếnto~]+\s*(\d{1,2})[hH:gG]?(\d{2})?"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

        var sH = 8
        var sM = 0
        var eH = 10
        var eM = 0
        var titleStartIndex = 0

        if let match = matches.first {
            // Bóc tách giờ bắt đầu
            if match.range(at: 1).location != NSNotFound {
                sH = Int(nsText.substring(with: match.range(at: 1))) ?? 8
            }
            if match.range(at: 2).location != NSNotFound {
                sM = Int(nsText.substring(with: match.range(at: 2))) ?? 0
            }

            // Bóc tách giờ kết thúc
            if match.range(at: 3).location != NSNotFound {
                eH = Int(nsText.substring(with: match.range(at: 3))) ?? (sH + 1)
            }
            if match.range(at: 4).location != NSNotFound {
                eM = Int(nsText.substring(with: match.range(at: 4))) ?? 0
            }

            titleStartIndex = match.range.location + match.range.length
        } else {
            // Kiểm tra nếu là "Cả ngày"
            let lower = text.lowercased()
            if lower.contains("cả ngày") || lower.contains("all day") {
                let cleanedTitle = cleanTitle(text.replacingOccurrences(of: "cả ngày", with: "", options: .caseInsensitive))
                return ParsedItem(
                    dayOffset: dayOffset,
                    dayName: weekdayName(for: dayOffset),
                    startHour: 8,
                    startMinute: 0,
                    endHour: 18,
                    endMinute: 0,
                    title: cleanedTitle.isEmpty ? "Lịch cả ngày" : cleanedTitle,
                    category: inferCategory(from: cleanedTitle),
                    isAllDay: true
                )
            }
            return nil
        }

        // Đảm bảo giờ kết thúc hợp lệ
        if eH < sH || (eH == sH && eM <= sM) {
            eH = min(23, sH + 1)
        }

        // Lấy tên công việc sau khung giờ
        var rawTitle = ""
        if titleStartIndex < nsText.length {
            rawTitle = nsText.substring(from: titleStartIndex)
        } else {
            rawTitle = text
        }

        let finalTitle = cleanTitle(rawTitle)
        guard !finalTitle.isEmpty else { return nil }

        return ParsedItem(
            dayOffset: dayOffset,
            dayName: weekdayName(for: dayOffset),
            startHour: sH,
            startMinute: sM,
            endHour: eH,
            endMinute: eM,
            title: finalTitle,
            category: inferCategory(from: finalTitle),
            isAllDay: false
        )
    }

    /// Làm sạch tiêu đề: bỏ dấu gạch đầu dòng, dấu hai chấm...
    private static func cleanTitle(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let removeChars: CharacterSet = [":", "-", "–", "—", "*", "•", ";", " "]
        s = s.trimmingCharacters(in: removeChars)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Tự động đoán danh mục màu sắc dựa vào từ khóa
    private static func inferCategory(from text: String) -> EventCategory {
        let lower = text.lowercased()
        if containsAny(lower, ["họp", "meeting", "làm", "work", "kpi", "báo cáo", "dự án", "deadline", "công ty", "task", "code", "khách"]) {
            return .work
        }
        if containsAny(lower, ["gym", "chạy", "bơi", "yoga", "khám", "thuốc", "thể dục", "relax", "spa", "đi dạo"]) {
            return .health
        }
        if containsAny(lower, ["học", "study", "thi", "đọc sách", "lớp", "tiếng anh", "ôn", "bài tập", "lecture"]) {
            return .study
        }
        if containsAny(lower, ["gia đình", "mẹ", "bố", "con", "chợ", "siêu thị", "nấu", "family", "vợ", "chồng", "nhà"]) {
            return .family
        }
        if containsAny(lower, ["cafe", "cà phê", "bạn", "phim", "du lịch", "mua sắm", "shopee", "chill", "ăn trưa", "ăn tối", "quán"]) {
            return .personal
        }
        return .other
    }

    private static func weekdayName(for offset: Int) -> String {
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
