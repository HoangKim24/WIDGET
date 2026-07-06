import SwiftUI

/// Danh mục sự kiện để đồng bộ màu và icon trong toàn bộ app.
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
        case .work: return "Work"
        case .personal: return "Personal"
        case .health: return "Health"
        case .study: return "Study"
        case .family: return "Family"
        case .other: return "Other"
        }
    }

    /// SF Symbol nhỏ, native, tương thích tốt với Dark Mode và Dynamic Type.
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

    var color: Color {
        AppColors.color(for: self)
    }
}
