import SwiftUI

/// Giao diện xem trước và chọn các sự kiện từ Lịch iPhone để đưa vào Bảng Lịch Tuần
struct DeviceCalendarImportSheet: View {
    @ObservedObject var viewModel: EventListViewModel
    let weekDays: [Date]
    @Environment(\.dismiss) private var dismiss

    @StateObject private var syncManager = DeviceCalendarSyncManager.shared
    @State private var fetchedItems: [SelectableCalendarEvent] = []
    @State private var hasRequestedPermission = false
    @State private var isLoading = false

    struct SelectableCalendarEvent: Identifiable {
        let id = UUID()
        var event: CalendarEvent
        var isSelected: Bool = true
    }

    private var selectedCount: Int {
        fetchedItems.filter { $0.isSelected }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if !syncManager.isAuthorized {
                    unauthorizedView
                } else if isLoading {
                    loadingView
                } else if fetchedItems.isEmpty {
                    emptyEventsView
                } else {
                    eventsListView
                }
            }
            .padding(16)
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("Đồng Bộ Lịch iPhone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                }
            }
            .task {
                syncManager.checkCurrentAuthorization()
                if syncManager.isAuthorized {
                    await loadEvents()
                }
            }
        }
    }

    private var unauthorizedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 54))
                .foregroundStyle(Color.cyan)

            Text("Quyền Truy Cập Lịch")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Để đọc các sự kiện từ iCloud, Google Calendar hoặc lịch máy, bạn vui lòng cấp quyền truy cập Lịch.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                Task {
                    let granted = await syncManager.requestCalendarAccess()
                    if granted {
                        await loadEvents()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                    Text("Cho Phép Truy Cập Lịch")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.cyan)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.cyan.opacity(0.4), radius: 8, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .tint(.cyan)
                .scaleEffect(1.2)
            Text("Đang đọc sự kiện từ Lịch iPhone...")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
        }
    }

    private var emptyEventsView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))

            Text("Không tìm thấy sự kiện nào")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Trong tuần này trên Lịch iPhone (iCloud/Google) của bạn chưa có sự kiện nào.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()
        }
    }

    private var eventsListView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("TÌM THẤY (\(selectedCount)/\(fetchedItems.count)) SỰ KIỆN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.green.opacity(0.9))

                Spacer()

                Button(selectedCount == fetchedItems.count ? "Bỏ chọn hết" : "Chọn tất cả") {
                    let shouldSelectAll = selectedCount != fetchedItems.count
                    for i in fetchedItems.indices {
                        fetchedItems[i].isSelected = shouldSelectAll
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.cyan)
            }
            .padding(.horizontal, 4)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(fetchedItems.indices, id: \.self) { idx in
                        let item = fetchedItems[idx]
                        HStack(spacing: 10) {
                            Button {
                                fetchedItems[idx].isSelected.toggle()
                            } label: {
                                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(item.isSelected ? Color.cyan : Color.white.opacity(0.3))
                            }

                            // Thứ
                            Text(vietnameseWeekdayShort(item.event.startDate))
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            // Giờ
                            Text(formatTimeRange(item.event))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.9))

                            // Tiêu đề
                            Text(item.event.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(eventColor(for: item.event.category))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                }
            }

            // Nút nhập vào lịch tuần
            Button {
                importSelectedEvents()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Nhập \(selectedCount) Sự Kiện Vào Bảng Tuần")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.58, blue: 1.0), Color(red: 0.42, green: 0.36, blue: 0.91)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.blue.opacity(0.35), radius: 8, y: 3)
            }
            .disabled(selectedCount == 0)
        }
    }

    private func loadEvents() async {
        isLoading = true
        let events = await syncManager.fetchEvents(for: weekDays)
        fetchedItems = events.map { SelectableCalendarEvent(event: $0, isSelected: true) }
        isLoading = false
    }

    private func importSelectedEvents() {
        let eventsToImport = fetchedItems.filter { $0.isSelected }.map { $0.event }
        viewModel.importEvents(eventsToImport)
        dismiss()
    }

    private func vietnameseWeekdayShort(_ date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return "CN"
        case 2: return "T2"
        case 3: return "T3"
        case 4: return "T4"
        case 5: return "T5"
        case 6: return "T6"
        case 7: return "T7"
        default: return ""
        }
    }

    private func formatTimeRange(_ event: CalendarEvent) -> String {
        if event.isAllDay { return "Cả ngày" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startDate))–\(formatter.string(from: event.endDate))"
    }

    private func eventColor(for category: EventCategory) -> Color {
        switch category {
        case .work: return Color(red: 0.92, green: 0.30, blue: 0.29)
        case .personal: return Color(red: 0.18, green: 0.58, blue: 1.0)
        case .health: return Color(red: 0.28, green: 0.79, blue: 0.89)
        case .study: return Color(red: 0.98, green: 0.79, blue: 0.14)
        case .family: return Color(red: 0.91, green: 0.26, blue: 0.58)
        case .other: return Color(red: 0.42, green: 0.36, blue: 0.91)
        }
    }
}
