import SwiftUI

// MARK: - Lưới Lịch Tháng Xinh Xắn (Minimalist Month Grid)
struct MonthlyGridCalendarView: View {
    let events: [CalendarEvent]
    let accentColor: Color
    var isGlassCard: Bool = false

    @State private var referenceDate = Date()

    private let calendar = Calendar.current
    private let weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "'Tháng' M • yyyy"
        return formatter.string(from: referenceDate)
    }

    private var monthDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: referenceDate) else {
            return []
        }

        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Trong Calendar, Chủ Nhật = 1, Thứ 2 = 2 ... Thứ 7 = 7
        // Ta muốn Thứ 2 là cột 0:
        let leadingEmptyCount = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCount)

        var current = firstDayOfMonth
        while current < monthInterval.end {
            days.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        // Điền thêm ô trống cho tròn bội số 7
        let trailingCount = (7 - (days.count % 7)) % 7
        days.append(contentsOf: Array(repeating: nil, count: trailingCount))

        return days
    }

    var body: some View {
        VStack(spacing: 10) {
            // Tiêu đề Tháng & Nút chuyển tháng
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        referenceDate = calendar.date(byAdding: .month, value: -1, to: referenceDate) ?? referenceDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(6)
                }

                Spacer()

                Text(monthYearTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        referenceDate = calendar.date(byAdding: .month, value: 1, to: referenceDate) ?? referenceDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(6)
                }
            }
            .padding(.horizontal, 8)

            // Hàng thứ trong tuần
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(day == "CN" ? accentColor : .white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                }
            }

            // Lưới các ngày trong tháng
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(0..<monthDays.count, id: \.self) { index in
                    if let dayDate = monthDays[index] {
                        let isToday = calendar.isDateInToday(dayDate)
                        let dayNumber = calendar.component(.day, from: dayDate)
                        let dayEvents = events.filter { calendar.isDate($0.startDate, inSameDayAs: dayDate) }

                        VStack(spacing: 2) {
                            ZStack {
                                if isToday {
                                    Circle()
                                        .fill(accentColor)
                                        .frame(width: 26, height: 26)
                                        .shadow(color: accentColor.opacity(0.6), radius: 4)
                                }

                                Text("\(dayNumber)")
                                    .font(.system(size: 12, weight: isToday ? .bold : .medium, design: .rounded))
                                    .foregroundStyle(isToday ? Color.black : Color.white)
                            }
                            .frame(height: 26)

                            // Chấm sự kiện xinh xắn
                            HStack(spacing: 2) {
                                if !dayEvents.isEmpty {
                                    Circle()
                                        .fill(isToday ? Color.white : accentColor)
                                        .frame(width: 3.5, height: 3.5)
                                } else {
                                    Spacer().frame(height: 3.5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(14)
        .background(
            Group {
                if isGlassCard {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                } else {
                    Color.clear
                }
            }
        )
    }
}

// MARK: - Lịch Tuần Năng Động (Weekly Planner)
struct WeeklyScheduleView: View {
    let events: [CalendarEvent]
    let accentColor: Color

    private let calendar = Calendar.current

    private var currentWeekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(accentColor)
                Text("Lịch Tuần Này")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(events.count) sự kiện")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 4)

            // Dải 7 ngày
            HStack(spacing: 6) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isToday = calendar.isDateInToday(day)
                    let dayNumber = calendar.component(.day, from: day)
                    let weekdaySymbol = vietnameseShortWeekday(for: day)
                    let dayEvents = events.filter { calendar.isDate($0.startDate, inSameDayAs: day) }

                    VStack(spacing: 5) {
                        Text(weekdaySymbol)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(isToday ? accentColor : .white.opacity(0.6))

                        ZStack {
                            if isToday {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(accentColor)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.12))
                            }

                            Text("\(dayNumber)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(isToday ? Color.black : Color.white)
                        }
                        .frame(height: 30)

                        if !dayEvents.isEmpty {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 4, height: 4)
                        } else {
                            Spacer().frame(height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Hiển thị 2-3 sự kiện nổi bật trong tuần
            let upcoming = events.prefix(3)
            if !upcoming.isEmpty {
                VStack(spacing: 6) {
                    ForEach(Array(upcoming)) { event in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 6, height: 6)

                            Text(event.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Spacer()

                            Text(formatEventDate(event.startDate))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                        )
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        )
    }

    private func vietnameseShortWeekday(for date: Date) -> String {
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

    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "HH:mm, d/M"
        return formatter.string(from: date)
    }
}
