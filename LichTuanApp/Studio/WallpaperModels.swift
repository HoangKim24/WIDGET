import SwiftUI

// MARK: - Preset Hình Nền Trẻ Trung & Sang Chảnh
enum WallpaperPreset: String, CaseIterable, Identifiable, Codable {
    case sunset = "sunset"
    case aurora = "aurora"
    case obsidian = "obsidian"
    case oled = "oled"
    case cyberpunk = "cyberpunk"
    case nordic = "nordic"
    case matcha = "matcha"
    case candy = "candy"
    case custom = "custom"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunset: return "Hoàng Hôn Chill"
        case .aurora: return "Cực Quang"
        case .obsidian: return "Đen Obsidian"
        case .oled: return "Đen OLED 100%"
        case .cyberpunk: return "Cyberpunk Neon"
        case .nordic: return "Pastel Bắc Âu"
        case .matcha: return "Matcha Dịu Êm"
        case .candy: return "Kẹo Ngọt Pastel"
        case .custom: return "Ảnh Của Bạn"
        }
    }

    var iconName: String {
        switch self {
        case .sunset: return "sun.horizon.fill"
        case .aurora: return "sparkles"
        case .obsidian: return "moon.stars.fill"
        case .oled: return "moon.fill"
        case .cyberpunk: return "bolt.shield.fill"
        case .nordic: return "cloud.fog.fill"
        case .matcha: return "leaf.fill"
        case .candy: return "heart.fill"
        case .custom: return "photo.badge.plus"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .sunset:
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.08, blue: 0.25),
                    Color(red: 0.85, green: 0.35, blue: 0.35),
                    Color(red: 0.95, green: 0.65, blue: 0.40)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aurora:
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.22),
                    Color(red: 0.18, green: 0.42, blue: 0.58),
                    Color(red: 0.45, green: 0.25, blue: 0.70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .obsidian:
            return LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.03, blue: 0.04),
                    Color(red: 0.10, green: 0.11, blue: 0.14),
                    Color(red: 0.05, green: 0.05, blue: 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .oled:
            return LinearGradient(
                colors: [Color.black, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cyberpunk:
            return LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.0, blue: 0.16),
                    Color(red: 0.22, green: 0.04, blue: 0.38),
                    Color(red: 0.05, green: 0.42, blue: 0.58)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nordic:
            return LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22),
                    Color(red: 0.26, green: 0.30, blue: 0.35),
                    Color(red: 0.44, green: 0.49, blue: 0.52)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .matcha:
            return LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.28, blue: 0.22),
                    Color(red: 0.42, green: 0.55, blue: 0.45),
                    Color(red: 0.82, green: 0.88, blue: 0.80)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .candy:
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.70, blue: 0.85),
                    Color(red: 0.75, green: 0.80, blue: 0.98),
                    Color(red: 0.98, green: 0.88, blue: 0.80)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .custom:
            return LinearGradient(
                colors: [Color.black, Color.gray],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Bố Cục Lịch Tuần 7 Ngày
enum CalendarLayoutType: String, CaseIterable, Identifiable, Codable {
    case rows = "rows"
    case columns = "columns"
    case frostedCard = "frosted"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rows: return "7 Dòng Chi Tiết"
        case .columns: return "7 Cột Tối Giản"
        case .frostedCard: return "Kính Mờ"
        }
    }

    var iconName: String {
        switch self {
        case .rows: return "list.bullet.rectangle"
        case .columns: return "rectangle.split.3x1"
        case .frostedCard: return "square.stack.3d.up.fill"
        }
    }
}

// MARK: - Vị Trí Lịch Trên Màn Hình Khóa
enum CalendarPosition: String, CaseIterable, Identifiable, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: return "Dưới Đồng Hồ"
        case .center: return "Chính Giữa"
        case .bottom: return "Dưới Đáy"
        }
    }

    var yRatio: CGFloat {
        switch self {
        case .top: return 0.28
        case .center: return 0.42
        case .bottom: return 0.56
        }
    }
}

// MARK: - Màu Sắc Điểm Nhấn
enum AccentColorTheme: String, CaseIterable, Identifiable, Codable {
    case gold = "gold"
    case rose = "rose"
    case cyan = "cyan"
    case mint = "mint"
    case white = "white"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gold: return "Vàng Gold"
        case .rose: return "Hồng Neon"
        case .cyan: return "Xanh Băng"
        case .mint: return "Xanh Mint"
        case .white: return "Trắng Tinh"
        }
    }

    var color: Color {
        switch self {
        case .gold: return Color(red: 1.0, green: 0.82, blue: 0.35)
        case .rose: return Color(red: 1.0, green: 0.45, blue: 0.65)
        case .cyan: return Color(red: 0.35, green: 0.85, blue: 1.0)
        case .mint: return Color(red: 0.45, green: 0.95, blue: 0.75)
        case .white: return Color.white
        }
    }
}

// MARK: - Phong Cách Phông Chữ Lịch Nghệ Thuật
enum CalendarFontTheme: String, CaseIterable, Identifiable, Codable {
    case rounded = "rounded"
    case modern = "modern"
    case serif = "serif"
    case monospaced = "monospaced"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rounded: return "Bo Tròn"
        case .modern: return "Hiện Đại"
        case .serif: return "Cổ Điển"
        case .monospaced: return "Coder"
        }
    }

    var iconName: String {
        switch self {
        case .rounded: return "capsule"
        case .modern: return "textformat"
        case .serif: return "textformat.alt"
        case .monospaced: return "chevron.left.forwardslash.chevron.right"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .modern:
            return .system(size: size, weight: weight, design: .default)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }
}

// MARK: - Cấu Hình Toàn Bộ Hình Nền
struct WallpaperConfig: Equatable, Codable {
    var preset: WallpaperPreset = .sunset
    var layoutType: CalendarLayoutType = .rows
    var position: CalendarPosition = .top
    var accentColor: AccentColorTheme = .gold
    var customHexColor: String? = nil
    var isMonochromeTheme: Bool = false
    var dimOpacity: Double = 0.25
    var blurRadius: Double = 0.0
    var showEventDots: Bool = true
    var fineTuneYOffset: CGFloat = 0.0
    var fontTheme: CalendarFontTheme = .rounded
    var cardOpacity: Double = 0.85

    init(
        preset: WallpaperPreset = .sunset,
        layoutType: CalendarLayoutType = .rows,
        position: CalendarPosition = .top,
        accentColor: AccentColorTheme = .gold,
        customHexColor: String? = nil,
        isMonochromeTheme: Bool = false,
        dimOpacity: Double = 0.25,
        blurRadius: Double = 0.0,
        showEventDots: Bool = true,
        fineTuneYOffset: CGFloat = 0.0,
        fontTheme: CalendarFontTheme = .rounded,
        cardOpacity: Double = 0.85
    ) {
        self.preset = preset
        self.layoutType = layoutType
        self.position = position
        self.accentColor = accentColor
        self.customHexColor = customHexColor
        self.isMonochromeTheme = isMonochromeTheme
        self.dimOpacity = dimOpacity
        self.blurRadius = blurRadius
        self.showEventDots = showEventDots
        self.fineTuneYOffset = fineTuneYOffset
        self.fontTheme = fontTheme
        self.cardOpacity = cardOpacity
    }

    private enum CodingKeys: String, CodingKey {
        case preset, layoutType, position, accentColor, customHexColor, isMonochromeTheme, dimOpacity, blurRadius, showEventDots, fineTuneYOffset, fontTheme, cardOpacity
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        preset = try c.decodeIfPresent(WallpaperPreset.self, forKey: .preset) ?? .sunset
        layoutType = try c.decodeIfPresent(CalendarLayoutType.self, forKey: .layoutType) ?? .rows
        position = try c.decodeIfPresent(CalendarPosition.self, forKey: .position) ?? .top
        accentColor = try c.decodeIfPresent(AccentColorTheme.self, forKey: .accentColor) ?? .gold
        customHexColor = try c.decodeIfPresent(String.self, forKey: .customHexColor)
        isMonochromeTheme = try c.decodeIfPresent(Bool.self, forKey: .isMonochromeTheme) ?? false
        dimOpacity = try c.decodeIfPresent(Double.self, forKey: .dimOpacity) ?? 0.25
        blurRadius = try c.decodeIfPresent(Double.self, forKey: .blurRadius) ?? 0.0
        showEventDots = try c.decodeIfPresent(Bool.self, forKey: .showEventDots) ?? true
        fineTuneYOffset = try c.decodeIfPresent(CGFloat.self, forKey: .fineTuneYOffset) ?? 0.0
        fontTheme = try c.decodeIfPresent(CalendarFontTheme.self, forKey: .fontTheme) ?? .rounded
        cardOpacity = try c.decodeIfPresent(Double.self, forKey: .cardOpacity) ?? 0.85
    }

    var effectiveAccentColor: Color {
        if let hex = customHexColor, let c = Color(hex: hex) {
            return c
        }
        return accentColor.color
    }

    private static let userDefaultsKey = "savedWallpaperConfig"
    private static var customImageURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("custom_wallpaper_background.jpg")
    }

    static func saveCustomImage(_ image: UIImage) {
        guard let url = customImageURL,
              let data = image.jpegData(compressionQuality: 0.88) else { return }
        try? data.write(to: url)
    }

    static func loadCustomImage() -> UIImage? {
        guard let url = customImageURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func load() -> WallpaperConfig {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(WallpaperConfig.self, from: data) else {
            return WallpaperConfig()
        }
        return decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: WallpaperConfig.userDefaultsKey)
        }
    }
}

