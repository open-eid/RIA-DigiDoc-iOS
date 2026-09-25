// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import NotificationCenter

/// @mockable
@MainActor
public protocol NotificationUtilProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func sendNotification(
        title: String,
        body: String
    ) async throws -> String
    func removeNotification(id: String)
}
