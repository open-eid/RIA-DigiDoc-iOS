// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import UniformTypeIdentifiers

public struct ImportedFileItem: Sendable {
    let fileUrl: URL
    let filename: String
    let data: Data
    let typeIdentifier: UTType
}
