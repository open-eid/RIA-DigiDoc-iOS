// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoObjCWrapper

/// @mockable
public protocol RecipientUtilProtocol: Sendable {
    func getRecipientCertTypeText(certType: CertType) -> String
}
