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

        submitNotification(
            identifier: event.id.uuidString,
            title: "🔔 Lịch Trình: \(event.title)",
            body: "Sắp diễn ra lúc \(event.startDate.timeString) (sau \(minutesBefore) phút)",
            triggerDate: triggerDate,
            repeatsWeekly: event.isRecurringWeekly
        )
    }

    /// Lên lịch thông báo đúng giờ bắt đầu
    private func scheduleExactNotification(for event: CalendarEvent) {
        submitNotification(
            identifier: event.id.uuidString,
            title: "🔔 Đến Giờ: \(event.title)",
            body: "Khung giờ: \(event.startDate.timeString) – \(event.endDate.timeString)",
            triggerDate: event.startDate,
            repeatsWeekly: event.isRecurringWeekly
        )
    }

    /// Chuẩn hóa tạo và đăng ký UNNotificationRequest với hệ thống iOS
    private func submitNotification(
        identifier: String,
        title: String,
        body: String,
        triggerDate: Date,
        repeatsWeekly: Bool
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components: Set<Calendar.Component> = repeatsWeekly ? [.weekday, .hour, .minute] : [.year, .month, .day, .hour, .minute]
        let triggerComponents = Calendar.current.dateComponents(components, from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: repeatsWeekly)

        let request = UNNotificationRequest(
            identifier: identifier,
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
}
