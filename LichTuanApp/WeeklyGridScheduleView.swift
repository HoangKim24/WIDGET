import SwiftUI

/// Bảng Lưới Tuần Trực Tiếp Trong App - Nơi người dùng xếp lịch trình 7 ngày (Thứ 2 đến Chủ Nhật)
/// với các ô chọn giờ cụ thể (Giờ bắt đầu - Giờ kết thúc), màu sắc và công việc.
struct WeeklyGridScheduleView: View {
    @ObservedObject var viewModel: EventListViewModel
    var onGoToStudio: (() -> Void)? = nil

    private let calendar = Calendar.current

    // Ngày đang được chọn để chỉnh sửa (mặc định là hôm nay)
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    // Dữ liệu nhập cho sự kiện mới
    @State private var newEventTitle: String = ""
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var selectedCategory: EventCategory = .work
    @State private var isAllDay: Bool = false
    @State private var isRecurringWeekly: Bool = false
    @State private var hasReminder: Bool = false
    @State private var showResetAlert = false
    @State private var showAutoGuide = false
    @State private var showImportSheet = false

    // Danh sách 7 ngày trong tuần hiện tại (Thứ 2 -> Chủ Nhật)
    private var currentWeekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    // Sự kiện thuộc ngày đang chọn (bao gồm cả sự kiện lặp lại hàng tuần vào thứ này)
    private var eventsForSelectedDate: [CalendarEvent] {
        let selWeekday = calendar.component(.weekday, from: selectedDate)
        return viewModel.events
            .filter { ev in
                if calendar.isDate(ev.startDate, inSameDayAs: selectedDate) { return true }
                if ev.isRecurringWeekly {
                    return calendar.component(.weekday, from: ev.startDate) == selWeekday
                }
                return false
            }
            .sorted { $0.startDate < $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - PHẦN 1: BẢNG TỔNG QUAN 7 CỘT TUẦN (Thứ 2 - CN)
                    weeklyMatrixOverviewCard

                    // MARK: - PHẦN 2: DANH SÁCH LỊCH TRÌNH ĐÃ XẾP TRONG NGÀY
                    scheduledSlotsSection

                    // MARK: - PHẦN 3: KHUNG XẾP LỊCH TRÌNH VÀO NGÀY ĐANG CHỌN
                    scheduleInputCard

                    // MARK: - NÚT XUẤT HÌNH NÈN KHÓA
                    if let onGoToStudio = onGoToStudio {
                        Button(action: onGoToStudio) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Xem & Xuất Hình Nền Màn Hình Khóa")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
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
                            .shadow(color: Color(red: 0.18, green: 0.58, blue: 1.0).opacity(0.35), radius: 10, y: 4)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("Bảng Lịch Tuần")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showAutoGuide = true
                        } label: {
                            Label("Cài Đặt Tự Động Hóa", systemImage: "bolt.badge.automatic")
                        }

                        Button {
                            showImportSheet = true
                        } label: {
                            Label("Dán Lịch Từ Zalo / Ghi Chú", systemImage: "doc.on.clipboard")
                        }

                        Button {
                            viewModel.loadSampleEvents()
                        } label: {
                            Label("Nạp Lịch Mẫu Tiếng Việt", systemImage: "sparkles")
                        }

                        Button(role: .destructive) {
                            NotificationManager.shared.cancelAllNotifications()
                            viewModel.clearAll()
                        } label: {
                            Label("Xóa Hết Lịch Trình", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .sheet(isPresented: $showAutoGuide) {
                AutoWallpaperSetupGuideView()
            }
            .sheet(isPresented: $showImportSheet) {
                SmartScheduleImportSheet(viewModel: viewModel)
            }
        }
    }

    // MARK: - Component 1: Bảng 7 Cột Tuần Trực Quan (Chạm để chọn ngày)
    private var weeklyMatrixOverviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("BẢNG 7 NGÀY TRONG TUẦN")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.5)

                Spacer()

                Text("Chạm vào cột để xếp lịch")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(red: 0.28, green: 0.79, blue: 0.89))
            }

            HStack(spacing: 4) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(day)
                    let dayWeekday = calendar.component(.weekday, from: day)
                    let dayEvents = viewModel.events.filter { ev in
                        if calendar.isDate(ev.startDate, inSameDayAs: day) { return true }
                        if ev.isRecurringWeekly {
                            return calendar.component(.weekday, from: ev.startDate) == dayWeekday
                        }
                        return false
                    }.sorted { $0.startDate < $1.startDate }
                    let dayNum = calendar.component(.day, from: day)
                    let shortName = vietnameseWeekdayShort(day)

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = day
                        }
                    } label: {
                        VStack(spacing: 4) {
                            // Header Thứ & Ngày
                            VStack(spacing: 1) {
                                Text(shortName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0) : .white.opacity(0.8))

                                Text("\(dayNum)")
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundStyle(isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0) : (isToday ? Color(red: 0.95, green: 0.65, blue: 0.40) : .white))
                            }
                            .padding(.bottom, 2)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .fill(isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0) : Color.white.opacity(0.1))
                                    .frame(height: 1.5),
                                alignment: .bottom
                            )

                            // Các ô khối công việc trong cột
                            VStack(spacing: 2) {
                                if !dayEvents.isEmpty {
                                    ForEach(dayEvents.prefix(3)) { ev in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(eventColor(for: ev.category))
                                            .frame(height: 12)
                                            .overlay(
                                                Text(ev.title)
                                                    .font(.system(size: 6.5, weight: .bold))
                                                    .foregroundStyle(isLightColor(ev.category) ? Color.black : Color.white)
                                                    .lineLimit(1)
                                                    .padding(.horizontal, 1)
                                            )
                                    }
                                    if dayEvents.count > 3 {
                                        Text("+\(dayEvents.count - 3)")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                } else {
                                    Text("+")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.2))
                                        .frame(height: 38)
                                }
                            }
                            .frame(minHeight: 44)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0).opacity(0.18) : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Component 2: Khung Nhập & Chọn Giờ Cụ Thể (Xếp Lịch)
    private var scheduleInputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tiêu đề ngày đang xếp
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))

                Text("Xếp Việc Vào \(vietnameseFullDate(selectedDate))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()
            }

            // 1. Ô nhập tên công việc
            VStack(alignment: .leading, spacing: 6) {
                Text("TÊN CÔNG VIỆC")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))

                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))

                    TextField("Ví dụ: 07:00 Đi làm, Họp team, Tập gym...", text: $newEventTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)

                    if !newEventTitle.isEmpty {
                        Button {
                            newEventTitle = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }

            // 2. Ô CHỌN GIỜ CỤ THỂ (Bắt đầu - Kết thúc)
            VStack(alignment: .leading, spacing: 6) {
                Text("KHUNG GIỜ CỤ THỂ")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: 12) {
                    // Ô giờ bắt đầu
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bắt đầu")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))

                        DatePicker(
                            "",
                            selection: $startTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .colorScheme(.dark)
                        .onChange(of: startTime) { newStart in
                            if endTime <= newStart {
                                endTime = newStart.addingTimeInterval(3600)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))

                    // Ô giờ kết thúc
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Kết thúc")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))

                        DatePicker(
                            "",
                            selection: $endTime,
                            in: startTime.addingTimeInterval(900)...,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .colorScheme(.dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Phím tắt giờ nhanh phổ biến
                HStack(spacing: 6) {
                    presetHourButton(title: "07:00–10:00", sH: 7, sM: 0, eH: 10, eM: 0)
                    presetHourButton(title: "12:00–13:00", sH: 12, sM: 0, eH: 13, eM: 0)
                    presetHourButton(title: "13:30–14:00", sH: 13, sM: 30, eH: 14, eM: 0)
                    presetHourButton(title: "16:30–17:00", sH: 16, sM: 30, eH: 17, eM: 0)
                }
                .padding(.top, 4)
            }

            // 3. Chọn Màu Khối Lịch
            VStack(alignment: .leading, spacing: 6) {
                Text("MÀU SẮC Ô LỊCH")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: 8) {
                    ForEach(EventCategory.allCases) { cat in
                        let isSelected = selectedCategory == cat
                        Button {
                            selectedCategory = cat
                        } label: {
                            Circle()
                                .fill(eventColor(for: cat))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 2.5 : 0)
                                )
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // 4. Tùy chọn nâng cao: Lặp lại hàng tuần & Bật nhắc nhở
            VStack(spacing: 8) {
                Toggle(isOn: $isRecurringWeekly) {
                    HStack(spacing: 8) {
                        Image(systemName: "repeat")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(isRecurringWeekly ? Color(red: 0.18, green: 0.58, blue: 1.0) : .white.opacity(0.5))
                        Text("Lặp lại hàng tuần (Thời khóa biểu)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .tint(Color(red: 0.18, green: 0.58, blue: 1.0))

                Divider().background(Color.white.opacity(0.08))

                Toggle(isOn: $hasReminder) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(hasReminder ? Color.yellow : .white.opacity(0.5))
                        Text("Bật nhắc nhở (Đổ chuông & Ghim Reminders)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .tint(Color.yellow)
            }
            .padding(10)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // NÚT THÊM VÀO BẢNG
            Button {
                addCurrentEvent()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Xếp Vào Bảng Lịch")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    newEventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.white.opacity(0.12)
                        : Color(red: 0.18, green: 0.58, blue: 1.0)
                )
                .foregroundStyle(
                    newEventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.white.opacity(0.4)
                        : Color.white
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(newEventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Component 3: Danh Sách Công Việc Đã Xếp Trong Ngày
    private var scheduledSlotsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("LỊCH TRÌNH NGÀY NÀY (\(eventsForSelectedDate.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.5)

                Spacer()
            }

            if eventsForSelectedDate.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("Chưa có lịch trình cho ngày này")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Hãy nhập giờ và công việc ở trên để xếp vào bảng")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.11, green: 0.12, blue: 0.15))
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(eventsForSelectedDate) { event in
                        HStack(spacing: 12) {
                            // Cột màu
                            RoundedRectangle(cornerRadius: 3)
                                .fill(eventColor(for: event.category))
                                .frame(width: 4, height: 36)

                            // Khung giờ
                            Text(formatTimeRange(event))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(width: 95, alignment: .leading)

                            // Tên công việc + Icon lặp lại & nhắc nhở
                            HStack(spacing: 6) {
                                Text(event.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(eventColor(for: event.category))
                                    .lineLimit(1)

                                if event.isRecurringWeekly {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color(red: 0.28, green: 0.70, blue: 1.0))
                                }

                                if event.hasReminder {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color.yellow)
                                }
                            }

                            Spacer()

                            // Nút xóa ô lịch
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if event.hasReminder {
                                        NotificationManager.shared.cancelNotification(for: event.id)
                                    }
                                    viewModel.delete(event)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.red.opacity(0.8))
                                    .padding(6)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.11, green: 0.12, blue: 0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }

    // Helper tạo nút chọn giờ nhanh
    private func presetHourButton(title: String, sH: Int, sM: Int, eH: Int, eM: Int) -> some View {
        Button {
            if let newStart = calendar.date(bySettingHour: sH, minute: sM, second: 0, of: selectedDate),
               let newEnd = calendar.date(bySettingHour: eH, minute: eM, second: 0, of: selectedDate) {
                startTime = newStart
                endTime = newEnd
            }
        } label: {
            Text(title)
                .font(.system(size: 9.5, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .foregroundStyle(.white.opacity(0.85))
                .clipShape(Capsule())
        }
    }

    // Hàm thêm sự kiện
    private func addCurrentEvent() {
        let trimmed = newEventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Ghép ngày của selectedDate với giờ của startTime và endTime
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        let finalStart = calendar.date(
            bySettingHour: startComponents.hour ?? 7,
            minute: startComponents.minute ?? 0,
            second: 0,
            of: selectedDate
        ) ?? selectedDate

        let finalEnd = calendar.date(
            bySettingHour: endComponents.hour ?? 10,
            minute: endComponents.minute ?? 0,
            second: 0,
            of: selectedDate
        ) ?? finalStart.addingTimeInterval(3600)

        let event = CalendarEvent(
            title: trimmed,
            startDate: finalStart,
            endDate: finalEnd,
            category: selectedCategory,
            isAllDay: isAllDay,
            isRecurringWeekly: isRecurringWeekly,
            hasReminder: hasReminder
        )

        withAnimation(.spring(response: 0.3)) {
            viewModel.add(event)
            if hasReminder {
                NotificationManager.shared.scheduleNotification(for: event)
            }
            newEventTitle = ""
        }
    }

    // Formatters
    private func vietnameseWeekdayShort(_ date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
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

    private func vietnameseFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, dd/MM"
        return formatter.string(from: date).capitalized
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

    private func isLightColor(_ category: EventCategory) -> Bool {
        return category == .study || category == .health
    }
}
