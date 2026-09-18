import SwiftUI

extension Color {
    /// Tạo màu SwiftUI chuẩn xác từ chuỗi hex (hỗ trợ Color Hunt: #RRGGBB, RRGGBB, #RRGGBBAA, #RGB)
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: Double

        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else if length == 3 {
            let rInt = (rgb & 0xF00) >> 8
            let gInt = (rgb & 0x0F0) >> 4
            let bInt = rgb & 0x00F
            r = Double(rInt * 17) / 255.0
            g = Double(gInt * 17) / 255.0
            b = Double(bInt * 17) / 255.0
            a = 1.0
        } else {
            return nil
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

