import Foundation

/// Bộ phân tích văn bản lịch trình thông minh (AI Prompt-to-Calendar Engine)
/// Hỗ trợ bóc tách câu nói tự nhiên tiếng Việt, đa ngày (2-4-6, 3-5-7), các buổi trong ngày (sáng, chiều, tối),
/// tin nhắn Zalo, Messenger, Ghi chú và thời khóa biểu quét từ Camera.
struct ScheduleTextParser {
    struct ParsedItem: Identifiable, Equatable {
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
        let rawClauses = splitIntoClauses(text)

        var lastEncounteredDays: [Int] = []

        for clause in rawClauses {
            let trimmed = clause.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            // 1. Nhận diện các ngày trong mệnh đề (hỗ trợ cả nhóm ngày 2-4-6, 3-5-7, t7-cn)
            let detectedDays = detectDaysOfWeek(in: trimmed)

            if !detectedDays.isEmpty {
                lastEncounteredDays = detectedDays
            }

            let targetDays = !detectedDays.isEmpty ? detectedDays : lastEncounteredDays
            if targetDays.isEmpty { continue }

            // 2. Bóc tách giờ và tiêu đề sự kiện
            if let details = extractTimeAndTitle(from: trimmed) {
                for day in targetDays {
                    results.append(
                        ParsedItem(
                            dayOffset: day,
                            dayName: DateTimeUtils.vietnameseWeekdayName(for: day),
                            startHour: details.sH,
                            startMinute: details.sM,
                            endHour: details.eH,
                            endMinute: details.eM,
                            title: details.title,
                            category: EventCategory.infer(from: details.title),
                            isAllDay: details.isAllDay
                        )
                    )
                }
            }
        }

        // Sắp xếp theo thứ tự ngày trong tuần và giờ bắt đầu
        return results.sorted {
            if $0.dayOffset != $1.dayOffset {
                return $0.dayOffset < $1.dayOffset
            }
            if $0.startHour != $1.startHour {
                return $0.startHour < $1.startHour
            }
            return $0.startMinute < $1.startMinute
        }
    }

    // MARK: - 1. Tách Câu & Mệnh Đề Tự Nhiên
    private static func splitIntoClauses(_ text: String) -> [String] {
        var clauses: [String] = []

        // Tách theo dòng trước
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty { continue }

            // Tách tiếp theo dấu chấm phẩy, dấu gạch nối đầu dòng, hoặc dấu phẩy (nếu không nằm trong cụm số 2,4,6)
            // Thay thế "2, 4, 6" tạm thời để không bị ngắt
            var normalized = trimmedLine
            normalized = normalized.replacingOccurrences(of: #"(?<=\d),\s*(?=\d)"#, with: "_", options: .regularExpression)

            // Tách theo dấu phẩy, chấm, chấm phẩy, hoặc " ngoài ra ", " rồi "
            let separators = CharacterSet(charactersIn: ";.,\n")
            let parts = normalized.components(separatedBy: separators)

            for part in parts {
                let restored = part.replacingOccurrences(of: "_", with: ",")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !restored.isEmpty {
                    clauses.append(restored)
                }
            }
        }

        return clauses
    }

    // MARK: - 2. Nhận Diện Nhóm Ngày (2-4-6, 3-5-7, Cuối Tuần...)
    static func detectDaysOfWeek(in text: String) -> [Int] {
        let lower = text.lowercased()

        // Nhóm 2-4-6 (Thứ 2, Thứ 4, Thứ 6)
        if lower.contains("2-4-6") || lower.contains("2,4,6") || lower.contains("2 4 6") ||
           lower.contains("2, 4, 6") || lower.contains("thứ 2, 4, 6") || lower.contains("thu 2, 4, 6") ||
           lower.contains("t2, t4, t6") || lower.contains("t2-t4-t6") {
            return [0, 2, 4]
        }

        // Nhóm 3-5-7 (Thứ 3, Thứ 5, Thứ 7)
        if lower.contains("3-5-7") || lower.contains("3,5,7") || lower.contains("3 5 7") ||
           lower.contains("3, 5, 7") || lower.contains("thứ 3, 5, 7") || lower.contains("thu 3, 5, 7") ||
           lower.contains("t3, t5, t7") || lower.contains("t3-t5-t7") {
            return [1, 3, 5]
        }

        // Nhóm Cuối tuần (Thứ 7, Chủ Nhật)
        if lower.contains("cuối tuần") || lower.contains("cuoi tuan") ||
           lower.contains("t7, cn") || lower.contains("t7-cn") || lower.contains("t7 và cn") {
            return [5, 6]
        }

        // Nhóm Trong tuần (Thứ 2 đến Thứ 6)
        if lower.contains("trong tuần") || lower.contains("từ thứ 2 đến thứ 6") || lower.contains("t2-t6") {
            return [0, 1, 2, 3, 4]
        }

        // Từng ngày đơn lẻ
        var singleDays: [Int] = []
        if matchesDayKeywords(lower, ["thứ 2", "thứ hai", "thu 2", "thu hai", "t2", "monday", "mon"]) { singleDays.append(0) }
        if matchesDayKeywords(lower, ["thứ 3", "thứ ba", "thu 3", "thu ba", "t3", "tuesday", "tue"]) { singleDays.append(1) }
        if matchesDayKeywords(lower, ["thứ 4", "thứ tư", "thu 4", "thu tu", "t4", "wednesday", "wed"]) { singleDays.append(2) }
        if matchesDayKeywords(lower, ["thứ 5", "thứ năm", "thu 5", "thu nam", "t5", "thursday"]) { singleDays.append(3) }
        if matchesDayKeywords(lower, ["thứ 6", "thứ sáu", "thu 6", "thu sau", "t6", "friday", "fri"]) { singleDays.append(4) }
        if matchesDayKeywords(lower, ["thứ 7", "thứ bảy", "thu 7", "thu bay", "t7", "saturday", "sat"]) { singleDays.append(5) }
        if matchesDayKeywords(lower, ["chủ nhật", "chu nhat", "cn", "sunday", "sun"]) { singleDays.append(6) }

        return singleDays
    }

    private static func matchesDayKeywords(_ text: String, _ keywords: [String]) -> Bool {
        for kw in keywords {
            if kw.contains(" ") {
                if text.contains(kw) { return true }
            } else {
                let escaped = NSRegularExpression.escapedPattern(for: kw)
                let pattern = "(^|[^\\p{L}\\p{N}])\(escaped)($|[^\\p{L}\\p{N}])"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(location: 0, length: (text as NSString).length)
                    if regex.firstMatch(in: text, options: [], range: range) != nil {
                        return true
                    }
                }
            }
        }
        return false
    }

    // MARK: - 3. Bóc Tách Khung Giờ & Tiêu Đề
    private struct ExtractedDetails {
        let sH: Int
        let sM: Int
        let eH: Int
        let eM: Int
        let title: String
        let isAllDay: Bool
    }

    private static func extractTimeAndTitle(from text: String) -> ExtractedDetails? {
        let lower = text.lowercased()

        // 1. Trường hợp cả ngày
        if lower.contains("cả ngày") || lower.contains("all day") {
            let cleaned = stripDayAndPeriodWords(from: text)
            let finalTitle = cleanTitle(cleaned.replacingOccurrences(of: "cả ngày", with: "", options: .caseInsensitive)
                                              .replacingOccurrences(of: "all day", with: "", options: .caseInsensitive))
            return ExtractedDetails(
                sH: 8, sM: 0, eH: 18, eM: 0,
                title: finalTitle.isEmpty ? "Lịch cả ngày" : finalTitle,
                isAllDay: true
            )
        }

        // 2. Mẫu khung giờ có khoảng: ví dụ 08:00 - 10:00, 8h-10h, 8h30 - 10h15, 6h đến 7h, 6g - 7g
        let rangePattern = #"(\d{1,2})[hH:gG]?(\d{2})?\s*[-–—đếnto~]+\s*(\d{1,2})[hH:gG]?(\d{2})?"#
        if let regex = try? NSRegularExpression(pattern: rangePattern, options: []) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsText.length)) {
                var sH = 8
                var sM = 0
                var eH = 10
                var eM = 0

                if match.range(at: 1).location != NSNotFound {
                    sH = Int(nsText.substring(with: match.range(at: 1))) ?? 8
                }
                if match.range(at: 2).location != NSNotFound {
                    sM = Int(nsText.substring(with: match.range(at: 2))) ?? 0
                }
                if match.range(at: 3).location != NSNotFound {
                    eH = Int(nsText.substring(with: match.range(at: 3))) ?? (sH + 1)
                }
                if match.range(at: 4).location != NSNotFound {
                    eM = Int(nsText.substring(with: match.range(at: 4))) ?? 0
                }

                // Điều chỉnh buổi tối / chiều nếu có từ khóa
                sH = adjustForPeriod(sH, in: lower)
                eH = adjustForPeriod(eH, in: lower)

                if eH < sH || (eH == sH && eM <= sM) {
                    eH = min(23, sH + 1)
                }

                // Cắt bỏ phần khung giờ khỏi tiêu đề
                let titlePart = nsText.replacingCharacters(in: match.range, with: "")
                let finalTitle = cleanTitle(stripDayAndPeriodWords(from: titlePart))
                guard !finalTitle.isEmpty else { return nil }

                return ExtractedDetails(sH: sH, sM: sM, eH: eH, eM: eM, title: finalTitle, isAllDay: false)
            }
        }

        // 3. Mẫu một mốc giờ duy nhất: ví dụ "19h", "lúc 7h", "19:30", "8h sáng"
        let singlePattern = #"(?:lúc\s+|vào\s+)?(\b\d{1,2})[hH:gG](\d{2})?|\b(\d{1,2}):(\d{2})\b"#
        if let regex = try? NSRegularExpression(pattern: singlePattern, options: [.caseInsensitive]) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsText.length)) {
                var sH = 8
                var sM = 0

                if match.range(at: 1).location != NSNotFound {
                    sH = Int(nsText.substring(with: match.range(at: 1))) ?? 8
                } else if match.range(at: 3).location != NSNotFound {
                    sH = Int(nsText.substring(with: match.range(at: 3))) ?? 8
                }

                if match.range(at: 2).location != NSNotFound {
                    sM = Int(nsText.substring(with: match.range(at: 2))) ?? 0
                } else if match.range(at: 4).location != NSNotFound {
                    sM = Int(nsText.substring(with: match.range(at: 4))) ?? 0
                }

                sH = adjustForPeriod(sH, in: lower)
                let eH = min(23, sH + 1)

                let titlePart = nsText.replacingCharacters(in: match.range, with: "")
                let finalTitle = cleanTitle(stripDayAndPeriodWords(from: titlePart))
                guard !finalTitle.isEmpty else { return nil }

                return ExtractedDetails(sH: sH, sM: sM, eH: eH, eM: sM, title: finalTitle, isAllDay: false)
            }
        }

        // 4. Mẫu buổi tự nhiên không kèm giờ: "sáng", "chiều", "tối"
        if lower.contains("sáng") || lower.contains("sang") {
            let finalTitle = cleanTitle(stripDayAndPeriodWords(from: text))
            guard !finalTitle.isEmpty else { return nil }
            return ExtractedDetails(sH: 8, sM: 0, eH: 10, eM: 0, title: finalTitle, isAllDay: false)
        }
        if lower.contains("chiều") || lower.contains("chieu") {
            let finalTitle = cleanTitle(stripDayAndPeriodWords(from: text))
            guard !finalTitle.isEmpty else { return nil }
            return ExtractedDetails(sH: 14, sM: 0, eH: 16, eM: 0, title: finalTitle, isAllDay: false)
        }
        if lower.contains("tối") || lower.contains("toi") {
            let finalTitle = cleanTitle(stripDayAndPeriodWords(from: text))
            guard !finalTitle.isEmpty else { return nil }
            return ExtractedDetails(sH: 19, sM: 0, eH: 21, eM: 0, title: finalTitle, isAllDay: false)
        }

        return nil
    }

    /// Tự động chuyển đổi giờ chiều/tối (ví dụ "7h tối" -> 19h, "2h chiều" -> 14h)
    private static func adjustForPeriod(_ hour: Int, in text: String) -> Int {
        if hour < 12 {
            if text.contains("tối") || text.contains("toi") {
                if hour >= 6 && hour <= 11 { return hour + 12 }
            }
            if text.contains("chiều") || text.contains("chieu") {
                if hour >= 1 && hour <= 6 { return hour + 12 }
            }
        }
        return min(23, max(0, hour))
    }

    /// Loại bỏ các từ chỉ thứ và buổi khỏi tiêu đề sự kiện
    private static func stripDayAndPeriodWords(from text: String) -> String {
        var s = text
        let removePatterns = [
            #"(?i)\b(thứ\s+[2-7]|thứ\s+hai|thứ\s+ba|thứ\s+tư|thứ\s+năm|thứ\s+sáu|thứ\s+bảy|chủ\s+nhật)\b"#,
            #"(?i)\b(thu\s+[2-7]|t[2-7]|cn)\b"#,
            #"(?i)\b(2-4-6|3-5-7|2,4,6|3,5,7|2, 4, 6|3, 5, 7)\b"#,
            #"(?i)\b(sáng|chiều|tối|buổi\s+sáng|buổi\s+chiều|buổi\s+tối|lúc|vào|hằng\s+ngày|hàng\s+ngày)\b"#,
            #"(?i)\b(tuần\s+này|tuan\s+nay)\b"#
        ]

        for pat in removePatterns {
            s = s.replacingOccurrences(of: pat, with: "", options: .regularExpression)
        }

        return s
    }

    /// Làm sạch tiêu đề: bỏ dấu gạch đầu dòng, dấu hai chấm...
    private static func cleanTitle(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let removeChars: CharacterSet = [":", "-", "–", "—", "*", "•", ";", ",", " "]
        s = s.trimmingCharacters(in: removeChars)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
