/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import SwiftASN1

/// @mockable
@MainActor
public protocol CertificateDetailViewModelProtocol: Sendable {
    func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getIssuerAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getSerialNumber(cert: Data) -> String
    func getVersion(cert: Data) -> String
    func getSignatureAlgorithm(cert: Data) -> String
    func getNotValidBefore(cert: Data) -> String
    func getNotValidAfter(cert: Data) -> String
    func getPublicKeyAlgorithm(cert: Data) -> String
    func getPublicKeyHexString(cert: Data) -> String
    func getKeyUsage(cert: Data) -> String
    func getSignature(cert: Data) -> String
    func getExtensions(cert: Data) -> [CertificateExtensionData]
    func getSHA256Fingerprint(cert: Data) -> String
    func getSHA1Fingerprint(cert: Data) -> String
}
