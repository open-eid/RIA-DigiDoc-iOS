// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoKit

/// @mockable
public protocol EncryptedDataUtilProtocol: Sendable {
    func getSymmetricKey(fileName: String) throws -> SymmetricKey
    func decryptSecret(_ data: Data, with symmetricKey: SymmetricKey) -> String?
}
