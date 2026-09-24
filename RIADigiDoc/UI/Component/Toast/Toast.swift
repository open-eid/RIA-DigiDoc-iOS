// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct Toast {
    static func show(
        _ message: String,
        duration: TimeInterval = 4.0,
        type: ToastType = .error
    ) {
        if message.isEmpty { return }

        Task {
            await ToastQueue.shared.enqueue(
                message: message,
                duration: duration,
                type: type
            )
        }
    }
}
