import AppIntents
import SwiftUI

/// AppIntent cho phép ứng dụng Phím Tắt (Shortcuts) của iOS gọi chạy ngầm
/// để tạo hình nền lịch tuần mới nhất và tự động gán lên Màn hình khóa.
struct UpdateCalendarWallpaperIntent: AppIntent {
    static var title: LocalizedStringResource = "Cập Nhật Hình Nền Lịch Tuần"
    static var description = IntentDescription("Tự động vẽ hình nền bảng lịch tuần mới nhất và trả về ảnh để đặt làm màn hình khóa.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        let config = WallpaperConfig.load()
        let events = SharedDataStore.shared.loadEvents()
        let customImage = WallpaperConfig.loadCustomImage()

        // Tự động nhận diện chuẩn xác tỉ lệ và độ phân giải của dòng iPhone hiện tại
        let targetSize = UIScreen.main.bounds.size
        let targetScale = UIScreen.main.scale > 0 ? UIScreen.main.scale : 3.0

        let renderView = WallpaperCanvasView(
            config: config,
            events: events,
            customImage: customImage
        )
        .frame(width: targetSize.width, height: targetSize.height)

        let renderer = ImageRenderer(content: renderView)
        renderer.scale = targetScale

        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData() else {
            throw IntentError.renderFailed
        }

        let file = IntentFile(
            data: pngData,
            filename: "LichTuan_LockScreen.png",
            type: .png
        )

        return .result(value: file)
    }

    enum IntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
        case renderFailed

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .renderFailed:
                return "Không thể kết xuất hình nền lịch. Vui lòng thử lại!"
            }
        }
    }
}

/// Tự động đăng ký Phím Tắt mặc định vào ứng dụng Shortcuts của iOS
struct CalendarAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: UpdateCalendarWallpaperIntent(),
            phrases: [
                "Cập nhật hình nền lịch với \(.applicationName)",
                "Đặt hình nền lịch tuần \(.applicationName)"
            ],
            shortTitle: "Cập nhật hình nền lịch",
            systemImageName: "calendar"
        )
    }
}
