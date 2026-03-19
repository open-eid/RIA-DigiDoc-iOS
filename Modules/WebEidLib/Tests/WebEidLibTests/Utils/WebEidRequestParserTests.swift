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
import Testing
import Security
import CommonsLib
import CommonsTestShared
import UtilsLib

@testable import WebEidLib

struct WebEidRequestParserTests {

    // swiftlint:disable line_length
    private let eccCertBase64 = "MIID7DCCA02gAwIBAgIQK33iqGajpAnSrLD7w+X3TjAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OVoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATYWYk4C8W5+RAMeuvIQVa0sVdobkxXKASvA4lUh5K/whRAT5f3p8n2rw8O3nsCt/1LFyKXVVrZdtWZ1Vh894TA2QHEm6xaXnJs4ZmYo4blrm/nXE1PcEZan9023+73sE+jggGrMIIBpzAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MEgGA1UdIARBMD8wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAkGBwQAi+xAAQIwgYoGCCsGAQUFBwEDBH4wfDAIBgYEAI5GAQEwCAYGBACORgEEMBMGBgQAjkYBBjAJBgcEAI5GAQYBMFEGBgQAjkYBBTBHMEUWP2h0dHBzOi8vc2suZWUvZW4vcmVwb3NpdG9yeS9jb25kaXRpb25zLWZvci11c2Utb2YtY2VydGlmaWNhdGVzLxMCZW4wHQYDVR0OBBYEFFh+R2KDfE2Tdj///kXTCqcz6rRuMA4GA1UdDwEB/wQEAwIGQDAKBggqhkjOPQQDBAOBjAAwgYgCQgD7B3WI1xpXX94+9e3TdaIcUNCj5JkCX15pj1mjRqv/Vx9Hlg3tbgwW2yOhqnTF04+e9rVHCtA8YRINp5BfDFqj/wJCAVuUlCu7GNVSFeU7A6lEORkB6obIALZusUFxT4bsaFWTpKllmvlX6lZm3QEbHgeiD8k7VMPdcw5V51p+B+2WUWBh"
    // swiftlint:enable line_length

    // MARK: - Auth

    @Test
    func parseAuthURL_returnsAuthRequest_whenValid() throws {
        let challenge = String(repeating: "A", count: 44)
        let loginUri = "https://example.com/login"
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": loginUri,
                "getSigningCertificate": true
            ]
        )

        let result = try WebEidRequestParser.parseAuthURL(authURL)

        #expect(result.challenge == challenge)
        #expect(result.loginUri == loginUri)
        #expect(result.getSigningCertificate == true)
        #expect(result.origin == "https://example.com")
    }

    @Test
    func parseAuthURL_returnsFalseForGetSigningCertificate_whenMissing() throws {
        let challenge = String(repeating: "B", count: 44)
        let loginUri = "https://example.com/login"
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": loginUri
            ]
        )

        let result = try WebEidRequestParser.parseAuthURL(authURL)

        #expect(result.challenge == challenge)
        #expect(result.loginUri == loginUri)
        #expect(result.getSigningCertificate == false)
        #expect(result.origin == "https://example.com")
    }

    @Test
    func parseAuthURL_throws_whenFragmentMissing() throws {
        let url = try #require(URL(string: "web-eid://authenticate"))

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(url)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenChallengeTooShort() throws {
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": "short",
                "loginUri": "https://example.com/login"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenChallengeTooLong() throws {
        let challenge = String(repeating: "A", count: 129)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": "https://example.com/login"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenChallengeBlank() throws {
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": "   ",
                "loginUri": "https://example.com/login"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenLoginUriMissing() throws {
        let challenge = String(repeating: "A", count: 44)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenLoginUriIsNotHttps() throws {
        let challenge = String(repeating: "A", count: 44)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": "http://example.com/login"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_throwsWebEidException_whenLoginUriContainsUserInfo() throws {
        let challenge = String(repeating: "A", count: 44)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": "https://user:pass@example.com/login"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseAuthURL(authURL)
        }
    }

    @Test
    func parseAuthURL_returnsOriginWithPort_whenResponseUriContainsPort() throws {
        let challenge = String(repeating: "A", count: 44)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": "https://example.com:8443/login"
            ]
        )

        let result = try WebEidRequestParser.parseAuthURL(authURL)

        #expect(result.origin == "https://example.com:8443")
    }

    // MARK: - Certificate

    @Test
    func parseCertificateURL_returnsCertificateRequest_whenValid() throws {
        let responseUri = "https://example.com/certificate"
        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": responseUri
            ]
        )

        let result = try WebEidRequestParser.parseCertificateURL(url)

        #expect(result.responseUri == responseUri)
        #expect(result.origin == "https://example.com")
    }

    @Test
    func parseCertificateURL_throwsWebEidException_whenResponseUriMissing() throws {
        let url = try makeURL(
            scheme: "web-eid",
            payload: [:]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseCertificateURL(url)
        }
    }

    @Test
    func parseCertificateURL_throwsWebEidException_whenResponseUriSchemeInvalid() throws {
        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "custom://example.com/certificate"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseCertificateURL(url)
        }
    }

    // MARK: - Sign

    @Test
    func parseSignURL_returnsSignRequest_whenValid() throws {
        let responseUri = "https://example.com/sign"
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": responseUri,
                "hash": hashBase64,
                "hashFunction": "SHA-256",
                "signingCertificate": eccCertBase64
            ]
        )

        let result = try WebEidRequestParser.parseSignURL(url)

        #expect(result.responseUri == responseUri)
        #expect(result.origin == "https://example.com")
        #expect(result.hash == hashBase64)
        #expect(result.hashFunction == "SHA-256")
        #expect(SecCertificateCopyKey(result.signingCertificate) != nil)

        #expect(result.personalData?.surname == "JÕEORG")
        #expect(result.personalData?.givenNames == "JAAK-KRISTJAN")
        #expect(result.personalData?.personalCode == "38001085718")
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashMissing() throws {
        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hashFunction": "SHA-256",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashFunctionMissing() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashEncodingInvalid() throws {
        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": "ÖÖÖÖÖÖÖ",
                "hashFunction": "SHA-256",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashFunctionUnsupported() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA-999",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashFunctionTooLong() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA3-256X",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenHashLengthDoesNotMatchHashFunction() throws {
        let hashData = Data(repeating: 0xAB, count: 31)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA-256",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throws_whenSigningCertificateMissing() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA-256"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenSigningCertificateEncodingInvalid() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA-256",
                "signingCertificate": "ÖÖÖÖÖÖÖ"
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    @Test
    func parseSignURL_throwsWebEidException_whenResponseUriInvalid() throws {
        let hashData = Data(repeating: 0xAB, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "http://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "SHA-256",
                "signingCertificate": eccCertBase64
            ]
        )

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseSignURL(url)
        }
    }

    // MARK: - Fragment / JSON decoding

    @Test
    func parseCertificateURL_throwsWebEidException_whenFragmentIsInvalidBase64() throws {
        let url = try #require(URL(string: "web-eid://certificate#ÖÖÖÖÖÖÖ"))

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseCertificateURL(url)
        }
    }

    @Test
    func parseCertificateURL_throwsWebEidException_whenFragmentIsNotJSONObject() throws {
        let arrayJSON = "[1,2,3]"
        let fragment = Data(arrayJSON.utf8).base64EncodedString()
        let url = try #require(URL(string: "web-eid://certificate#\(fragment)"))

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseCertificateURL(url)
        }
    }

    @Test
    func parseCertificateURL_throwsWebEidException_whenFragmentIsNotJSON() throws {
        let fragment = Data("not-json".utf8).base64EncodedString()
        let url = try #require(URL(string: "web-eid://certificate#\(fragment)"))

        #expect(throws: WebEidException.self) {
            try WebEidRequestParser.parseCertificateURL(url)
        }
    }

    // MARK: - Edge cases

    @Test
    func parseAuthURL_acceptsChallengeAtMaxLength() throws {
        let challenge = String(repeating: "C", count: 128)
        let authURL = try makeURL(
            scheme: "web-eid",
            payload: [
                "challenge": challenge,
                "loginUri": "https://example.com/login"
            ]
        )

        let result = try WebEidRequestParser.parseAuthURL(authURL)

        #expect(result.challenge == challenge)
    }

    @Test
    func parseSignURL_acceptsLowercaseHashFunction() throws {
        let hashData = Data(repeating: 0xCD, count: 32)
        let hashBase64 = hashData.base64EncodedString()

        let url = try makeURL(
            scheme: "web-eid",
            payload: [
                "responseUri": "https://example.com/sign",
                "hash": hashBase64,
                "hashFunction": "sha-256",
                "signingCertificate": eccCertBase64
            ]
        )

        let result = try WebEidRequestParser.parseSignURL(url)

        #expect(result.hashFunction == "sha-256")
    }

    // MARK: - Helpers

    private func makeURL(scheme: String, payload: [String: Any]) throws -> URL {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        let fragment = jsonData.base64EncodedString()
        return try #require(URL(string: "\(scheme)://request#\(fragment)"))
    }
}
