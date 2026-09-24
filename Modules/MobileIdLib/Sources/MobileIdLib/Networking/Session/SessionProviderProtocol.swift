// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire
import CommonsLib

/// @mockable
public protocol SessionProviderProtocol: Sendable {
    func ensureSession(
        url: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> Session
}
