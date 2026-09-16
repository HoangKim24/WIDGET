import SwiftUI

/// View Canvas chính render toàn bộ hình nền màn hình khóa.
/// Được dùng cả cho chế độ xem trước trực tiếp và xuất ảnh bằng ImageRenderer.
struct WallpaperCanvasView: View {
    let config: WallpaperConfig
    let events: [CalendarEvent]
    var customImage: UIImage? = nil
    var showMockOverlay: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // MARK: - Layer 1: Nền (Gradient hoặc Ảnh cá nhân)
                Group {
                    if config.preset == .custom, let image = customImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: w, height: h)
                            .clipped()
                    } else {
                        config.preset.gradient
                            .frame(width: w, height: h)
                    }
                }
                .blur(radius: CGFloat(config.blurRadius))

                // MARK: - Layer 2: Lớp Phủ Tối (Dim Overlay)
                Color.black.opacity(config.dimOpacity)
                    .frame(width: w, height: h)

                // MARK: - Layer 3: Khung Lịch Tùy Biến
                VStack {
                    Spacer()
                        .frame(height: max(20, h * config.position.yRatio + config.fineTuneYOffset))

                    Group {
                        switch config.layoutType {
                        case .monthly:
                            MonthlyGridCalendarView(
                                events: events,
                                accentColor: config.accentColor.color,
                                isGlassCard: false
                            )
                        case .weekly:
                            WeeklyScheduleView(
                                events: events,
                                accentColor: config.accentColor.color
                            )
                        case .frostedCard:
                            MonthlyGridCalendarView(
                                events: events,
                                accentColor: config.accentColor.color,
                                isGlassCard: true
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .frame(width: w, height: h)

                // MARK: - Layer 4: Lớp Mô Phỏng Màn Hình Khóa (Nếu bật xem trước)
                if showMockOverlay {
                    LockScreenMockOverlay()
                        .frame(width: w, height: h)
                        .transition(.opacity)
                }
            }
            .frame(width: w, height: h)
            .clipped()
        }
    }
}
