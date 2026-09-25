// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct PinResponse: Sendable, Hashable {
    let pin1RetryCount: UInt8
    let pin1Active: Bool
    let pin2RetryCount: UInt8
    let pin2Active: Bool
    let pukRetryCount: UInt8
    let pukActive: Bool
}

extension PinResponse {
    var isCourierCard: Bool {
        !pin1Active
    }
}
