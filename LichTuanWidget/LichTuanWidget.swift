import WidgetKit
import SwiftUI

// MARK: - Dữ Liệu Timeline Entry
struct LichTuanEntry: TimelineEntry {
    let date: Date
    let events: [CalendarEvent]

    /// Sự kiện hôm nay
    var todayEvents: [CalendarEvent] {
        let calendar = Calendar.current
        return events
            .filter { $0.occurs(on: date, calendar: calendar) }
            .sorted { $0.startDate < $1.startDate }
    }

    /// Sự kiện sắp tới hôm nay (chưa kết thúc)
    var upcomingTodayEvents: [CalendarEvent] {
        todayEvents.filter { $0.endDate >= date }
    }

    /// Sự kiện kế tiếp gần nhất
    var nextEvent: CalendarEvent? {
        upcomingTodayEvents.first ?? todayEvents.first
    }

    /// 7 ngày trong tuần hiện tại
    var weekDays: [Date] {
        Calendar.current.weekDays(for: date)
    }

    /// Lấy sự kiện cho một ngày cụ thể
    func events(for day: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events
            .filter { $0.occurs(on: day, calendar: calendar) }
            .sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - Timeline Provider
struct LichTuanTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LichTuanEntry {
        LichTuanEntry(date: Date(), events: samplePreviewEvents)
    }

    func getSnapshot(in context: Context, completion: @escaping (LichTuanEntry) -> Void) {
        let events = SharedDataStore.shared.loadEvents()
        let entry = LichTuanEntry(date: Date(), events: events.isEmpty ? samplePreviewEvents : events)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LichTuanEntry>) -> Void) {
        let currentDate = Date()
        let events = SharedDataStore.shared.loadEvents()
        let entry = LichTuanEntry(date: currentDate, events: events)

        // Cập nhật lại sau 30 phút hoặc ngay khi bắt đầu sự kiện tiếp theo
        var nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        if let nextStart = entry.upcomingTodayEvents.first?.startDate, nextStart > currentDate, nextStart < nextRefresh {
            nextRefresh = nextStart
        }

        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private var samplePreviewEvents: [CalendarEvent] {
        let now = Date()
        let calendar = Calendar.current
        let s1 = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: now) ?? now
        let e1 = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) ?? now.addingTimeInterval(5400)
        let s2 = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now) ?? now.addingTimeInterval(7200)
        let e2 = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: now) ?? now.addingTimeInterval(14400)

        return [
            CalendarEvent(title: "Họp kế hoạch tuần", startDate: s1, endDate: e1, category: .work),
            CalendarEvent(title: "Tập gym & chạy bộ", startDate: s2, endDate: e2, category: .health)
        ]
    }
}

// MARK: - Root Entry View Dispatcher
struct LichTuanWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LichTuanEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                LockScreenInlineView(entry: entry)
            case .accessoryCircular:
                LockScreenCircularView(entry: entry)
            case .accessoryRectangular:
                LockScreenRectangularView(entry: entry)
            case .systemSmall:
                HomeScreenSmallView(entry: entry)
            case .systemMedium:
                HomeScreenMediumView(entry: entry)
            case .systemLarge:
                HomeScreenLargeWeeklyGridView(entry: entry)
            default:
                HomeScreenMediumView(entry: entry)
            }
        }
        .widgetBackground(Color(red: 0.08, green: 0.09, blue: 0.12))
    }
}

// MARK: - 1. MÀN HÌNH KHÓA: Dòng Chữ Nhỏ Trên Đồng Hồ (Accessory Inline)
struct LockScreenInlineView: View {
    let entry: LichTuanEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
            if let ev = entry.nextEvent {
                Text("\(ev.startDate.timeString) \(ev.title)")
            } else {
                Text("Hôm nay: Rảnh rỗi")
            }
        }
    }
}

// MARK: - 2. MÀN HÌNH KHÓA: Hình Tròn Đếm Việc (Accessory Circular)
struct LockScreenCircularView: View {
    let entry: LichTuanEntry

    var body: some View {
        let count = entry.upcomingTodayEvents.count
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "checklist")
                    .font(.system(size: 11, weight: .bold))
                Text("\(count)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                Text("việc")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 3. MÀN HÌNH KHÓA: Khung Chữ Nhật Dưới Đồng Hồ (Accessory Rectangular)
struct LockScreenRectangularView: View {
    let entry: LichTuanEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Header ngày hôm nay
            HStack(spacing: 4) {
                Text(entry.date.vietnameseWeekdayShort)
                    .font(.system(size: 11, weight: .heavy))
                Text(entry.date.shortDateString)
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Text("\(entry.upcomingTodayEvents.count) việc")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            // Tối đa 2 sự kiện tiếp theo
            let items = Array(entry.upcomingTodayEvents.prefix(2))
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(items) { ev in
                        HStack(spacing: 4) {
                            Text(ev.startDate.timeString)
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            Text(ev.title)
                                .font(.system(size: 10, weight: .medium))
                                .lineLimit(1)
                        }
                    }
                }
            } else {
                Text("Không còn lịch trình trong ngày")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
    }
}

// MARK: - 4. MÀN HÌNH CHÍNH: Ô Vuông Nhỏ (System Small - 2x2)
struct HomeScreenSmallView: View {
    let entry: LichTuanEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Ngày
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.date.vietnameseWeekdayShort)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))
                    Text(entry.date.shortDateString)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 28, height: 28)
                    Text("\(entry.todayEvents.count)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
            }

            Divider()
                .background(Color.white.opacity(0.15))

            // Việc tiếp theo
            if let next = entry.nextEvent {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(next.category.color)
                            .frame(width: 6, height: 6)
                        Text(next.formattedTimeRange)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Text(next.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.13, green: 0.14, blue: 0.18))
                )
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.green.opacity(0.8))
                    Text("Đã xong hết việc")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(12)
    }
}

// MARK: - 5. MÀN HÌNH CHÍNH: Ô Chữ Nhật (System Medium - 2x4)
struct HomeScreenMediumView: View {
    let entry: LichTuanEntry

    var body: some View {
        HStack(spacing: 12) {
            // Khối Date Hero bên trái
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date.vietnameseWeekdayShort)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))

                Text("\(Calendar.current.component(.day, from: entry.date))")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text(entry.date.shortDateString)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 10))
                    Text("\(entry.upcomingTodayEvents.count) việc còn lại")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Color(red: 0.28, green: 0.79, blue: 0.89))
            }
            .frame(width: 88, alignment: .leading)

            Divider()
                .background(Color.white.opacity(0.15))

            // Danh sách việc hôm nay bên phải
            VStack(alignment: .leading, spacing: 6) {
                let items = Array(entry.upcomingTodayEvents.prefix(3))
                if !items.isEmpty {
                    ForEach(items) { ev in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ev.category.color)
                                .frame(width: 3.5, height: 26)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(ev.title)
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)

                                Text(ev.formattedTimeRange)
                                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.65))
                            }
                            Spacer()
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.yellow)
                        Text("Không còn lịch trình nào trong hôm nay!")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(14)
    }
}

// MARK: - 6. MÀN HÌNH CHÍNH: Bảng Lịch Tuần 7 Cột Thu Nhỏ (System Large - 4x4)
struct HomeScreenLargeWeeklyGridView: View {
    let entry: LichTuanEntry
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Tiêu đề tuần & ngày
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))
                    Text("BẢNG LỊCH TUẦN")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(.white)
                }

                Spacer()

                if let first = entry.weekDays.first, let last = entry.weekDays.last {
                    Text("\(first.shortDateString) – \(last.shortDateString)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Divider()
                .background(Color.white.opacity(0.12))

            // 7 Cột Lịch (Thứ 2 đến Chủ Nhật)
            HStack(alignment: .top, spacing: 4) {
                ForEach(entry.weekDays, id: \.self) { day in
                    let isToday = calendar.isDate(day, inSameDayAs: entry.date)
                    let dayNum = calendar.component(.day, from: day)
                    let dayEvs = entry.events(for: day)

                    VStack(spacing: 3) {
                        // Header cột (Thứ & Ngày)
                        VStack(spacing: 1) {
                            Text(day.vietnameseWeekdayShort)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(isToday ? Color.black : .white.opacity(0.8))

                            Text("\(dayNum)")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundStyle(isToday ? Color.black : .white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isToday ? Color(red: 0.18, green: 0.58, blue: 1.0) : Color.white.opacity(0.06))
                        )

                        // Các ô khối công việc
                        VStack(spacing: 2) {
                            if !dayEvs.isEmpty {
                                ForEach(dayEvs.prefix(3)) { ev in
                                    VStack(alignment: .leading, spacing: 0.5) {
                                        Text(ev.startDate.timeString)
                                            .font(.system(size: 6, weight: .bold, design: .monospaced))
                                            .lineLimit(1)
                                            .opacity(0.9)

                                        Text(ev.title)
                                            .font(.system(size: 6.5, weight: .heavy))
                                            .lineLimit(2)
                                    }
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(ev.category.color)
                                    .foregroundStyle(ev.category.textColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 3.5))
                                }
                                if dayEvs.count > 3 {
                                    Text("+\(dayEvs.count - 3)")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            } else {
                                Color.clear.frame(height: 20)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Tiện Ích Tương Thích Nền Widget (iOS 16 & iOS 17)
private extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return self.background(backgroundView)
        }
    }
}

// MARK: - Cấu Hình Widget Chính
struct LichTuanWidget: Widget {
    let kind: String = "LichTuanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LichTuanTimelineProvider()) { entry in
            LichTuanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lịch Tuần")
        .description("Xem nhanh lịch trình 7 ngày và sự kiện hôm nay ngay trên Màn hình chính và Màn hình khóa.")
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}
