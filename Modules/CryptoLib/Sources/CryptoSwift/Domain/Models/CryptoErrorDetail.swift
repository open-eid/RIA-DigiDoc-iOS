/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
