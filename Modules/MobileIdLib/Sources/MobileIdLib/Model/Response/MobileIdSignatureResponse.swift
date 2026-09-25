// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MobileIdSignatureResponse: Sendable, Decodable, CustomStringConvertible {
    public let sessionID: String?

    public var description: String {
        return """
        MobileIdSignatureResponse(
            sessionId: \(sessionID ?? "-")
        )
        """
    }

    public init(sessionID: String?) {
        self.sessionID = sessionID
    }
}
