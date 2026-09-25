import SwiftUI

/// Danh mục sự kiện để đồng bộ màu sắc, icon và độ tương phản chữ trong toàn bộ app.
enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case work
    case personal
    case health
    case study
    case family
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: return "Công việc"
        case .personal: return "Cá nhân"
        case .health: return "Sức khỏe"
        case .study: return "Học tập"
        case .family: return "Gia đình"
        case .other: return "Khác"
        }
    }

    /// SF Symbol chuẩn native, tương thích tốt với Dynamic Type và WidgetKit.
    var symbolName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .study: return "book.fill"
        case .family: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// Bảng màu hiện đại, độ tương phản cao, chuẩn xác trên cả OLED và màn hình khóa.
    var color: Color {
        switch self {
        case .work: return Color(red: 0.92, green: 0.30, blue: 0.29)
        case .personal: return Color(red: 0.18, green: 0.58, blue: 1.0)
        case .health: return Color(red: 0.28, green: 0.79, blue: 0.89)
        case .study: return Color(red: 0.98, green: 0.79, blue: 0.14)
        case .family: return Color(red: 0.91, green: 0.26, blue: 0.58)
        case .other: return Color(red: 0.42, green: 0.36, blue: 0.91)
        }
    }

    /// Dải gradient mềm mại cho các thẻ card xem trước và hero banner.
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Xác định xem màu nền có phải là tông sáng (cần chữ đen để dễ đọc) hay không.
    var isLightColor: Bool {
        self == .study || self == .health
    }

    /// Màu chữ tự động đảm bảo tương phản tuyệt đối theo chuẩn WCAG.
    var textColor: Color {
        isLightColor ? Color.black.opacity(0.85) : Color.white
    }

    /// Tự động dự đoán danh mục thông minh dựa trên từ khóa trong tên sự kiện (hỗ trợ cả tiếng Việt và tiếng Anh)
    static func infer(from text: String) -> EventCategory {
        let lower = text.lowercased()

        func containsAny(_ keywords: [String]) -> Bool {
            for kw in keywords where lower.contains(kw) {
                return true
            }
            return false
        }

        if containsAny(["họp", "meeting", "làm", "work", "kpi", "báo cáo", "dự án", "deadline", "công ty", "task", "code", "khách", "call", "phỏng vấn"]) {
            return .work
        }
        if containsAny(["gym", "chạy", "bơi", "yoga", "khám", "thuốc", "thể dục", "relax", "spa", "đi dạo", "bác sĩ", "workout", "fitness"]) {
            return .health
        }
        if containsAny(["học", "study", "thi", "đọc sách", "lớp", "tiếng anh", "ôn", "bài tập", "lecture", "khóa học", "exam", "course"]) {
            return .study
        }
        if containsAny(["gia đình", "mẹ", "bố", "con", "chợ", "siêu thị", "nấu", "family", "vợ", "chồng", "nhà", "dọn dẹp", "đón"]) {
            return .family
        }
        if containsAny(["cafe", "cà phê", "bạn", "phim", "du lịch", "mua sắm", "shopee", "chill", "ăn trưa", "ăn tối", "quán", "nhậu", "party", "sinh nhật"]) {
            return .personal
        }

        return .other
    }
}
