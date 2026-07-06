import SwiftUI
import WidgetKit

enum LockScreenSummaryStyle {
    case circular
    case rectangular
    case inline
}

/// Hiển thị 3 family nhỏ của Lock Screen bằng cùng một dữ liệu timeline.
struct LockScreenSummaryView: View {
    let entry: WeekEntry
    let style: LockScreenSummaryStyle

    var body: some View {
        switch style {
        case .circular:
            circularBody
        case .rectangular:
            rectangularBody
        case .inline:
            inlineBody
        }
    }

    private var upcomingTitle: String {
        entry.upcomingEvent?.title ?? "No events"
    }

    private var upcomingTimeText: String {
        guard let event = entry.upcomingEvent else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }

    private var circularBody: some View {
        VStack(spacing: 2) {
            Image(systemName: entry.upcomingEvent?.category.symbolName ?? "calendar")
                .font(.caption2)
                .widgetAccentable()
            Text(entry.days.first(where: { $0.isToday })?.events.count.description ?? "0")
                .font(.headline.weight(.semibold))
            Text("Soon")
                .font(.caption2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(6)
    }

    private var rectangularBody: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: entry.upcomingEvent?.category.symbolName ?? "calendar")
                .font(.caption2)
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 4) {
                Text(upcomingTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                Text(upcomingTimeText.isEmpty ? "No upcoming event" : upcomingTimeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(8)
    }

    private var inlineBody: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.upcomingEvent?.category.symbolName ?? "calendar")
                .font(.caption2)
                .widgetAccentable()
            Text(upcomingTimeText.isEmpty ? "Free" : upcomingTimeText)
                .font(.caption2.weight(.semibold))
            Text("•")
            Text(upcomingTitle)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
    }
}

/// Lưới lịch tuần cho Home Screen và StandBy.
struct WeekGridView: View {
    let entry: WeekEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("This Week")
                    .font(.headline.weight(.semibold))
                Spacer()
                Text(weekRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(entry.days) { day in
                    dayCell(day)
                }
            }

            if let upcomingEvent = entry.upcomingEvent {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next up")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(upcomingEvent.title)
                        .font(.caption)
                        .lineLimit(2)
                    Text(upcomingEvent.startDate, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            }
        }
        .padding(12)
    }

    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let weekEndDate = Calendar.current.date(byAdding: .day, value: 6, to: entry.weekStartDate) ?? entry.weekStartDate
        return "\(formatter.string(from: entry.weekStartDate)) - \(formatter.string(from: weekEndDate))"
    }

    private func dayCell(_ day: WeekDaySummary) -> some View {
        let firstEvent = day.events.first

        return VStack(alignment: .leading, spacing: 5) {
            Text(day.weekdaySymbol.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(day.dayNumber)")
                .font(.headline.weight(day.isToday ? .bold : .semibold))
                .foregroundStyle(day.isToday ? .accentColor : .primary)
            if let firstEvent {
                HStack(spacing: 4) {
                    Image(systemName: firstEvent.category.symbolName)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(eventColor(for: firstEvent))
                    Text(firstEvent.title)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            } else {
                Text("Free")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if day.events.count > 1 {
                Text("+\(day.events.count - 1) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else if !day.events.isEmpty {
                Text("1 event")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(day.isToday ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.09))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(day.isToday ? Color.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
        )
    }

    private func eventColor(for event: CalendarEvent) -> Color {
        event.category.color
    }
}

/// Adapter riêng cho widget, chọn view phù hợp theo family.
struct WidgetRootView: View {
    let entry: WeekEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockScreenSummaryView(entry: entry, style: .circular)
        case .accessoryRectangular:
            LockScreenSummaryView(entry: entry, style: .rectangular)
        case .accessoryInline:
            LockScreenSummaryView(entry: entry, style: .inline)
        case .systemLarge:
            WeekGridView(entry: entry)
        default:
            WeekGridView(entry: entry)
        }
    }
}

#Preview("Lock Screen Circular") {
    LockScreenSummaryView(entry: WeekTimelineBuilder.makeEntry(referenceDate: .now, events: SharedEventSeed.sampleEvents), style: .circular)
}

#Preview("Lock Screen Rectangular") {
    LockScreenSummaryView(entry: WeekTimelineBuilder.makeEntry(referenceDate: .now, events: SharedEventSeed.sampleEvents), style: .rectangular)
}

#Preview("Lock Screen Inline") {
    LockScreenSummaryView(entry: WeekTimelineBuilder.makeEntry(referenceDate: .now, events: SharedEventSeed.sampleEvents), style: .inline)
}

#Preview("Week Grid") {
    WeekGridView(entry: WeekTimelineBuilder.makeEntry(referenceDate: .now, events: SharedEventSeed.sampleEvents))
}

