// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import LibdigidocLibSwift

struct SignatureUtil: SignatureUtilProtocol {
    func getSignatureStatusText(status: SignatureStatus, isTimestamp: Bool) -> String {
        switch status {
            case .valid:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid"
            case .warning:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid with warnings"
            case .nonQSCD:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid non qscd"
            case .invalid:
                return isTimestamp ? "Timestamp is invalid" : "Signature is invalid"
            case .unknown:
                return isTimestamp ? "Timestamp is unknown" : "Signature is unknown"
            }
    }
}
