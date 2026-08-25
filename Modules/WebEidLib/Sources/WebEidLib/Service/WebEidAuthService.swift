/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import Security
import UtilsLib

public actor WebEidAuthService: WebEidAuthServiceProtocol, Loggable {

    init() {}

    public func buildAuthToken(
        authCert: Data,
        signingCert: Data?,
        signature: Data
    ) throws -> Data {
        guard let secCert = SecCertificateCreateWithData(nil, authCert as CFData) else {
            throw WebEidBuilderError.invalidCertificate
        }
        guard let publicKey = SecCertificateCopyKey(secCert) else {
            throw WebEidBuilderError.missingPublicKey
        }

        let algorithm = try WebEidAlgorithmUtil.getAlgorithm(publicKey: publicKey)

        var token: [String: Any] = [
            "algorithm": algorithm,
            "unverifiedCertificate": authCert.base64EncodedString(),
            // TODO: hardcoded? NB! clarify with RIA
            "issuerApp": "https://web-eid.eu/web-eid-mobile-app/releases/v1.0.0",
            "signature": signature.base64EncodedString()
        ]

        if let signingCert {
            guard let signingSecCert = SecCertificateCreateWithData(nil, signingCert as CFData) else {
                throw WebEidBuilderError.invalidCertificate
            }
            guard let signingPublicKey = SecCertificateCopyKey(signingSecCert) else {
                throw WebEidBuilderError.missingPublicKey
            }

            let supportedSignatureAlgorithms = try WebEidAlgorithmUtil
                .buildSupportedSignatureAlgorithms(publicKey: signingPublicKey)

            let signingCertificates: [[String: Any]] = [
                [
                    "certificate": signingCert.base64EncodedString(),
                    "supportedSignatureAlgorithms": supportedSignatureAlgorithms
                ]
            ]

            token["unverifiedSigningCertificates"] = signingCertificates
            token["format"] = "web-eid:1.1"
        } else {
            token["format"] = "web-eid:1.0"
        }

        guard JSONSerialization.isValidJSONObject(token) else {
            throw WebEidBuilderError.invalidJSON
        }

        return try JSONSerialization.data(withJSONObject: token, options: [])
    }
}
