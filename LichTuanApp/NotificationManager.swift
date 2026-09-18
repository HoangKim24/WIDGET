import Foundation
import UserNotifications

/// Quản lý thông báo chuông và rung nội bộ của iPhone (Local Notifications).
/// Hoạt động 100% offline, không cần server.
@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false

    private init() {
        checkAuthorization()
    }

    /// Kiểm tra trạng thái cấp quyền thông báo
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }

    /// Yêu cầu người dùng cấp quyền thông báo lần đầu
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                completion?(granted)
            }
        }
    }

    /// Lên lịch thông báo chuông cho một sự kiện (báo trước 15 phút hoặc đúng giờ)
    func scheduleNotification(for event: CalendarEvent, minutesBefore: Int = 15) {
        guard event.hasReminder else { return }

        // Tính thời điểm rung chuông
        let triggerDate = event.startDate.addingTimeInterval(-Double(minutesBefore * 60))
        guard triggerDate > Date() else {
            // Nếu đã quá giờ thông báo trước 15 phút thì thử báo đúng giờ
            if event.startDate > Date() {
                scheduleExactNotification(for: event)
            }
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🔔 Lịch Trình: \(event.title)"
        content.body = "Sắp diễn ra lúc \(formatTime(event.startDate)) (sau \(minutesBefore) phút)"
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: event.isRecurringWeekly)

        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Lên lịch thông báo đúng giờ bắt đầu
    private func scheduleExactNotification(for event: CalendarEvent) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Đến Giờ: \(event.title)"
        content.body = "Khung giờ: \(formatTime(event.startDate)) – \(formatTime(event.endDate))"
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: event.startDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: event.isRecurringWeekly)

        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Hủy thông báo khi xóa sự kiện
    func cancelNotification(for eventID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventID.uuidString])
    }

    /// Hủy toàn bộ thông báo khi xóa toàn bộ lịch
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
