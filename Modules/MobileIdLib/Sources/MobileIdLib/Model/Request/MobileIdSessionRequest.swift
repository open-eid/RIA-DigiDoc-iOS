// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MobileIdSessionRequest: Sendable, Encodable, CustomStringConvertible {
    let sessionID: String?
    let timeoutMs: Int?

    public var description: String {
        return """
        MobileIdSessionRequest(
            sessionID: \(sessionID ?? "-"),
            timeoutMs: \(String(timeoutMs ?? 0))
        )
        """
    }
}
