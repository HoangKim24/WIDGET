import SwiftUI
import PhotosUI

enum StudioTab: String, CaseIterable, Identifiable {
    case background = "Nền"
    case layout = "Kiểu Lịch"
    case position = "Vị Trí"
    case color = "Màu Sắc"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .background: return "paintpalette.fill"
        case .layout: return "calendar"
        case .position: return "arrow.up.and.down.and.sparkles"
        case .color: return "circle.hexagongrid.fill"
        }
    }
}

/// Màn hình Studio chính - Nơi người dùng thiết kế và xuất hình nền lịch màn hình khóa.
struct LockScreenStudioView: View {
    @ObservedObject var viewModel: EventListViewModel
    @StateObject private var saveManager = WallpaperSaveManager()

    @State private var config = WallpaperConfig.load()
    @State private var showAutoGuide = false
    @State private var selectedTab: StudioTab = .background
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var customLoadedImage: UIImage? = nil
    @State private var showSuccessTutorial = false
    @State private var hexInputText: String = ""

    // Bảng màu thịnh hành từ Color Hunt (Color Hunt Popular Palettes)
    private let colorHuntPresets: [(title: String, hex: String)] = [
        ("Cam Đất", "#E76F51"),
        ("Xanh Ngọc", "#2A9D8F"),
        ("Hoàng Hôn", "#E9C46A"),
        ("Tím Pastel", "#B388FF"),
        ("Bạc Hà", "#06D6A0")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // MARK: - Thanh Trên Cùng: Tiêu Đề & Nút Tự Động Hóa
                headerBar

                // MARK: - Khung Canvas iPhone 15 Ở Giữa
                phonePreviewCanvas
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Bảng Điều Khiển Nổi Phía Dưới
                controlPanel
            }
            .padding(.top, 6)
            .padding(.bottom, 8)
            .background(Color(red: 0.08, green: 0.08, blue: 0.10).ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if let hex = config.customHexColor {
                    hexInputText = hex
                }
            }
            .onChange(of: config) { newConfig in
                newConfig.save()
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        customLoadedImage = uiImage
                        config.preset = .custom
                        config.save()
                    }
                }
            }
            .sheet(isPresented: $showSuccessTutorial) {
                successTutorialSheet
            }
            .sheet(isPresented: $showAutoGuide) {
                AutoWallpaperSetupGuideView()
            }
            .onChange(of: saveManager.saveSuccess) { success in
                if success {
                    showSuccessTutorial = true
                }
            }
            .alert("Thông Báo", isPresented: Binding(
                get: { saveManager.errorMessage != nil },
                set: { if !$0 { saveManager.errorMessage = nil } }
            )) {
                Button("Đã hiểu", role: .cancel) {}
            } message: {
                Text(saveManager.errorMessage ?? "")
            }
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(config.effectiveAccentColor)

                Text("Studio Lịch Khóa")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Nút Tự Động Hóa Màn Hình Khóa (Shortcuts)
            Button {
                showAutoGuide = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.badge.automatic.fill")
                    Text("Tự Động Hóa")
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.18, green: 0.58, blue: 1.0).opacity(0.22))
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.18, green: 0.58, blue: 1.0).opacity(0.6), lineWidth: 1)
                )
                .foregroundStyle(Color(red: 0.28, green: 0.70, blue: 1.0))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Phone Preview Canvas
    private var phonePreviewCanvas: some View {
        GeometryReader { proxy in
            // Tỷ lệ màn hình iPhone 15: 393 / 852 ~= 0.461
            let availableHeight = proxy.size.height
            let targetHeight = min(availableHeight, 460)
            let targetWidth = targetHeight * (393.0 / 852.0)
            let scaleRatio = targetHeight / 852.0

            ZStack {
                // Viền giả lập điện thoại iPhone 15
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(Color.black)
                    .frame(width: targetWidth + 8, height: targetHeight + 8)
                    .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 12)

                WallpaperCanvasView(
                    config: config,
                    events: viewModel.events,
                    customImage: customLoadedImage
                )
                .frame(width: 393, height: 852)
                .scaleEffect(scaleRatio)
                .frame(width: targetWidth, height: targetHeight)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                )

                // Giả lập màn hình khóa iOS (Đồng hồ, Ngày tháng, Dynamic Island) giúp căn chỉnh chính xác 100%
                mockLockScreenOverlay
                    .frame(width: 393, height: 852)
                    .scaleEffect(scaleRatio)
                    .frame(width: targetWidth, height: targetHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // MARK: - Bảng Điều Khiển Nổi (Control Panel)
    private var controlPanel: some View {
        VStack(spacing: 10) {
            // Thanh Tab Chọn Mục Tùy Biến
            HStack(spacing: 6) {
                ForEach(StudioTab.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                            Text(tab.rawValue)
                        }
                        .font(.system(size: 12, weight: selectedTab == tab ? .bold : .medium))
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? config.effectiveAccentColor : Color.white.opacity(0.08))
                        )
                        .foregroundStyle(selectedTab == tab ? Color.black : Color.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 14)

            // Vùng Nội Dung Tab
            VStack {
                switch selectedTab {
                case .background:
                    backgroundSection
                case .layout:
                    layoutSection
                case .position:
                    positionSection
                case .color:
                    colorSection
                }
            }
            .frame(minHeight: 90, maxHeight: 110)
            .padding(.horizontal, 14)

            // Nút Lưu Hình Nền To Bản
            Button {
                saveManager.saveWallpaper(
                    config: config,
                    events: viewModel.events,
                    customImage: customLoadedImage
                )
            } label: {
                HStack(spacing: 8) {
                    if saveManager.isSaving {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: "arrow.down.to.line.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                    }

                    Text(saveManager.isSaving ? "Đang xuất ảnh siêu nét..." : "Lưu Hình Nền Màn Hình Khóa")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [config.effectiveAccentColor, config.effectiveAccentColor.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: config.effectiveAccentColor.opacity(0.4), radius: 10, y: 4)
            }
            .disabled(saveManager.isSaving)
            .padding(.horizontal, 14)
            .padding(.top, 2)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
    }

    // MARK: - Tab Nền (Backgrounds)
    private var backgroundSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Nút Chọn Ảnh Cá Nhân
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(config.preset == .custom ? config.effectiveAccentColor : Color.white.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 17))
                                .foregroundStyle(config.preset == .custom ? Color.black : Color.white)
                        }
                        Text("Ảnh Của Bạn")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                // Các Preset Có Sẵn
                ForEach(WallpaperPreset.allCases.filter { $0 != .custom }) { preset in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            config.preset = preset
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(preset.gradient)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(config.preset == preset ? config.effectiveAccentColor : Color.white.opacity(0.2), lineWidth: config.preset == preset ? 2.5 : 1)
                                 )
                                .shadow(color: config.preset == preset ? config.effectiveAccentColor.opacity(0.5) : Color.clear, radius: 5)

                            Text(preset.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(config.preset == preset ? config.effectiveAccentColor : .white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Tab Kiểu Lịch (Layout)
    private var layoutSection: some View {
        HStack(spacing: 10) {
            ForEach(CalendarLayoutType.allCases) { layout in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        config.layoutType = layout
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: layout.iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(config.layoutType == layout ? Color.black : config.effectiveAccentColor)

                        Text(layout.title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(config.layoutType == layout ? Color.black : Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(config.layoutType == layout ? config.effectiveAccentColor : Color.white.opacity(0.08))
                    )
                }
            }
        }
    }

    // MARK: - Tab Vị Trí (Position)
    private var positionSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ForEach(CalendarPosition.allCases) { pos in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            config.position = pos
                            config.fineTuneYOffset = 0
                        }
                    } label: {
                        Text(pos.title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(config.position == pos ? Color.black : Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(config.position == pos ? config.effectiveAccentColor : Color.white.opacity(0.08))
                            )
                    }
                }
            }

            // Thanh trượt tinh chỉnh Y (hạ thấp hoặc nâng cao)
            HStack {
                Text("Căn chỉnh:")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                Slider(value: $config.fineTuneYOffset, in: -40...100, step: 2)
                    .tint(config.effectiveAccentColor)
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Tab Màu Sắc (Color Hunt & Tone-sur-tone)
    private var colorSection: some View {
        VStack(spacing: 8) {
            // Hàng 1: Màu có sẵn + Màu Color Hunt thịnh hành
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Màu cơ bản
                    ForEach(AccentColorTheme.allCases) { theme in
                        let isSelected = config.customHexColor == nil && config.accentColor == theme
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                config.customHexColor = nil
                                config.accentColor = theme
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: isSelected ? 2.5 : 0)
                                    )
                                    .shadow(color: theme.color.opacity(0.4), radius: 4)

                                Text(theme.title)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(isSelected ? theme.color : .white.opacity(0.7))
                            }
                        }
                    }

                    // Màu Color Hunt đề xuất
                    ForEach(colorHuntPresets, id: \.hex) { preset in
                        let isSelected = config.customHexColor?.uppercased() == preset.hex.uppercased()
                        let presetColor = Color(hex: preset.hex) ?? .white
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                config.customHexColor = preset.hex
                                hexInputText = preset.hex
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(presetColor)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: isSelected ? 2.5 : 0)
                                    )
                                    .shadow(color: presetColor.opacity(0.4), radius: 4)

                                Text(preset.title)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(isSelected ? presetColor : .white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            // Hàng 2: Nhập mã HEX bất kỳ từ Color Hunt & Toggle Đồng bộ màu
            HStack(spacing: 8) {
                // Ô nhập mã HEX
                HStack(spacing: 6) {
                    Image(systemName: "number")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(config.effectiveAccentColor)

                    TextField("Mã HEX (vd: #E76F51)", text: $hexInputText)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: hexInputText) { newHex in
                            let clean = newHex.trimmingCharacters(in: .whitespacesAndNewlines)
                            if clean.count >= 4, Color(hex: clean) != nil {
                                config.customHexColor = clean
                            }
                        }

                    Button {
                        if let clip = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !clip.isEmpty {
                            hexInputText = clip
                            if Color(hex: clip) != nil {
                                config.customHexColor = clip
                            }
                        }
                    } label: {
                        Text("Dán")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(config.effectiveAccentColor.opacity(0.25))
                            .foregroundStyle(config.effectiveAccentColor)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Nút gạt Tone-sur-tone (Đồng bộ màu toàn bộ sự kiện)
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        config.isMonochromeTheme.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: config.isMonochromeTheme ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 10))
                        Text("Đồng bộ màu")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(config.isMonochromeTheme ? config.effectiveAccentColor.opacity(0.2) : Color.white.opacity(0.06))
                    .foregroundStyle(config.isMonochromeTheme ? config.effectiveAccentColor : Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    // MARK: - Hướng Dẫn Cài Đặt Khi Lưu Thành Công
    private var successTutorialSheet: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(config.effectiveAccentColor)
                .padding(.top, 24)

            Text("Đã Lưu Hình Nền Vào Ảnh!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Hình nền lịch đã sẵn sàng trong Thư viện ảnh của bạn. Để cài lên màn hình khóa:")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 14) {
                stepRow(number: "1", text: "Mở ứng dụng Ảnh (Photos) trên iPhone.")
                stepRow(number: "2", text: "Chọn ảnh hình nền vừa lưu, nhấn biểu tượng Chia sẻ (mũi tên lên).")
                stepRow(number: "3", text: "Chọn 'Dùng làm hình nền' (Use as Wallpaper) và nhấn 'Đặt làm cặp hình nền'.")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.08))
            )
            .padding(.horizontal, 20)

            Spacer()

            Button {
                showSuccessTutorial = false
            } label: {
                Text("Tuyệt Vời, Tôi Đã Hiểu!")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(config.effectiveAccentColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.visible)
        .background(Color(red: 0.12, green: 0.12, blue: 0.16).ignoresSafeArea())
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 22, height: 22)
                .background(Circle().fill(config.effectiveAccentColor))

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Giả Lập Màn Hình Khóa iOS (Đồng Hồ, Dynamic Island, Đèn Pin/Camera)
    private var mockLockScreenOverlay: some View {
        VStack(spacing: 0) {
            // Dynamic Island
            Capsule()
                .fill(Color.black)
                .frame(width: 108, height: 30)
                .padding(.top, 14)

            // Dòng Thứ, Ngày tháng chuẩn iOS
            Text(vietnameseLockScreenDate(Date()))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .shadow(color: .black.opacity(0.4), radius: 4)
                .padding(.top, 14)

            // Đồng hồ to bản chuẩn iOS
            Text(mockClockTime)
                .font(.system(size: 78, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.45), radius: 8)
                .padding(.top, -8)

            Spacer()

            // Các nút đáy màn hình khóa (Đèn pin & Camera)
            HStack {
                Circle()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "flashlight.on.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    )

                Spacer()

                Circle()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    )
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 24)

            // Thanh gạt Home Indicator
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width: 138, height: 4.5)
                .padding(.bottom, 8)
        }
    }

    private var mockClockTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func vietnameseLockScreenDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d 'thg' M"
        return formatter.string(from: date).capitalized
    }
}
