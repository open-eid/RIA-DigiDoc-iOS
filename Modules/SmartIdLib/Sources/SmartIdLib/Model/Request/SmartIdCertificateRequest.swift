// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct SmartIdCertificateRequest: Sendable, Encodable, CustomStringConvertible {
    let relyingPartyName: String?
    let relyingPartyUUID: String?

    public var description: String {
        return """
        SmartIdSignatureRequest(
            relyingPartyName: \(relyingPartyName ?? "-"),
            relyingPartyUUID: \(relyingPartyUUID ?? "-")
        )
        """
    }
}
