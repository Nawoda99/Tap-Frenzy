import SwiftUI
import CoreLocation

struct SettingsTab: View {
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var location: LocationService
    @AppStorage("dailyChallengeEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var challengeHour = 18
    @AppStorage("dailyChallengeMinute") private var challengeMinute = 0
    @State private var showingResetConfirmation = false
    @State private var notificationMessage: String?

    private let notifications = NotificationService()

    private var challengeTime: Binding<Date> {
        Binding {
            Calendar.current.date(from: DateComponents(hour: challengeHour, minute: challengeMinute)) ?? Date()
        } set: { date in
            let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
            challengeHour = parts.hour ?? 18
            challengeMinute = parts.minute ?? 0
            if notificationsEnabled { scheduleNotification() }
        }
    }

    var body: some View {
        Form {
            Section("Daily Challenge") {
                Toggle("Daily reminder", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        enabled ? scheduleNotification() : notifications.cancelDaily()
                    }
                DatePicker("Challenge time", selection: challengeTime, displayedComponents: .hourAndMinute)
                    .disabled(!notificationsEnabled)
                if let notificationMessage {
                    Text(notificationMessage).font(.caption).foregroundStyle(.secondary)
                }
            }

            Section("Location") {
                LabeledContent("Permission", value: locationLabel)
                Button("Request Location Access") { location.requestPermission() }
            }

            Section("Data") {
                LabeledContent("Saved games", value: "\(store.sessions.count)")
                Button("Reset All Stats", role: .destructive) { showingResetConfirmation = true }
            }

            Section("About") {
                LabeledContent("App", value: "PlayHub")
                LabeledContent("Version", value: "1.0")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Reset all game history and high scores?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset All Stats", role: .destructive) { store.reset() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var locationLabel: String {
        switch location.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: "Allowed"
        case .denied, .restricted: "Denied"
        case .notDetermined: "Not requested"
        @unknown default: "Unknown"
        }
    }

    private func scheduleNotification() {
        Task {
            let granted = await notifications.requestPermission()
            guard granted else {
                notificationsEnabled = false
                notificationMessage = "Notifications were not allowed."
                return
            }
            do {
                try await notifications.scheduleDaily(hour: challengeHour, minute: challengeMinute)
                notificationMessage = String(format: "Scheduled daily at %02d:%02d", challengeHour, challengeMinute)
            } catch {
                notificationMessage = error.localizedDescription
            }
        }
    }
}
