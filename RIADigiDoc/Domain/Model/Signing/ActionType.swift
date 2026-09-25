// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum ActionType: Sendable {
    case signing
    case myeid
    case decrypt
    case auth
    case certificate
    case signingWebEid

    var isWebEidFlow: Bool {
        self == .auth || self == .certificate || self == .signingWebEid
    }
}
