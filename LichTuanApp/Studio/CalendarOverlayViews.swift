import SwiftUI

// MARK: - Daily Agenda and Week Schedule (Chuẩn 100% Theo Mẫu Tham Khảo)
struct DailyAgendaAndWeekScheduleView: View {
    let events: [CalendarEvent]
    var reminders: [String] = []

    private let calendar = Calendar.current

    private var currentWeekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private var displayEvents: [CalendarEvent] {
        events
    }

    private var todayEvents: [CalendarEvent] {
        displayEvents.filter { calendar.isDateInToday($0.startDate) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - PHẦN 1: BẢNG TUẦN 7 CỘT (Mon - Sun / T2 - CN)
            weekMatrixCard

            // MARK: - PHẦN 2: LỊCH TRÌNH HÔM NAY (Today)
            todayAgendaSection

            // MARK: - PHẦN 3: GHI CHÚ NHẮC VIỆC (Reminders)
            remindersSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Component 1: Bảng 7 Cột Tuần
    private var weekMatrixCard: some View {
        HStack(alignment: .top, spacing: 3) {
            ForEach(currentWeekDays, id: \.self) { day in
                let isToday = calendar.isDateInToday(day)
                let dayNum = calendar.component(.day, from: day)
                let dayName = vietnameseShortDay(for: day)
                let dayEvents = displayEvents.filter { calendar.isDate($0.startDate, inSameDayAs: day) }

                VStack(spacing: 3) {
                    // Header của cột (Thứ + Ngày)
                    VStack(spacing: 1) {
                        Text(dayName)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(isToday ? Color(red: 0.18, green: 0.58, blue: 1.0) : .white.opacity(0.75))
                        Text("\(dayNum)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(isToday ? Color(red: 0.18, green: 0.58, blue: 1.0) : .white)
                    }
                    .padding(.bottom, 2)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1),
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
                            Color.clear.frame(height: 48)
                        }
                    }
                    .frame(minHeight: 48)
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

    // MARK: - Component 2: Today (Lịch Trình Hôm Nay Với Khung Giờ Cụ Thể)
    private var todayAgendaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                if !todayEvents.isEmpty {
                    ForEach(todayEvents) { event in
                        HStack(spacing: 16) {
                            Text(formatTimeRange(event))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .frame(width: 95, alignment: .leading)

                            Text(event.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(eventColor(for: event.category))
                                .lineLimit(1)
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.yellow.opacity(0.8))
                        Text("Chưa có lịch trình hôm nay")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Component 3: Reminders (Ghi Chú Nhắc Việc)
    @ViewBuilder
    private var remindersSection: some View {
        if !reminders.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reminders")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.95, green: 0.61, blue: 0.07)) // Màu cam giống ảnh

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(reminders, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
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
        switch category {
        case .work: return Color(red: 0.92, green: 0.30, blue: 0.29)     // Đỏ san hô
        case .personal: return Color(red: 0.18, green: 0.58, blue: 1.0)  // Xanh dương
        case .health: return Color(red: 0.28, green: 0.79, blue: 0.89)    // Xanh cyan
        case .study: return Color(red: 0.98, green: 0.79, blue: 0.14)     // Vàng
        case .family: return Color(red: 0.91, green: 0.26, blue: 0.58)    // Hồng
        case .other: return Color(red: 0.42, green: 0.36, blue: 0.91)     // Tím
        }
    }

    private func isLightColor(_ category: EventCategory) -> Bool {
        return category == .study || category == .health
    }
}
