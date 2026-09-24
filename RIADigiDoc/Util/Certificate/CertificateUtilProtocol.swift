// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import SwiftASN1

/// @mockable
public protocol CertificateUtilProtocol: Sendable {
    func pemToDerData(fromPEM pem: Data) -> Data?
    func certificate(from data: Data) -> SecCertificate?
    func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getNotValidAfterWithExpiredLabel(cert: Data, expiredLabel: String) -> String
    func getNotValidDate(_ certData: Data?) throws -> String?
    func getNotValidAfterDate(cert: Data) -> Date?
}
