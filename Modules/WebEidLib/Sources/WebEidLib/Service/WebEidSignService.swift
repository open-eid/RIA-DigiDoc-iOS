// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Security
import UtilsLib

public actor WebEidSignService: WebEidSignServiceProtocol, Loggable {

    init() {}

    public func buildCertificatePayload(signingCert: Data) async throws -> Data {

        guard let secCert = SecCertificateCreateWithData(nil, signingCert as CFData) else {
            throw WebEidBuilderError.invalidCertificate
        }
        guard let publicKey = SecCertificateCopyKey(secCert) else {
            throw WebEidBuilderError.missingPublicKey
        }

        let supportedSignatureAlgorithms = try WebEidAlgorithmUtil.buildSupportedSignatureAlgorithms(
            publicKey: publicKey
        )

        let payload: [String: Any] = [
            "certificate": signingCert.base64EncodedString(),
            "supportedSignatureAlgorithms": supportedSignatureAlgorithms
        ]

        guard JSONSerialization.isValidJSONObject(payload) else {
            throw WebEidBuilderError.invalidJSON
        }

        return try JSONSerialization.data(withJSONObject: payload, options: [])
    }

    public func buildSignPayload(
        signingCert: String,
        signature: Data,
        hashFunction: String
    ) async throws -> Data {

        let secCert = try WebEidAlgorithmUtil.parseCertificate(signingCertBase64: signingCert)

        guard let publicKey = SecCertificateCopyKey(secCert) else {
            throw WebEidBuilderError.missingPublicKey
        }

        let signatureAlgorithm = try WebEidAlgorithmUtil.buildSignatureAlgorithm(
            publicKey: publicKey,
            hashFunction: hashFunction
        )

        let payload: [String: Any] = [
            "signature": signature.base64EncodedString(),
            "signatureAlgorithm": signatureAlgorithm
        ]

        guard JSONSerialization.isValidJSONObject(payload) else {
            throw WebEidBuilderError.invalidJSON
        }

        return try JSONSerialization.data(withJSONObject: payload, options: [])
    }
}
