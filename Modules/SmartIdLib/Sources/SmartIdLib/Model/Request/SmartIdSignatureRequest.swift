// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct SmartIdSignatureRequest: Sendable, Encodable, CustomStringConvertible {
    let relyingPartyName: String
    let relyingPartyUUID: String
    let hash: String
    let hashType: String
    let allowedInteractionsOrder: [AllowedInteractionsOrder]

    public var description: String {
        return """
        SmartIdSignatureRequest(
            relyingPartyName: \(relyingPartyName),
            relyingPartyUUID: \(relyingPartyUUID),
            hash: \(hash),
            hashType: \(hashType),
            allowedInteractionsOrder: \(allowedInteractionsOrder.description)
        )
        """
    }
}

public struct AllowedInteractionsOrder: Sendable, Encodable, CustomStringConvertible {
    let type: String
    let displayText200: String

    public var description: String {
        return """
        AllowedInteractionsOrder(
            type: \(type),
            displayText200: \(displayText200)
        )
        """
    }
}
