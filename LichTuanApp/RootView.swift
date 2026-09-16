import SwiftUI

/// Màn hình gốc điều hướng của ứng dụng.
struct ContentView: View {
    @StateObject private var viewModel = EventListViewModel()

    var body: some View {
        RootTabView(viewModel: viewModel)
    }
}

/// Tab điều hướng chính với 2 phân hệ rõ ràng: Studio Thiết Kế và Quản Lý Sự Kiện.
struct RootTabView: View {
    @ObservedObject var viewModel: EventListViewModel
    @State private var selectedTab = 0

    private let studioAccent = Color(red: 1.0, green: 0.82, blue: 0.35)

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Studio Thiết Kế Hình Nền Lịch
            LockScreenStudioView(viewModel: viewModel)
                .tabItem {
                    Label("Thiết Kế", systemImage: "sparkles")
                }
                .tag(0)

            // MARK: - Tab 2: Quản Lý Sự Kiện & Lịch Biểu
            EventListView(viewModel: viewModel)
                .tabItem {
                    Label("Sự Kiện", systemImage: "calendar.badge.clock")
                }
                .tag(1)
        }
        .tint(studioAccent)
    }
}

/// Màn hình danh sách và quản lý sự kiện của người dùng.
struct EventListView: View {
    @ObservedObject var viewModel: EventListViewModel
    @State private var editorContext: EventEditorContext?
    @State private var filterMode: EventFilterMode = .all

    enum EventFilterMode: String, CaseIterable, Identifiable {
        case all = "Tất Cả"
        case today = "Hôm Nay"
        case upcoming = "Sắp Tới"

        var id: String { rawValue }
    }

    private var filteredEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        switch filterMode {
        case .all:
            return viewModel.events
        case .today:
            return viewModel.events.filter { calendar.isDateInToday($0.startDate) }
        case .upcoming:
            return viewModel.events.filter { $0.startDate >= now }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Thẻ giới thiệu & Thống kê nhanh
                        summaryHeroCard

                        // Bộ lọc danh mục sự kiện
                        filterSegmentControl

                        // Danh sách sự kiện
                        if filteredEvents.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEvents) { event in
                                    EventCardRow(event: event) {
                                        editorContext = .edit(event)
                                    } onDelete: {
                                        withAnimation(.spring(response: 0.3)) {
                                            viewModel.delete(event)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Sự Kiện Của Bạn")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorContext = .add
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Thêm Mới")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.82, blue: 0.35))
                        )
                        .foregroundStyle(Color.black)
                    }
                }
            }
            .sheet(item: $editorContext) { context in
                EventEditorView(event: context.eventToEdit) { savedEvent in
                    switch context {
                    case .add:
                        viewModel.add(savedEvent)
                    case .edit:
                        viewModel.update(savedEvent)
                    }
                }
            }
        }
    }

    // MARK: - Thẻ Hero Thống Kê
    private var summaryHeroCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Đồng Bộ Hình Nền")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.35))

                Text("Các sự kiện bạn tạo sẽ tự động xuất hiện dưới dạng chấm màu hoặc danh sách trên hình nền màn hình khóa.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(viewModel.events.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.35))
                Text("Sự kiện")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.14, green: 0.14, blue: 0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Phân Loại Tab
    private var filterSegmentControl: some View {
        HStack(spacing: 8) {
            ForEach(EventFilterMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        filterMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 12, weight: filterMode == mode ? .bold : .medium))
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(filterMode == mode ? Color(red: 1.0, green: 0.82, blue: 0.35) : Color.white.opacity(0.08))
                        )
                        .foregroundStyle(filterMode == mode ? Color.black : Color.white.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Trạng Thái Trống
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.35).opacity(0.8))
                .padding(.top, 30)

            Text("Chưa Có Sự Kiện Nào")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Text("Hãy bấm '+ Thêm Mới' ở góc trên để tạo sự kiện hoặc deadline đầu tiên của bạn nhé!")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

/// Thẻ hiển thị một sự kiện trong danh sách.
struct EventCardRow: View {
    let event: CalendarEvent
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Biểu tượng danh mục
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.gradient(for: event.category))
                        .frame(width: 42, height: 42)

                    Image(systemName: event.category.symbolName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }

                // Chi tiết sự kiện
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(event.category.displayName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.35))

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))

                        Text(formatEventTime(event.startDate, isAllDay: event.isAllDay))
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                // Nút Xóa
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func formatEventTime(_ date: Date, isAllDay: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        if isAllDay {
            formatter.dateFormat = "d 'tháng' M (Cả ngày)"
        } else {
            formatter.dateFormat = "HH:mm, d 'tháng' M"
        }
        return formatter.string(from: date)
    }
}

// MARK: - Quản Lý Ngữ Cảnh Thêm/Sửa Sự Kiện
enum EventEditorContext: Identifiable {
    case add
    case edit(CalendarEvent)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let event): return event.id.uuidString
        }
    }

    var eventToEdit: CalendarEvent? {
        switch self {
        case .add: return nil
        case .edit(let event): return event
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
