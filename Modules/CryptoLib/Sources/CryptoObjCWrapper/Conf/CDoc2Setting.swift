// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import ConfigLib
import UtilsLib

public final class CDoc2Setting: NSObject, Sendable, Loggable {
    @objc @MainActor static public var isEncryptionEnabled: Bool = Constants.CryptoDefaultValues.encryptionUseCdoc2

    @MainActor
    public static func setEncryptionEnabled(_ val: Bool) {
       Self.isEncryptionEnabled = val
    }
}
