// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Security
import UtilsLib

public actor WebEidAuthService: WebEidAuthServiceProtocol, Loggable {

    private let appVersionUrl: String

    init(appVersion: String = BundleUtil.getBundleShortVersionString()) {
        appVersionUrl = "https://id.eesti.ee/releases/v\(appVersion)"
    }

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
            "issuerApp": appVersionUrl,
            "appVersion": appVersionUrl,
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
