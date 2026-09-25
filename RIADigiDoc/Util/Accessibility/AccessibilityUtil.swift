// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UIKit

class AccessibilityUtil {
    public static func announceMessage(_ message: String) {
        if UIAccessibility.isVoiceOverRunning {
            var announcement = AttributedString(message)
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}
