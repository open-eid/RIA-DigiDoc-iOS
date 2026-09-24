// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import NotificationCenter

@MainActor
public final class NotificationUtil: NSObject, NotificationUtilProtocol, Loggable {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    public func requestAuthorization() async -> Bool {
        NotificationUtil.logger().info("Requesting authorization to send notifications")
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            NotificationUtil.logger().info("Notification sending authorized: \(granted)")
            return granted
        } catch {
            NotificationUtil.logger().info("Unable to request authorization to send notifications. \(error)")
            return false
        }
    }

    public func sendNotification(
        title: String,
        body: String
    ) async throws -> String {
        NotificationUtil.logger().info("Sending notification (\(title))")

        let notificationId = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: nil)

        try await UNUserNotificationCenter.current().add(request)

        NotificationUtil.logger().info("Notification sent. ID: \(notificationId)")

        return notificationId
    }

    public func removeNotification(id: String) {
        guard !id.isEmpty else { return }
        NotificationUtil.logger().info("Removing notification (\(id))")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
        NotificationUtil.logger().info("Removed notification \(id)")
    }
}

extension NotificationUtil: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async
    -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        removeNotification(id: response.notification.request.identifier)
    }
}
