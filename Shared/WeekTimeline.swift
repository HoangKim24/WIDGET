import Foundation
import WidgetKit

/// Dữ liệu cho một ngày trong tuần, dùng chung cho cả Lock Screen và Large widget.
struct WeekDaySummary: Identifiable, Equatable {
    let id: String
    let date: Date
    let dayNumber: Int
    let weekdaySymbol: String
    let events: [CalendarEvent]
    let isToday: Bool

    init(
        date: Date,
        dayNumber: Int,
        weekdaySymbol: String,
        events: [CalendarEvent],
        isToday: Bool
    ) {
        self.id = Self.identifier(for: date)
        self.date = date
        self.dayNumber = dayNumber
        self.weekdaySymbol = weekdaySymbol
        self.events = events
        self.isToday = isToday
    }

    private static func identifier(for date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}

/// Entry của WidgetKit cho một snapshot tuần cụ thể.
struct WeekEntry: TimelineEntry {
    let date: Date
    let weekStartDate: Date
    let days: [WeekDaySummary]
    let upcomingEvent: CalendarEvent?
}

/// Tạo entry tuần từ dữ liệu cục bộ trong App Group.
struct WeekTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeekEntry {
        WeekTimelineBuilder.makeEntry(referenceDate: .now, events: SharedEventSeed.sampleEvents)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekEntry) -> Void) {
        let events = SharedDataStore.shared.loadEvents()
        let fallbackEvents = events.isEmpty ? SharedEventSeed.sampleEvents : events
        completion(WeekTimelineBuilder.makeEntry(referenceDate: .now, events: fallbackEvents))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeekEntry>) -> Void) {
        let currentDate = Date()
        let events = SharedDataStore.shared.loadEvents()
        let timelineEvents = events.isEmpty ? SharedEventSeed.sampleEvents : events
        let entry = WeekTimelineBuilder.makeEntry(referenceDate: currentDate, events: timelineEvents)
        let refreshDate = WeekTimelineBuilder.nextRefreshDate(after: currentDate, events: timelineEvents)

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

/// Hàm thuần Swift để gom dữ liệu sự kiện vào cấu trúc tuần.
enum WeekTimelineBuilder {
    static func makeEntry(referenceDate: Date, events: [CalendarEvent], calendar: Calendar = .autoupdatingCurrent) -> WeekEntry {
        let weekStartDate = startOfWeek(containing: referenceDate, calendar: calendar)
        let weekDates = (0..<7).compactMap { offset -> Date? in
            calendar.date(byAdding: .day, value: offset, to: weekStartDate)
        }

        let days = weekDates.map { dayDate in
            let startOfDay = calendar.startOfDay(for: dayDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? dayDate
            let dayEvents = events
                .filter { event in
                    event.startDate < endOfDay && event.endDate >= startOfDay
                }
                .sorted { $0.startDate < $1.startDate }

            let weekdaySymbol = weekdayLabel(for: dayDate, calendar: calendar)
            let dayNumber = calendar.component(.day, from: dayDate)
            let isToday = calendar.isDateInToday(dayDate)

            return WeekDaySummary(
                date: dayDate,
                dayNumber: dayNumber,
                weekdaySymbol: weekdaySymbol,
                events: dayEvents,
                isToday: isToday
            )
        }

        let upcomingEvent = events
            .filter { $0.endDate >= referenceDate }
            .sorted { $0.startDate < $1.startDate }
            .first

        return WeekEntry(
            date: referenceDate,
            weekStartDate: weekStartDate,
            days: days,
            upcomingEvent: upcomingEvent
        )
    }

    static func nextRefreshDate(after date: Date, events: [CalendarEvent], calendar: Calendar = .autoupdatingCurrent) -> Date {
        let startOfNextHour = calendar.dateInterval(of: .hour, for: date)?.end ?? date.addingTimeInterval(60 * 60)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date.addingTimeInterval(60 * 60 * 24)

        let nextEventDate = events
            .filter { $0.startDate > date }
            .map(\ .startDate)
            .sorted()
            .first

        let candidates = [startOfNextHour, startOfNextDay, nextEventDate].compactMap { $0 }
        return candidates.min() ?? startOfNextHour
    }

    static func startOfWeek(containing date: Date, calendar: Calendar = .autoupdatingCurrent) -> Date {
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)
        return weekInterval?.start ?? calendar.startOfDay(for: date)
    }

    static func events(on day: Date, in events: [CalendarEvent], calendar: Calendar = .autoupdatingCurrent) -> [CalendarEvent] {
        let startOfDay = calendar.startOfDay(for: day)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? day

        return events
            .filter { event in
                event.startDate < endOfDay && event.endDate >= startOfDay
            }
            .sorted { $0.startDate < $1.startDate }
    }

    static func upcomingEvent(from events: [CalendarEvent], referenceDate: Date) -> CalendarEvent? {
        events
            .filter { $0.endDate >= referenceDate }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    private static func weekdayLabel(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .autoupdatingCurrent
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
