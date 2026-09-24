// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public enum MyEidDocumentStatus: Sendable {
    case valid
    case expired
    case unknown
}

extension MyEidDocumentStatus {
    var localizationKey: String {
        switch self {
        case .valid:
            return "My eid status valid"
        case .expired:
            return "My eid status expired"
        case .unknown:
            return "My eid status unknown"
        }
    }
}
