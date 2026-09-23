import Foundation
import EventKit

/// Trình đồng bộ và đọc sự kiện từ Lịch iPhone (iCloud, Google Calendar, Outlook...)
@MainActor
final class DeviceCalendarSyncManager: ObservableObject {
    static let shared = DeviceCalendarSyncManager()

    private let eventStore = EKEventStore()

    @Published var isAuthorized: Bool = false
    @Published var isFetching: Bool = false
    @Published var lastErrorMessage: String?

    init() {
        checkCurrentAuthorization()
    }

    /// Kiểm tra quyền truy cập hiện tại
    func checkCurrentAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            isAuthorized = (status.rawValue == 3 || status == .fullAccess || status == .authorized)
        } else {
            isAuthorized = (status == .authorized)
        }
    }

    /// Xin quyền truy cập lịch máy
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                self.isAuthorized = granted
                return granted
            } catch {
                self.lastErrorMessage = error.localizedDescription
                self.isAuthorized = false
                return false
            }
        } else {
            let granted: Bool = await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
            self.isAuthorized = granted
            return granted
        }
    }

    /// Đọc toàn bộ sự kiện trong tuần được chọn từ Lịch iPhone
    func fetchEvents(for weekDays: [Date]) async -> [CalendarEvent] {
        guard !weekDays.isEmpty else { return [] }
        isFetching = true
        defer { isFetching = false }

        let calendar = Calendar.current
        guard let firstDay = weekDays.first, let lastDay = weekDays.last else { return [] }

        let start = calendar.startOfDay(for: firstDay)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDay)) ?? lastDay

        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)

        var results: [CalendarEvent] = []

        for ek in ekEvents {
            let title = (ek.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                ? ek.title!
                : "Sự kiện lịch"

            let event = CalendarEvent(
                id: UUID(),
                title: title,
                startDate: ek.startDate,
                endDate: ek.endDate,
                category: inferCategory(from: title),
                isAllDay: ek.isAllDay,
                isRecurringWeekly: false,
                recurrenceEndDate: nil,
                hasReminder: ek.hasAlarms
            )
            results.append(event)
        }

        return results.sorted { $0.startDate < $1.startDate }
    }

    /// Dự đoán danh mục màu sắc thông minh dựa trên từ khóa trong tên sự kiện
    private func inferCategory(from text: String) -> EventCategory {
        let lower = text.lowercased()
        if containsAny(lower, ["họp", "meeting", "làm", "work", "kpi", "báo cáo", "dự án", "deadline", "công ty", "task", "code", "khách", "call", "phỏng vấn"]) {
            return .work
        }
        if containsAny(lower, ["gym", "chạy", "bơi", "yoga", "khám", "thuốc", "thể dục", "relax", "spa", "đi dạo", "bác sĩ", "workout", "fitness"]) {
            return .health
        }
        if containsAny(lower, ["học", "study", "thi", "đọc sách", "lớp", "tiếng anh", "ôn", "bài tập", "lecture", "khóa học", "exam", "course"]) {
            return .study
        }
        if containsAny(lower, ["gia đình", "mẹ", "bố", "con", "chợ", "siêu thị", "nấu", "family", "vợ", "chồng", "nhà", "dọn dẹp", "đón"]) {
            return .family
        }
        if containsAny(lower, ["cafe", "cà phê", "bạn", "phim", "du lịch", "mua sắm", "shopee", "chill", "ăn trưa", "ăn tối", "quán", "nhậu", "party", "sinh nhật"]) {
            return .personal
        }
        return .other
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        for kw in keywords where text.contains(kw) {
            return true
        }
        return false
    }
}
