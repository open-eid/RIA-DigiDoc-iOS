// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct CertificateExtensionData: Sendable {
    let id: UUID = UUID()
    let name: String
    let oid: String
    let critical: Bool
    let values: String
}
