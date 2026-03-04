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
import Security
import ASN1Decoder
import UtilsLib

struct WebEidRequestParser: Loggable {

    private static let minChallengeLength = 44
    private static let maxChallengeLength = 128
    private static let maxOriginLength = 255

    // MARK: Public API

    static func parseAuthURL(_ authURL: URL) throws -> WebEidAuthRequest {
        let request = try decodeURLFragment(authURL)

        let challenge = (request["challenge"] as? String) ?? ""
        let loginUriString = (request["loginUri"] as? String) ?? ""
        let responseURL = try validateResponseURL(loginUriString)

        if challenge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            challenge.count < minChallengeLength ||
            challenge.count > maxChallengeLength {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid challenge length",
                responseUri: responseURL.absoluteString
            )
        }

        let getSigningCertificate = (request["getSigningCertificate"] as? Bool) ?? false

        return WebEidAuthRequest(
            challenge: challenge,
            loginUri: responseURL.absoluteString,
            getSigningCertificate: getSigningCertificate,
            origin: try parseOrigin(responseURL)
        )
    }

    static func parseCertificateURL(_ url: URL) throws -> WebEidCertificateRequest {
        let request = try decodeURLFragment(url)
        let responseUriString = (request["responseUri"] as? String) ?? ""
        let responseURL = try validateResponseURL(responseUriString)

        return WebEidCertificateRequest(
            responseUri: responseURL.absoluteString,
            origin: try parseOrigin(responseURL)
        )
    }

    static func parseSignURL(_ url: URL) throws -> WebEidSignRequest {
        let request = try decodeURLFragment(url)
        let responseUriString = (request["responseUri"] as? String) ?? ""
        let responseURL = try validateResponseURL(responseUriString)

        let hash = ((request["hash"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let hashFunction = ((request["hashFunction"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if hash.isEmpty || hashFunction.isEmpty {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid signing request: missing hash or hashFunction",
                responseUri: responseURL.absoluteString
            )
        }

        _ = try validateAndDecodeHash(
            hashBase64: hash,
            hashFunction: hashFunction,
            responseUri: responseURL.absoluteString
        )

        let signingCertificateB64 = ((request["signingCertificate"] as? String) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if signingCertificateB64.isEmpty {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid signing request: missing signingCertificate",
                responseUri: responseURL.absoluteString
            )
        }

        guard let certDER = WebEidAlgorithmUtil.base64DecodeFlexible(signingCertificateB64),
              let cert = WebEidAlgorithmUtil.certificate(from: certDER) else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid signingCertificate encoding",
                responseUri: responseURL.absoluteString
            )
        }

        // Use ASN1Decoder to extract CN
        guard let personalData = try? extractPersonalData(from: certDER) else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Failed to extract personal data from certificate",
                responseUri: responseURL.absoluteString
            )
        }
        return WebEidSignRequest(
            responseUri: responseURL.absoluteString,
            origin: try parseOrigin(responseURL),
            signingCertificate: cert,
            hash: hash,
            hashFunction: hashFunction,
            personalData: personalData
        )
    }

    // MARK: - Validation / Decoding

    private static func validateResponseURL(_ responseUri: String) throws -> URL {
        guard let components = URLComponents(string: responseUri) else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid response URI",
                responseUri: responseUri
            )
        }

        guard let scheme = components.scheme, !scheme.isEmpty else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid response URI scheme",
                responseUri: responseUri
            )
        }

        guard scheme.lowercased() == "https" else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Response URI must use HTTPS scheme",
                responseUri: responseUri
            )
        }

        guard let host = components.host, !host.isEmpty else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid response URI host",
                responseUri: responseUri
            )
        }

        if components.user != nil || components.password != nil {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Response URI must not contain userinfo",
                responseUri: responseUri
            )
        }

        guard let url = components.url else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid response URI",
                responseUri: responseUri
            )
        }

        return url
    }

    private static func decodeURLFragment(_ url: URL) throws -> [String: Any] {
        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment,
              !fragment.isEmpty else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Missing URI fragment",
                responseUri: url.absoluteString
            )
        }

        guard let decoded = WebEidAlgorithmUtil.base64DecodeFlexible(fragment) else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid URI fragment",
                responseUri: url.absoluteString
            )
        }

        do {
            let obj = try JSONSerialization.jsonObject(with: decoded, options: [])
            guard let dict = obj as? [String: Any] else {
                throw WebEidException(
                    code: .errWebEidMobileInvalidRequest,
                    message: "Invalid URI fragment JSON",
                    responseUri: url.absoluteString
                )
            }
            return dict
        } catch {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid URI fragment",
                responseUri: url.absoluteString
            )
        }
    }

    private static func parseOrigin(_ url: URL) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              let host = components.host else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid origin",
                responseUri: url.absoluteString
            )
        }

        let portPart = components.port.map { ":\($0)" } ?? ""
        let origin = "\(scheme)://\(host)\(portPart)"

        if origin.count > maxOriginLength {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid origin length",
                responseUri: url.absoluteString
            )
        }
        return origin
    }

    private static func validateAndDecodeHash(
        hashBase64: String,
        hashFunction: String,
        responseUri: String
    ) throws -> Data {
        guard let hashBytes = WebEidAlgorithmUtil.base64DecodeFlexible(hashBase64) else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Invalid hash encoding",
                responseUri: responseUri
            )
        }

        if hashFunction.count > 8 {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "hashFunction value is invalid",
                responseUri: responseUri
            )
        }

        let expectedLength: Int
        switch hashFunction.uppercased() {
        case "SHA-224", "SHA3-224": expectedLength = 28
        case "SHA-256", "SHA3-256": expectedLength = 32
        case "SHA-384", "SHA3-384": expectedLength = 48
        case "SHA-512", "SHA3-512": expectedLength = 64
        default:
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Unsupported hashFunction: \(hashFunction)",
                responseUri: responseUri
            )
        }

        if hashBytes.count != expectedLength {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "\(hashFunction) hash must be \(expectedLength) bytes long, but is \(hashBytes.count)",
                responseUri: responseUri
            )
        }

        return hashBytes
    }

    // MARK: - Personal Data Extraction using (SwiftASN1/X509)
    
    private static func getSubjectAttribute(cert: Data, oidString: String) -> String {
        do {
            let x509 = try X509Certificate(data: cert)
            return x509.subject(oidString: oidString)?.first ?? ""
        } catch {
            logger().error(
                "Unable to get subject attribute from certificate: \(String(reflecting: error))"
            )
            return ""
        }
    }
    
    private static func extractPersonalData(from certDER: Data) throws -> WebEidPersonalData {
        let commonName = "2.5.4.3" // CN OID: 2.5.4.3
        let cn = getSubjectAttribute(cert: certDER, oidString: commonName)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cn.isEmpty else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Signing certificate CN missing",
                responseUri: ""
            )
        }

        let normalizedCN = cn
            .replacing("\\,", with: ",")
            .replacing("\\ ", with: " ")

        let parts = normalizedCN
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard parts.count >= 3 else {
            throw WebEidException(
                code: .errWebEidMobileInvalidRequest,
                message: "Unexpected signing certificate CN format: \(normalizedCN)",
                responseUri: ""
            )
        }

        return WebEidPersonalData(
            givenNames: parts[1],
            surname: parts[0],
            personalCode: parts[2]
        )
    }
}
