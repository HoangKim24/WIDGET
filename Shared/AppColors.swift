import SwiftUI

/// Bảng màu tập trung của app, dựa trên Color Asset để đổi Light/Dark Mode tự động.
enum AppColors {
    static let primary = Color("AppPrimary")
    static let accent = Color("AppAccent")

    static func color(for category: EventCategory) -> Color {
        Color(category.assetName)
    }

    static func gradient(for category: EventCategory) -> LinearGradient {
        LinearGradient(
            colors: [color(for: category), color(for: category).opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func iconGradient(start: Color, end: Color) -> LinearGradient {
        LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private extension EventCategory {
    var assetName: String {
        switch self {
        case .work: return "CategoryWork"
        case .personal: return "CategoryPersonal"
        case .health: return "CategoryHealth"
        case .study: return "CategoryStudy"
        case .family: return "CategoryFamily"
        case .other: return "CategoryOther"
        }
    }
}
