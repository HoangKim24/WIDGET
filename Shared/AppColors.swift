import SwiftUI

/// Bảng màu chính và điểm nhấn thương hiệu của ứng dụng.
enum AppColors {
    static let primary = Color("AppPrimary")
    static let accent = Color("AppAccent")

    /// Màu đại diện cho từng danh mục sự kiện
    static func color(for category: EventCategory) -> Color {
        category.color
    }

    /// Dải gradient cho từng danh mục sự kiện
    static func gradient(for category: EventCategory) -> LinearGradient {
        category.gradient
    }
}
