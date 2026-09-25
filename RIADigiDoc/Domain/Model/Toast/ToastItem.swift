// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

struct ToastItem: Sendable {
    let message: String
    let duration: TimeInterval
    let type: ToastType
}
