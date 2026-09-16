import SwiftUI

// MARK: - Bảng Lịch Tuần 7 Ngày (Thứ Hai đến Chủ Nhật)
struct WeeklyScheduleView: View {
    let events: [CalendarEvent]
    let accentColor: Color
    var isGlassCard: Bool = false

    @State private var weekOffset: Int = 0
    private let calendar = Calendar.current

    private var currentWeekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let baseMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        let targetMonday = calendar.date(byAdding: .day, value: weekOffset * 7, to: baseMonday) ?? baseMonday
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: targetMonday) }
    }

    private var weekRangeTitle: String {
        guard let first = currentWeekDays.first, let last = currentWeekDays.last else { return "Tuần Này" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "d/M"
        if weekOffset == 0 {
            return "Tuần Này (\(formatter.string(from: first)) - \(formatter.string(from: last)))"
        } else if weekOffset == 1 {
            return "Tuần Sau (\(formatter.string(from: first)) - \(formatter.string(from: last)))"
        } else if weekOffset == -1 {
            return "Tuần Trước (\(formatter.string(from: first)) - \(formatter.string(from: last)))"
        } else {
            return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Thanh tiêu đề điều hướng tuần
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) { weekOffset -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(accentColor)
                    Text(weekRangeTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.35))
                )

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) { weekOffset += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
            }
            .padding(.horizontal, 4)

            // Danh sách 7 dòng cho 7 ngày trong tuần
            VStack(spacing: 5) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isToday = calendar.isDateInToday(day)
                    let dayEvents = events.filter { calendar.isDate($0.startDate, inSameDayAs: day) }
                    let weekdayName = vietnameseShortWeekday(for: day)
                    let dayNumber = calendar.component(.day, from: day)

                    HStack(spacing: 8) {
                        // Khối Thứ & Ngày
                        VStack(spacing: 1) {
                            Text(weekdayName)
                                .font(.system(size: 9, weight: .extrabold))
                                .textCase(.uppercase)
                            Text("\(dayNumber)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isToday ? accentColor : Color.white.opacity(0.12))
                        )
                        .foregroundStyle(isToday ? Color.black : Color.white)

                        // Nội dung công việc trong ngày
                        if let firstEvent = dayEvents.first {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 5, height: 5)
                                Text(firstEvent.title)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                        } else {
                            Text(isToday ? "Hôm nay không có lịch" : "—")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.white.opacity(0.35))
                        }

                        Spacer()

                        // Tag danh mục hoặc trạng thái
                        if isToday {
                            Text("Hôm nay")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(accentColor))
                                .foregroundStyle(Color.black)
                        } else if let cat = dayEvents.first?.category {
                            Text(cat.displayName)
                                .font(.system(size: 8, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.white.opacity(0.1)))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isToday ? accentColor.opacity(0.18) : Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isToday ? accentColor.opacity(0.7) : Color.clear, lineWidth: 1)
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isGlassCard ? Material.ultraThinMaterial : Material.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
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
}

// MARK: - Lưới 7 Cột Dọc Tối Giản
struct WeeklyColumnsView: View {
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
        HStack(spacing: 5) {
            ForEach(currentWeekDays, id: \.self) { day in
                let isToday = calendar.isDateInToday(day)
                let dayNumber = calendar.component(.day, from: day)
                let weekdayName = vietnameseShortWeekday(for: day)
                let dayEvents = events.filter { calendar.isDate($0.startDate, inSameDayAs: day) }

                VStack(spacing: 6) {
                    Text(weekdayName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(isToday ? accentColor : .white.opacity(0.6))

                    Text("\(dayNumber)")
                        .font(.system(size: 12, weight: .extrabold, design: .rounded))
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(isToday ? accentColor : Color.white.opacity(0.12)))
                        .foregroundStyle(isToday ? Color.black : Color.white)

                    if let first = dayEvents.first {
                        Text(first.title)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                    } else {
                        Spacer().frame(height: 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isToday ? accentColor.opacity(0.18) : Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isToday ? accentColor : Color.clear, lineWidth: 1)
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Material.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
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
}
