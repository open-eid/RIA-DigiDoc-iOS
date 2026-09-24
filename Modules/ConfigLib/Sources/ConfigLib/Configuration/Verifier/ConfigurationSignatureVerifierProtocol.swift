// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol ConfigurationSignatureVerifierProtocol: Sendable {
    func verifyConfigurationSignature(config: String, publicKey: String, signature: String) throws
}
