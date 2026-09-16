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

    @State private var config = WallpaperConfig()
    @State private var showMockOverlay = true
    @State private var selectedTab: StudioTab = .background
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var customLoadedImage: UIImage? = nil
    @State private var showSuccessTutorial = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Nền đen xám sang trọng cho Studio
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // MARK: - Thanh Trên Cùng: Tiêu Đề & Nút Mắt Xem Trước
                    headerBar

                    // MARK: - Khung Canvas iPhone 15 Ở Giữa
                    phonePreviewCanvas
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // MARK: - Bảng Điều Khiển Nổi Phía Dưới
                    controlPanel
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        customLoadedImage = uiImage
                        config.preset = .custom
                    }
                }
            }
            .sheet(isPresented: $showSuccessTutorial) {
                successTutorialSheet
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
                    .foregroundStyle(config.accentColor.color)

                Text("Studio Lịch Khóa")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Nút Bật/Tắt Lớp Mô Phỏng Màn Hình Khóa
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showMockOverlay.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: showMockOverlay ? "eye.fill" : "eye.slash.fill")
                    Text(showMockOverlay ? "Mô phỏng: BẬT" : "Mô phỏng: TẮT")
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(showMockOverlay ? config.accentColor.color.opacity(0.25) : Color.white.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(showMockOverlay ? config.accentColor.color.opacity(0.6) : Color.clear, lineWidth: 1)
                )
                .foregroundStyle(showMockOverlay ? config.accentColor.color : .white.opacity(0.7))
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
                    customImage: customLoadedImage,
                    showMockOverlay: showMockOverlay
                )
                .frame(width: 393, height: 852)
                .scaleEffect(scaleRatio)
                .frame(width: targetWidth, height: targetHeight)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                )
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
                                .fill(selectedTab == tab ? config.accentColor.color : Color.white.opacity(0.08))
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
            .frame(height: 90)
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
                        colors: [config.accentColor.color, config.accentColor.color.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: config.accentColor.color.opacity(0.4), radius: 10, y: 4)
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
                                .fill(config.preset == .custom ? config.accentColor.color : Color.white.opacity(0.12))
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
                                        .stroke(config.preset == preset ? config.accentColor.color : Color.white.opacity(0.2), lineWidth: config.preset == preset ? 2.5 : 1)
                                )
                                .shadow(color: config.preset == preset ? config.accentColor.color.opacity(0.5) : Color.clear, radius: 5)

                            Text(preset.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(config.preset == preset ? config.accentColor.color : .white.opacity(0.8))
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
                            .foregroundStyle(config.layoutType == layout ? Color.black : config.accentColor.color)

                        Text(layout.title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(config.layoutType == layout ? Color.black : Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(config.layoutType == layout ? config.accentColor.color : Color.white.opacity(0.08))
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
                                    .fill(config.position == pos ? config.accentColor.color : Color.white.opacity(0.08))
                            )
                    }
                }
            }

            // Thanh trượt tinh chỉnh Y
            HStack {
                Text("Căn chỉnh:")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                Slider(value: $config.fineTuneYOffset, in: -40...40, step: 2)
                    .tint(config.accentColor.color)
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Tab Màu Sắc (Color)
    private var colorSection: some View {
        HStack(spacing: 14) {
            ForEach(AccentColorTheme.allCases) { theme in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        config.accentColor = theme
                    }
                } label: {
                    VStack(spacing: 5) {
                        Circle()
                            .fill(theme.color)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: config.accentColor == theme ? 3 : 0)
                            )
                            .shadow(color: theme.color.opacity(0.5), radius: 6)

                        Text(theme.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(config.accentColor == theme ? theme.color : .white.opacity(0.7))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hướng Dẫn Cài Đặt Khi Lưu Thành Công
    private var successTutorialSheet: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(config.accentColor.color)
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
                    .background(config.accentColor.color)
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
                .background(Circle().fill(config.accentColor.color))

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
