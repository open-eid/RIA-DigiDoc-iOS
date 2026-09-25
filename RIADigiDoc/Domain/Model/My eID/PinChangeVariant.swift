// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

enum PinChangeVariant: Sendable, Identifiable {
    case pin1Change
    case pin1Unblock
    case pin2Change
    case pin2Unblock
    case pukChange

    var id: String { String(describing: self) }
}
