// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

enum MyEidPinCodeChangeError: Error, Sendable, Equatable {
    case invalidCurrentCode(remainingRetries: Int)
    case blocked
}
