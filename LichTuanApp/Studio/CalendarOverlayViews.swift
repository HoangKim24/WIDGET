import SwiftUI

// MARK: - Daily Agenda and Week Schedule (Hỗ Trợ 3 Bố Cục Thật & Màu Sắc Color Hunt)
struct DailyAgendaAndWeekScheduleView: View {
    let events: [CalendarEvent]
    var config: WallpaperConfig = WallpaperConfig()

    private let calendar = Calendar.current

    private var accent: Color {
        config.effectiveAccentColor
    }

    private func themeFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        config.fontTheme.font(size: size, weight: weight)
    }

    private var currentWeekDays: [Date] {
        calendar.weekDays()
    }

    /// Lấy danh sách sự kiện cho một ngày (hỗ trợ cả sự kiện lặp lại hàng tuần và khóa dừng lặp)
    private func events(for day: Date) -> [CalendarEvent] {
        return events.filter { $0.occurs(on: day, calendar: calendar) }
            .sorted { $0.startDate < $1.startDate }
    }

    /// Sự kiện hôm nay
    private var todayEvents: [CalendarEvent] {
        let today = Date()
        return events(for: today)
    }

    /// Sự kiện có bật nhắc nhở (Reminders) - chỉ lấy sự kiện hôm nay hoặc tương lai
    private var reminderEvents: [CalendarEvent] {
        let startOfToday = calendar.startOfDay(for: Date())
        return events
            .filter { ev in
                ev.hasReminder && (ev.isRecurringWeekly || ev.endDate >= startOfToday)
            }
            .sorted { $0.startDate < $1.startDate }
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
            Text("Lịch Trình Tuần")
                .font(themeFont(size: 18, weight: .heavy))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isToday = calendar.isDateInToday(day)
                    let dayNum = calendar.component(.day, from: day)
                    let dayName = day.vietnameseWeekdayShort
                    let dayEvs = events(for: day)

                    HStack(spacing: 8) {
                        // Cột Thứ & Ngày bên trái
                        HStack(spacing: 3) {
                            Text(dayName)
                                .font(.system(size: 10, weight: .bold))
                            Text("\(dayNum)")
                                .font(themeFont(size: 11, weight: .heavy))
                        }
                        .foregroundStyle(isToday ? Color.black : (accent))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(isToday ? accent : Color.white.opacity(0.08))
                        )
                        .frame(width: 58, alignment: .leading)

                        // Các ô việc theo hàng ngang (Cho phép xuống dòng tròn chữ, bỏ ScrollView để ImageRenderer vẽ chuẩn xác 100%)
                        if !dayEvs.isEmpty {
                            HStack(spacing: 5) {
                                ForEach(dayEvs.prefix(2)) { ev in
                                    HStack(alignment: .center, spacing: 4) {
                                        Text(ev.formattedTimeRange)
                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                            .opacity(0.9)
                                        Text(ev.title)
                                            .font(.system(size: 9, weight: .semibold))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(eventColor(for: ev.category))
                                    .foregroundStyle(isLightColor(ev.category) ? Color.black : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 4.5))
                                }
                                if dayEvs.count > 2 {
                                    Text("+\(dayEvs.count - 2)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.6))
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
                    .fill(Color(red: 0.11, green: 0.12, blue: 0.15).opacity(config.cardOpacity))
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
                    Text("LỊCH TRÌNH & HÔM NAY")
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
                .fill(Color(red: 0.12, green: 0.13, blue: 0.18).opacity(config.cardOpacity))
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
                            .font(themeFont(size: 10.5, weight: .heavy))
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

                    // Các khối màu sự kiện trong cột (Hỗ trợ xuống dòng để tròn chữ)
                    VStack(spacing: 2.5) {
                        if !dayEvents.isEmpty {
                            ForEach(dayEvents.prefix(4)) { event in
                                VStack(spacing: 0.5) {
                                    Text(event.formattedTimeRange)
                                        .font(.system(size: 6, weight: .bold, design: .monospaced))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .opacity(0.95)

                                    Text(event.title)
                                        .font(.system(size: 6.5, weight: .heavy))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.75)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal, 1.5)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity)
                                .background(eventColor(for: event.category))
                                .foregroundStyle(isLightColor(event.category) ? Color.black : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 3.5))
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
                .fill(Color(red: 0.11, green: 0.12, blue: 0.15).opacity(config.cardOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
        )
    }

    // MARK: - Component: Today (Tự động co giãn thông minh)
    private var todayAgendaSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !todayEvents.isEmpty {
                Text("Hôm Nay")
                    .font(themeFont(size: 15, weight: .heavy))
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 5) {
                    ForEach(todayEvents.prefix(3)) { event in
                        HStack(alignment: .top, spacing: 8) {
                            Text(event.formattedTimeRange)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .frame(width: 84, alignment: .leading)
                                .padding(.top, 1)

                            HStack(alignment: .top, spacing: 4) {
                                Text(event.title)
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundStyle(eventColor(for: event.category))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                if event.hasReminder {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Color.yellow)
                                        .padding(.top, 2)
                                }
                            }

                            Spacer(minLength: 0)
                        }
                    }
                }
            } else {
                // Tự co gọn khi hôm nay trống lịch để không che khuất hình nền
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundStyle(accent)
                    Text("Hôm nay thảnh thơi • Không có lịch trình")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.top, 2)
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
                    Text("Nhắc Việc")
                        .font(themeFont(size: 16, weight: .heavy))
                        .foregroundStyle(Color(red: 0.95, green: 0.61, blue: 0.07))
                }

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(reminderEvents.prefix(4)) { event in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(Color(red: 0.95, green: 0.61, blue: 0.07))
                                .frame(width: 4, height: 4)
                                .padding(.top, 6)

                            Text(event.title)
                                .font(.system(size: 12.5, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("(\(event.formattedTimeRange))")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 1)
                        }
                    }
                }
            }
        }
    }

    // Helpers
    private func eventColor(for category: EventCategory) -> Color {
        config.isMonochromeTheme ? accent : category.color
    }

    private func isLightColor(_ category: EventCategory) -> Bool {
        config.isMonochromeTheme ? false : category.isLightColor
    }
}
