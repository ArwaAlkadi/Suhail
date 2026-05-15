//
//  NotificationsManager.swift
//  Desert
//
//  Created by Arwa Alkadi on 06/05/2026.
//

import Foundation
import UserNotifications
import Combine

/// Manages all local notifications for active desert trips.
///
/// ## Summary
/// - No server required — all notifications are local via `UNUserNotificationCenter`
/// - Offline notifications fire when Firebase upload fails and no network is detected
///
/// ## Responsibilities
/// 1. Requesting notification permission from the user
/// 2. Scheduling safety reminders based on trip return time
/// 3. Scheduling emergency notifications when device has no network
/// 4. Cancelling all notifications when a trip ends or network is restored
/// 5. Showing notifications even when the app is in the foreground
///
/// ## Usage
/// ```swift
/// // 1. Request permission during onboarding
/// NotificationsManager.shared.requestPermission()
///
/// // 2. Schedule offline notifications when network is lost
/// NotificationsManager.shared.scheduleOfflineNotifications(returnTime: trip.returnTime)
///
/// // 3. Cancel all when trip ends or network is restored
/// NotificationsManager.shared.cancelAllNotifications()
/// ```
///
/// - Important: Always call ``requestPermission()`` during onboarding before
///   scheduling any notifications.
class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    /// Shared singleton — use this throughout the app.
    static let shared = NotificationsManager()
    
    /// Whether the user has granted notification permission.
    ///
    /// Observe this to update the UI if notifications are denied.
    @Published var isAuthorized: Bool = false
    
    override init() {
        super.init()
        // set delegate so notifications show while app is open
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Request Permission
    /// Requests notification permission from the user.
    ///
    /// Asks for `.alert` and `.sound` permissions.
    /// Updates ``isAuthorized`` on the main thread when the user responds.
    ///
    /// - Note: Call this once during onboarding. The system dialog only
    ///   appears once — subsequent calls are ignored by iOS.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                print("Notifications authorized: \(granted)")
            }
        }
    }
    
    // MARK: - Foreground Presentation
    /// Allows notifications to appear while the app is in the foreground.
    ///
    /// Without this delegate method, `UNUserNotificationCenter` suppresses
    /// all notifications when the app is active. This override ensures
    /// banners and sounds play regardless of app state.
    ///
    /// - Parameters:
    ///   - center: The notification center handling the notification.
    ///   - notification: The notification about to be presented.
    ///   - completionHandler: Call with the desired presentation options.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    // MARK: - Schedule Offline Notifications
    /// Schedules a series of safety reminder notifications when the device has no network.
    ///
    /// Called when a Firebase location upload fails due to no connectivity,
    /// and the trip's return time has already passed. Fires three escalating
    /// reminders at 5 minutes, 30 minutes, and 60 minutes from now.
    ///
    /// Cancels any previously scheduled notifications before scheduling new ones
    /// to avoid duplicates.
    ///
    /// - Parameter returnTime: The expected return time of the active trip.
    ///   Notifications are only scheduled if the current time has passed this value.
    ///
    /// - Note: If the return time has not yet passed, this method exits early
    ///   and no notifications are scheduled.
    ///
    /// ## Notification Schedule
    /// | Delay | Title | Purpose |
    /// | ----- | ----- | ------- |
    /// | 5 min | No Signal Detected | Initial alert |
    /// | 30 min | Safety Reminder | Encourage staying near vehicle |
    /// | 60 min | Stay With Your Vehicle | Critical safety guidance |
    func scheduleOfflineNotifications(returnTime: Date) {
        cancelAllNotifications()
        
        let now = Date()
        
        guard now >= returnTime else {
            print("Return time not reached — offline notifications skipped")
            return
        }
        
        let notifications: [(title: String, body: String, delay: TimeInterval)] = [
            (
                title: "No Signal Detected",
                body: "You appear to be out of range. Stay near your vehicle.",
                delay: 60 * 5
            ),
            (
                title: "Safety Reminder",
                body: "Stay calm and remain visible. Help is easier to find near your vehicle.",
                delay: 60 * 30
            ),
            (
                title: "Stay With Your Vehicle",
                body: "Do not wander. Rescuers search along known routes first.",
                delay: 60 * 60
            )
        ]
        
        for notification in notifications {
            let fireDate = now.addingTimeInterval(notification.delay)
            scheduleNotification(
                title: notification.title,
                body: notification.body,
                date: fireDate
            )
        }
        
        print("Offline emergency notifications scheduled")
    }
    
    // MARK: - Cancel All Notifications
    /// Cancels all pending local notifications.
    ///
    /// Called when:
    /// - The trip ends normally — user taps "I'm Back Safely"
    /// - Network connectivity is restored and Firebase upload succeeds
    ///
    /// - Note: This only cancels **pending** notifications.
    ///   Notifications already delivered to the notification center are not removed.
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    // MARK: - Schedule Single Notification
    /// Schedules a single local notification at a specific date and time.
    ///
    /// Internal helper used by ``scheduleOfflineNotifications(returnTime:)``.
    /// Creates a `UNCalendarNotificationTrigger` from the given date and
    /// registers it with `UNUserNotificationCenter`.
    ///
    /// Each notification is assigned a unique `UUID` identifier so multiple
    /// notifications can coexist without overwriting each other.
    ///
    /// - Parameters:
    ///   - title: The notification title shown in bold.
    ///   - body: The notification body shown below the title.
    ///   - date: The exact date and time to fire the notification.
    private func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
