// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoKit

extension Digest {
    public func hexString(separator: String = " ") -> String {
        self.map { String(format: "%02X", $0) }.joined(separator: separator)
    }
}
