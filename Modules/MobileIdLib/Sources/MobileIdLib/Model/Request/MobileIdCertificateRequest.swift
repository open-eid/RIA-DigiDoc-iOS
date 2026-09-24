// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MobileIdCertificateRequest: Sendable, Encodable, CustomStringConvertible {
    let relyingPartyName: String?
    let relyingPartyUUID: String?
    let phoneNumber: String?
    let nationalIdentityNumber: String?

    public var description: String {
        return """
        MobileIdSignatureRequest(
            relyingPartyName: \(relyingPartyName ?? "-"),
            relyingPartyUUID: \(relyingPartyUUID ?? "-"),
            phoneNumber: \(phoneNumber ?? "-"),
            nationalIdentityNumber: \(nationalIdentityNumber ?? "-")
        )
        """
    }
}
