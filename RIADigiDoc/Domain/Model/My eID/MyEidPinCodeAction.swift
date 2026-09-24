// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

public enum MyEidPinCodeAction: Sendable, Codable {
    case change
    case unblock

    func steps() -> [MyEidPinCodeStep] {
        switch self {
        case .change:
            return [.current, .new, .confirm]

        case .unblock:
            return [.current, .new, .confirm]
        }
    }
}
