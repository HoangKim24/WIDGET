import SwiftUI

/// Màn hình gốc điều hướng của ứng dụng.
struct ContentView: View {
    @StateObject private var viewModel = EventListViewModel()

    var body: some View {
        RootTabView(viewModel: viewModel)
    }
}

/// Tab điều hướng chính với 2 phân hệ rõ ràng:
/// 1. Bảng Lịch Tuần: Xếp lịch trình 7 ngày (Thứ 2 đến Chủ Nhật) theo các ô giờ cụ thể.
/// 2. Màn Hình Khóa: Studio xuất hình nền lịch cho màn hình khóa iPhone.
struct RootTabView: View {
    @ObservedObject var viewModel: EventListViewModel
    @State private var selectedTab = 0

    private let primaryAccent = Color(red: 0.18, green: 0.58, blue: 1.0)

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: BẢNG LỊCH TUẦN (Màn hình chính)
            WeeklyGridScheduleView(viewModel: viewModel) {
                withAnimation(.spring(response: 0.35)) {
                    selectedTab = 1
                }
            }
            .tabItem {
                Label("Bảng Lịch Tuần", systemImage: "calendar")
            }
            .tag(0)

            // MARK: - Tab 2: STUDIO MÀN HÌNH KHÓA (Xuất hình nền)
            LockScreenStudioView(viewModel: viewModel)
                .tabItem {
                    Label("Màn Hình Khóa", systemImage: "sparkles")
                }
                .tag(1)
        }
        .tint(primaryAccent)
    }
}
