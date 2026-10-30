// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import CryptoObjCWrapper

struct RecipientUtil: RecipientUtilProtocol {
    func getRecipientCertTypeText(certType: CertType) -> String {
        switch certType {
            case .unknownType:
                return "Unknown"
            case .iDCardType:
                return "ID-card"
            case .digiIDType:
                return "Digi-ID"
            case .eResidentType:
                return "E-Resident"
            case .mobileIDType:
                return "Mobile-ID"
            case .smartIDType:
                return "Smart-ID"
            case .eSealType:
                return "Certificate for Encryption"
            case .passwordType:
                return "Password"
            }
    }

    private func isSameRecipient(_ recipient: Addressee, _ other: Addressee) -> Bool {
        recipient.data == other.data
    }

    func isRecipientAdded(_ recipient: Addressee, in addedRecipients: [Addressee]) -> Bool {
        addedRecipients.contains { isSameRecipient($0, recipient) }
    }
}
