// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct CryptoErrorDetail: Sendable {
    public let message: String
    public let code: Int
    public let userInfo: [String: String]

    public init(message: String = "", code: Int = 0, userInfo: [String: String] = [:]) {
        self.message = message
        self.code = code
        self.userInfo = userInfo
    }

    public var description: String {
        return """
            Error: \(self.message)
            Code: \(self.code)
            Info: \(self.userInfo)
        """
    }

    private static func convertUserInfoToStringDictionary(_ userInfo: [String: Any]) -> [String: String] {
        userInfo.mapValues { value in
            String(describing: value)
        }
    }
}
