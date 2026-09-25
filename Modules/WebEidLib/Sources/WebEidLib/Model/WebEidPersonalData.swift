// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

// MARK: - WebEidPersonalData

public struct WebEidPersonalData: JSONCodable, Equatable, Sendable {

    public let givenNames: String
    public let surname: String
    public let personalCode: String

    enum CodingKeys: String, CodingKey {
        case givenNames
        case surname
        case personalCode
    }
}
