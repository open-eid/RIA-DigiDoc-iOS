// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct RoleData: Sendable, Equatable {
    public var roles: [String]
    public var city: String
    public var state: String
    public var country: String
    public var zipCode: String

    public init(
        roles: [String],
        city: String,
        state: String,
        country: String,
        zipCode: String
    ) {
        self.roles = roles
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zipCode
    }
}
