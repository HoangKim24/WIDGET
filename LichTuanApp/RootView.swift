import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EventListViewModel()
    @State private var selectedDay = Calendar.current.startOfDay(for: Date())
    @State private var editorContext: EditorContext?
    @State private var showAppIconConcepts = false
    @State private var showSyncSettings = false

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private var selectedEvents: [CalendarEvent] {
        viewModel.events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay) }
    }

    private var todayEvents: [CalendarEvent] {
        viewModel.events.filter { Calendar.current.isDateInToday($0.startDate) }
    }

    private var nextEvent: CalendarEvent? {
        viewModel.events.first { $0.startDate >= Date() }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WeekHeaderView(days: weekDays, selectedDay: $selectedDay)

                    QuickMetricsView(todayCount: todayEvents.count, nextEvent: nextEvent)

                    TimelineSection(
                        selectedDay: selectedDay,
                        events: selectedEvents,
                        onAdd: { editorContext = .add },
                        onSelect: { editorContext = .edit($0) }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(monthTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hôm nay") {
                        selectedDay = Calendar.current.startOfDay(for: Date())
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorContext = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Thêm sự kiện")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.load()
                        } label: {
                            Label("Làm mới", systemImage: "arrow.clockwise")
                        }

                        Button {
                            showAppIconConcepts = true
                        } label: {
                            Label("Xem biểu tượng", systemImage: "paintpalette.fill")
                        }

                        Menu("Đồng bộ widget") {
                            Button {
                                showSyncSettings = true
                            } label: {
                                Label("Cấu hình GitHub token", systemImage: "key.fill")
                            }

                            Button {
                                viewModel.syncToRemote()
                            } label: {
                                Label("Đẩy dữ liệu lên widget", systemImage: "arrow.up.circle.fill")
                            }
                            .disabled(!viewModel.isRemoteSyncReady)

                            Button {
                                viewModel.pullFromRemote()
                            } label: {
                                Label("Tải dữ liệu từ Gist", systemImage: "arrow.down.circle.fill")
                            }
                            .disabled(!RemoteSyncConfig.isConfigured)
                        }

                        Divider()

                        Button(role: .destructive) {
                            viewModel.clearAll()
                        } label: {
                            Label("Xóa tất cả sự kiện", systemImage: "trash")
                        }
                        .disabled(viewModel.events.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Tùy chọn")
                }
            }
            .sheet(item: $editorContext) { context in
                switch context {
                case .add:
                    EventEditorView(event: nil) { newEvent in
                        viewModel.add(newEvent)
                        editorContext = nil
                    }
                case .edit(let event):
                    EventEditorView(event: event) { updatedEvent in
                        viewModel.update(updatedEvent)
                        editorContext = nil
                    }
                }
            }
            .sheet(isPresented: $showAppIconConcepts) {
                AppIconConceptsView()
            }
            .sheet(isPresented: $showSyncSettings) {
                RemoteSyncSettingsView {
                    viewModel.syncToRemote()
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: selectedDay).capitalized
    }
}

private struct WeekHeaderView: View {
    let days: [Date]
    @Binding var selectedDay: Date

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.self) { day in
                DayCapsuleView(
                    date: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDay),
                    isToday: Calendar.current.isDateInToday(day)
                ) {
                    selectedDay = day
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DayCapsuleView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Text(weekdayText)
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                Text(String(Calendar.current.component(.day, from: date)))
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent)) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)))
            }
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColors.accent, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var weekdayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    private var accessibilityText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

private struct QuickMetricsView: View {
    let todayCount: Int
    let nextEvent: CalendarEvent?

    var body: some View {
        HStack(spacing: 12) {
            MetricCardView(title: "Hôm nay", value: "\(todayCount)", detail: "sự kiện", icon: "calendar", tint: AppColors.accent)
            MetricCardView(title: "Sắp tới", value: nextEvent?.title ?? "Trống", detail: nextEvent.map(timeText) ?? "Chưa có lịch", icon: nextEvent?.category.symbolName ?? "checkmark.circle", tint: nextEvent?.category.color ?? .secondary)
        }
    }

    private func timeText(for event: CalendarEvent) -> String {
        if event.isAllDay { return "Cả ngày" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}

private struct MetricCardView: View {
    let title: String
    let value: String
    let detail: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(detail).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct TimelineSection: View {
    let selectedDay: Date
    let events: [CalendarEvent]
    let onAdd: () -> Void
    let onSelect: (CalendarEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(dayTitle).font(.title3.weight(.bold))
                    Text("\(events.count) sự kiện").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if !events.isEmpty {
                    Button("Thêm", action: onAdd)
                        .font(.subheadline.weight(.semibold))
                }
            }

            if events.isEmpty {
                EmptyDayView(onAdd: onAdd)
            } else {
                VStack(spacing: 10) {
                    ForEach(events) { event in
                        EventCardView(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(event) }
                    }
                }
            }
        }
    }

    private var dayTitle: String {
        if Calendar.current.isDateInToday(selectedDay) { return "Hôm nay" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: selectedDay).capitalized
    }
}

private struct EventCardView: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(timeText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(event.category.color)
                .multilineTextAlignment(.center)
                .frame(width: 52)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text(event.title).font(.headline).lineLimit(2)
                    Spacer(minLength: 0)
                    Image(systemName: event.category.symbolName).foregroundStyle(event.category.color)
                }
                HStack(spacing: 8) {
                    CapsuleLabel(text: event.category.displayName, symbol: event.category.symbolName, tint: event.category.color)
                    Text(event.isAllDay ? "Cả ngày" : durationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var timeText: String {
        if event.isAllDay { return "Cả\nngày" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }

    private var durationText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeStyle = .short
        return "đến \(formatter.string(from: event.endDate))"
    }
}

private struct EmptyDayView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(AppColors.accent)
            Text("Không có lịch trình hôm nay")
                .font(.subheadline.weight(.semibold))
            Button("Thêm sự kiện", action: onAdd)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct HeroCardView: View {
    let totalEvents: Int
    let nextEvent: CalendarEvent?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                        Text("Lịch Tuần")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        Text("Lịch tuần gọn gàng, dễ xem và đồng bộ widget.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent))
                        .frame(width: 84, height: 84)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.12))
                        .frame(width: 58, height: 58)
                        .overlay {
                            Image(systemName: nextEvent?.category.symbolName ?? "calendar")
                                .foregroundStyle(.white)
                                .font(.title3.weight(.semibold))
                        }
                }
                .shadow(color: AppColors.accent.opacity(0.18), radius: 18, y: 10)
                
            }

            HStack(spacing: 10) {
                StatChip(title: "Sự kiện", value: "\(totalEvents)", icon: "calendar.badge.plus")
                StatChip(title: "Tiếp theo", value: nextEvent?.category.displayName ?? "Trống", icon: nextEvent?.category.symbolName ?? "circle")
            }

            HStack(spacing: 8) {
                Label("App + Widget synced", systemImage: "link")
                Spacer()
                Text(Date.now, style: .date)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [AppColors.primary.opacity(0.24), AppColors.accent.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.primary.opacity(0.08), radius: 20, y: 8)
        .padding(.vertical, 4)
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.accent.opacity(0.14))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .foregroundStyle(AppColors.accent)
                    .font(.caption.weight(.semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.gradient(for: event.category))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: event.category.symbolName)
                        .foregroundStyle(.white)
                        .font(.headline.weight(.semibold))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    CapsuleLabel(text: event.category.displayName, symbol: event.category.symbolName, tint: event.category.color)

                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
        .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
        .listRowBackground(Color.clear)
    }

    private var detailText: String {
        if event.isAllDay {
            return "Cả ngày"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }
}

private struct CapsuleLabel: View {
    let text: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }
}

private struct EmptyEventsCard: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent))
                        .frame(width: 56, height: 56)

                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.white)
                        .font(.title3.weight(.semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                        Text("Chưa có sự kiện")
                        .font(.headline)
                        Text("Thêm sự kiện đầu tiên để lịch tuần và widget có dữ liệu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(action: onAdd) {
                Label("Thêm sự kiện", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(AppColors.primary.opacity(0.18), lineWidth: 1)
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

/// Dòng hiển thị trạng thái đồng bộ gần nhất giữa app và Gist.
private struct SyncStatusRow: View {
    let status: SyncStatus

    var body: some View {
        HStack(spacing: 10) {
            if case .syncing = status {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: symbolName)
                    .foregroundStyle(tint)
            }

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("SyncStatusRow")
    }

    private var symbolName: String {
        switch status {
        case .idle:
            return "clock.arrow.circlepath"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .success:
            return .green
        case .failure:
            return .orange
        default:
            return .secondary
        }
    }

    private var message: String {
        switch status {
        case .idle:
            return RemoteSyncConfig.isConfigured
                ? "Chưa đồng bộ trong phiên này."
                : "Chưa cấu hình Gist ID nên widget đang dùng dữ liệu mẫu."
        case .syncing:
            return "Đang đồng bộ với Gist..."
        case .success(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            return "Đồng bộ thành công lúc \(formatter.string(from: date))."
        case .failure(let reason):
            return "Đồng bộ thất bại: \(reason)"
        }
    }
}

private enum EditorContext: Identifiable {
    case add
    case edit(CalendarEvent)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let event):
            return event.id.uuidString
        }
    }
}

#Preview {
    ContentView()
}

