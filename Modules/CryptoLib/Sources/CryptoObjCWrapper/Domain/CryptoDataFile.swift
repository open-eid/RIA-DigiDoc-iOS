// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public final class CryptoDataFile: NSObject, Sendable {
    @objc public let filename: String
    @objc public let filePath: String?

    public init(filename: String, filePath: String? = nil) {
        self.filename = filename
        self.filePath = filePath
    }
}
