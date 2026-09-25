// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol NameUtilProtocol: Sendable {
    func formatName(_ components: [String]) -> String
    func formatName(_ name: String) -> String
    func formatName(surname: String?, givenName: String?, identifier: String?) -> String
    func formatCompanyName(identifier: String?, serialNumber: String?) -> String
}
