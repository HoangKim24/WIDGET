import SwiftUI

/// View Canvas chính render toàn bộ hình nền màn hình khóa.
/// Được dùng cả cho chế độ xem trước trực tiếp và xuất ảnh bằng ImageRenderer.
struct WallpaperCanvasView: View {
    let config: WallpaperConfig
    let events: [CalendarEvent]
    var customImage: UIImage? = nil

    private func calculateTopPadding(totalHeight h: CGFloat) -> CGFloat {
        // iPhone 15 native height: 852pt
        // Khoảng cách an toàn tránh đè đồng hồ (kể cả khi iOS tự zoom nhẹ hình nền):
        // Vùng an toàn vẽ lịch: ~310pt đến 730pt
        let baseRatio: CGFloat
        switch config.position {
        case .top:
            baseRatio = 0.365 // ~311pt trên 852pt (cách xa đáy đồng hồ 13:19 và widget)
        case .center:
            baseRatio = 0.435 // ~370pt trên 852pt (chính giữa vùng an toàn)
        case .bottom:
            baseRatio = 0.510 // ~435pt trên 852pt (nằm ở nửa dưới màn hình)
        }
        let calculated = h * baseRatio + config.fineTuneYOffset
        let minTop = h * 0.33
        let maxTop = h * 0.65
        return max(minTop, min(calculated, maxTop))
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let topPadding = calculateTopPadding(totalHeight: h)
            // Đáy an toàn tối đa: 735pt / 852pt = ~0.862 (cách nút đèn pin 755pt ít nhất 20pt)
            let maxContentHeight = max(120, h * 0.862 - topPadding)

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
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: topPadding)

                    DailyAgendaAndWeekScheduleView(events: events, config: config)
                        .padding(.horizontal, 24)
                        .frame(maxHeight: maxContentHeight, alignment: .top)

                    Spacer()
                }
                .frame(width: w, height: h)
            }
            .frame(width: w, height: h)
            .clipped()
        }
    }
}
