// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol SignatureUtilProtocol: Sendable {
    func getSignatureStatusText(status: SignatureStatus, isTimestamp: Bool) -> String
}
