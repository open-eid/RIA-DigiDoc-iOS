/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import NotificationCenter
import OSLog

@MainActor
public final class NotificationUtil: NSObject, NotificationUtilProtocol {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc",
        category: "NotificationUtil"
    )

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    public func requestAuthorization() async -> Bool {
        NotificationUtil.logger.debug("Requesting authorization to send notifications")
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            NotificationUtil.logger.debug("Notification sending authorized: \(granted)")
            return granted
        } catch {
            NotificationUtil.logger.debug("Unable to request authorization to send notifications. \(error)")
            return false
        }
    }

    public func sendNotification(
        title: String,
        body: String
    ) async throws -> String {
        NotificationUtil.logger.debug("Sending notification (\(title))")

        let notificationId = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: nil)

        try await UNUserNotificationCenter.current().add(request)

        NotificationUtil.logger.debug("Notification sent. ID: \(notificationId)")

        return notificationId
    }

    public func removeNotification(id: String) {
        NotificationUtil.logger.debug("Removing notification (\(id))")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
        NotificationUtil.logger.debug("Removed notification \(id)")
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
