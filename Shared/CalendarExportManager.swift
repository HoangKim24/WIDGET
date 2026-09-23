import UIKit
import SwiftUI

/// Trình xuất file lịch chuẩn quốc tế (.ics) và sao lưu dữ liệu (.json)
enum CalendarExportManager {

    /// Tạo chuỗi định dạng iCalendar RFC 5545 (.ics) từ danh sách sự kiện
    static func generateICS(from events: [CalendarEvent]) -> String {
        var lines: [String] = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:-//HoangKim24//LichTuanApp//VI",
            "CALSCALE:GREGORIAN",
            "METHOD:PUBLISH",
            "X-WR-CALNAME:Lịch Tuần"
        ]

        let icsDateFormatter = DateFormatter()
        icsDateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        icsDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let icsDayFormatter = DateFormatter()
        icsDayFormatter.dateFormat = "yyyyMMdd"
        icsDayFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let nowStr = icsDateFormatter.string(from: Date())

        for ev in events {
            lines.append("BEGIN:VEVENT")
            lines.append("UID:\(ev.id.uuidString)")
            lines.append("DTSTAMP:\(nowStr)")

            if ev.isAllDay {
                lines.append("DTSTART;VALUE=DATE:\(icsDayFormatter.string(from: ev.startDate))")
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: ev.endDate) ?? ev.endDate
                lines.append("DTEND;VALUE=DATE:\(icsDayFormatter.string(from: nextDay))")
            } else {
                lines.append("DTSTART:\(icsDateFormatter.string(from: ev.startDate))")
                lines.append("DTEND:\(icsDateFormatter.string(from: ev.endDate))")
            }

            let escapedSummary = escapeICS(ev.title)
            lines.append("SUMMARY:\(escapedSummary)")
            lines.append("DESCRIPTION:Danh mục: \(ev.category.title)")

            if ev.isRecurringWeekly {
                if let recurrenceEnd = ev.recurrenceEndDate {
                    let untilStr = icsDayFormatter.string(from: recurrenceEnd)
                    lines.append("RRULE:FREQ=WEEKLY;UNTIL=\(untilStr)T235959Z")
                } else {
                    lines.append("RRULE:FREQ=WEEKLY")
                }
            }

            lines.append("END:VEVENT")
        }

        lines.append("END:VCALENDAR")
        return lines.joined(separator: "\r\n")
    }

    /// Tạo file tạm .ics và trả về URL để kích hoạt bảng chia sẻ
    static func createTempICSFile(from events: [CalendarEvent]) -> URL? {
        let icsContent = generateICS(from: events)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("LichTuan.ics")

        do {
            try icsContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    /// Tạo file sao lưu dữ liệu toàn vẹn dạng .json
    static func createTempBackupJSONFile(from events: [CalendarEvent]) -> URL? {
        do {
            let jsonString = try EventCoding.jsonString(from: events)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("LichTuan_Backup.json")
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    /// Kích hoạt bảng chia sẻ hệ thống iOS (Share Sheet)
    @MainActor
    static func presentShareSheet(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Hỗ trợ iPad popover
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topController.present(activityVC, animated: true)
    }

    private static func escapeICS(_ text: String) -> String {
        var s = text
        s = s.replacingOccurrences(of: "\\", with: "\\\\")
        s = s.replacingOccurrences(of: ";", with: "\\;")
        s = s.replacingOccurrences(of: ",", with: "\\,")
        s = s.replacingOccurrences(of: "\n", with: "\\n")
        return s
    }
}
