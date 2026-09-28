import Foundation
import UserNotifications

struct NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let requestID = "playHubDailyChallenge"

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleDaily(hour: Int, minute: Int) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
        let content = UNMutableNotificationContent()
        content.title = "Your daily challenge is ready!"
        content.body = "Open PlayHub and beat your best score."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(identifier: requestID, content: content, trigger: trigger))
    }

    func cancelDaily() {
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
    }
}
