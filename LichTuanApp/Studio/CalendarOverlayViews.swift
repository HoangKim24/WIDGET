import SwiftUI

// MARK: - Daily Agenda and Week Schedule (Hỗ Trợ 3 Bố Cục Thật & Màu Sắc Color Hunt)
struct DailyAgendaAndWeekScheduleView: View {
    let events: [CalendarEvent]
    var config: WallpaperConfig = WallpaperConfig()

    private let calendar = Calendar.current

    private var accent: Color {
        config.effectiveAccentColor
    }

    private var currentWeekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    /// Lấy danh sách sự kiện cho một ngày (hỗ trợ cả sự kiện lặp lại hàng tuần)
    private func events(for day: Date) -> [CalendarEvent] {
        let dayWeekday = calendar.component(.weekday, from: day)
        return events.filter { ev in
            if calendar.isDate(ev.startDate, inSameDayAs: day) {
                return true
            }
            if ev.isRecurringWeekly {
                let evWeekday = calendar.component(.weekday, from: ev.startDate)
                return evWeekday == dayWeekday
            }
            return false
        }.sorted { $0.startDate < $1.startDate }
    }

    /// Sự kiện hôm nay
    private var todayEvents: [CalendarEvent] {
        let today = Date()
        return events(for: today)
    }

    /// Sự kiện có bật nhắc nhở (Reminders)
    private var reminderEvents: [CalendarEvent] {
        events.filter { $0.hasReminder }
    }

    var body: some View {
        Group {
            switch config.layoutType {
            case .columns:
                columnsLayoutView
            case .rows:
                rowsLayoutView
            case .frostedCard:
                frostedCardLayoutView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - BỐ CỤC 1: 7 CỘT TỐI GIẢN (Columns Layout)
    private var columnsLayoutView: some View {
        VStack(alignment: .leading, spacing: 14) {
            weekMatrixCard
            todayAgendaSection
            remindersSection
        }
    }

    // MARK: - BỐ CỤC 2: 7 DÒNG CHI TIẾT (Rows Layout)
    private var rowsLayoutView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Schedule")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isToday = calendar.isDateInToday(day)
                    let dayNum = calendar.component(.day, from: day)
                    let dayName = vietnameseShortDay(for: day)
                    let dayEvs = events(for: day)

                    HStack(spacing: 8) {
                        // Cột Thứ & Ngày bên trái
                        HStack(spacing: 3) {
                            Text(dayName)
                                .font(.system(size: 10, weight: .bold))
                            Text("\(dayNum)")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                        }
                        .foregroundStyle(isToday ? Color.black : (accent))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(isToday ? accent : Color.white.opacity(0.08))
                        )
                        .frame(width: 58, alignment: .leading)

                        // Các ô việc theo hàng ngang
                        if !dayEvs.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(dayEvs.prefix(3)) { ev in
                                        HStack(spacing: 3) {
                                            Text(formatTimeRange(ev))
                                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                                .opacity(0.85)
                                            Text(ev.title)
                                                .font(.system(size: 8.5, weight: .semibold))
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(eventColor(for: ev.category))
                                        .foregroundStyle(isLightColor(ev.category) ? Color.black : Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                            }
                        } else {
                            Text("—")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.25))
                                .padding(.leading, 4)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isToday ? accent.opacity(0.12) : Color.black.opacity(0.25))
                    )
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.11, green: 0.12, blue: 0.15).opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )

            todayAgendaSection
            remindersSection
        }
    }

    // MARK: - BỐ CỤC 3: KÍNH MỜ SANG CHẢNH (Frosted Glassmorphism Card)
    private var frostedCardLayoutView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header thẻ kính
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(accent)
                        .frame(width: 7, height: 7)
                    Text("AGENDA & WEEK")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(accent)
                        .tracking(0.8)
                }

                Spacer()

                Text("Hôm nay: \(vietnameseShortDay(for: Date()))")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.bottom, 2)

            weekMatrixCard
            todayAgendaSection
            remindersSection
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.18).opacity(0.75))
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .blur(radius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [accent.opacity(0.6), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 20, y: 10)
        )
    }

    // MARK: - Component: Bảng 7 Cột Tuần
    private var weekMatrixCard: some View {
        HStack(alignment: .top, spacing: 2.5) {
            ForEach(currentWeekDays, id: \.self) { day in
                let isToday = calendar.isDateInToday(day)
                let dayNum = calendar.component(.day, from: day)
                let dayName = vietnameseShortDay(for: day)
                let dayEvents = events(for: day)

                VStack(spacing: 3) {
                    // Header của cột (Thứ + Ngày)
                    VStack(spacing: 1) {
                        Text(dayName)
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundStyle(isToday ? accent : .white.opacity(0.75))
                        Text("\(dayNum)")
                            .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                            .foregroundStyle(isToday ? accent : .white)
                    }
                    .padding(.bottom, 2)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .fill(isToday ? accent : Color.white.opacity(0.12))
                            .frame(height: isToday ? 2 : 1),
                        alignment: .bottom
                    )

                    // Các khối màu sự kiện trong cột
                    VStack(spacing: 2.5) {
                        if !dayEvents.isEmpty {
                            ForEach(dayEvents.prefix(4)) { event in
                                VStack(spacing: 0.5) {
                                    Text(formatShortTime(event))
                                        .font(.system(size: 6, weight: .bold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text(event.title)
                                        .font(.system(size: 6.5, weight: .heavy))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .padding(.horizontal, 1.5)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity)
                                .background(eventColor(for: event.category))
                                .foregroundStyle(isLightColor(event.category) ? Color.black : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        } else {
                            Color.clear.frame(height: 44)
                        }
                    }
                    .frame(minHeight: 44)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.11, green: 0.12, blue: 0.15).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
        )
    }

    // MARK: - Component: Today
    private var todayAgendaSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 5) {
                if !todayEvents.isEmpty {
                    ForEach(todayEvents) { event in
                        HStack(spacing: 14) {
                            Text(formatTimeRange(event))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .frame(width: 95, alignment: .leading)

                            Text(event.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(eventColor(for: event.category))
                                .lineLimit(1)

                            if event.hasReminder {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.yellow)
                            }
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(accent)
                        Text("Không có lịch trình hôm nay")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 3)
                }
            }
        }
    }

    // MARK: - Component: Reminders
    @ViewBuilder
    private var remindersSection: some View {
        if !reminderEvents.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.95, green: 0.61, blue: 0.07))
                    Text("Reminders")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.95, green: 0.61, blue: 0.07))
                }

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(reminderEvents.prefix(4)) { event in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(red: 0.95, green: 0.61, blue: 0.07))
                                .frame(width: 4, height: 4)
                            Text(event.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("(\(formatShortTime(event)))")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }

    // Helpers
    private func vietnameseShortDay(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return "Sun"
        case 2: return "Mon"
        case 3: return "Tue"
        case 4: return "Wed"
        case 5: return "Thu"
        case 6: return "Fri"
        case 7: return "Sat"
        default: return ""
        }
    }

    private func formatTimeRange(_ event: CalendarEvent) -> String {
        if event.isAllDay { return "All day" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startDate))–\(formatter.string(from: event.endDate))"
    }

    private func formatShortTime(_ event: CalendarEvent) -> String {
        if event.isAllDay { return "All day" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startDate))–\(formatter.string(from: event.endDate))"
    }

    private func eventColor(for category: EventCategory) -> Color {
        if config.isMonochromeTheme {
            return accent
        }
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
        if config.isMonochromeTheme {
            return false
        }
        return category == .study || category == .health
    }
}
