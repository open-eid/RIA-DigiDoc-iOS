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
import CommonsLib
import CommonsTestShared
import WebEidLibMocks
import Security

@testable import WebEidLib

struct WebEidAlgorithmUtilTests {

    // swiftlint:disable line_length
    private let testCert = "MIID7DCCA02gAwIBAgIQK33iqGajpAnSrLD7w+X3TjAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OVoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATYWYk4C8W5+RAMeuvIQVa0sVdobkxXKASvA4lUh5K/whRAT5f3p8n2rw8O3nsCt/1LFyKXVVrZdtWZ1Vh894TA2QHEm6xaXnJs4ZmYo4blrm/nXE1PcEZan9023+73sE+jggGrMIIBpzAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MEgGA1UdIARBMD8wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAkGBwQAi+xAAQIwgYoGCCsGAQUFBwEDBH4wfDAIBgYEAI5GAQEwCAYGBACORgEEMBMGBgQAjkYBBjAJBgcEAI5GAQYBMFEGBgQAjkYBBTBHMEUWP2h0dHBzOi8vc2suZWUvZW4vcmVwb3NpdG9yeS9jb25kaXRpb25zLWZvci11c2Utb2YtY2VydGlmaWNhdGVzLxMCZW4wHQYDVR0OBBYEFFh+R2KDfE2Tdj///kXTCqcz6rRuMA4GA1UdDwEB/wQEAwIGQDAKBggqhkjOPQQDBAOBjAAwgYgCQgD7B3WI1xpXX94+9e3TdaIcUNCj5JkCX15pj1mjRqv/Vx9Hlg3tbgwW2yOhqnTF04+e9rVHCtA8YRINp5BfDFqj/wJCAVuUlCu7GNVSFeU7A6lEORkB6obIALZusUFxT4bsaFWTpKllmvlX6lZm3QEbHgeiD8k7VMPdcw5V51p+B+2WUWBh"
    private let testSignature =
        "jfrC/H3mn+ySpYCJrzIMm5Wm7sC0VRLyyuA6Jkc7cTt1JwjobbdAleQucJfc71f0MOeGtXouKIjs/HvETPZZNfjtgx/9bzwQCnws9TvZly1XCbscFFYP4rAbz4HNF+wk"
    // swiftlint:enable line_length

    @Test
    func buildSupportedSignatureAlgorithms_returnJSONObject() async throws {
        let signingCert = try #require(Data(base64Encoded: testCert))
        let secCert = try #require(SecCertificateCreateWithData(nil, signingCert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let expected = [
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA-224",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA-256",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA-384",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA-512",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA3-224",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA3-256",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA3-384",
                "paddingScheme": "NONE"
            ],
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": "SHA3-512",
                "paddingScheme": "NONE"
            ]
        ]
        let result = try WebEidAlgorithmUtil.buildSupportedSignatureAlgorithms(
            publicKey: publicKey
        )
        let resultTyped = result as? [[String: String]]

        #expect(resultTyped == expected)
    }

    @Test
    func buildSupportedSignatureAlgorithms_advertisesRSAForAnRSASigningKey() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()
        let secCert = try #require(SecCertificateCreateWithData(nil, cert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let result = try WebEidAlgorithmUtil.buildSupportedSignatureAlgorithms(publicKey: publicKey)

        #expect(result.count == WebEidAlgorithmUtil.supportedHashFunctions.count)
        #expect(result.allSatisfy { $0["cryptoAlgorithm"] as? String == "RSA" })
        #expect(result.allSatisfy { $0["paddingScheme"] as? String == "PKCS1.5" })
        #expect(result.contains { $0["hashFunction"] as? String == "SHA-256" })
    }

    @Test
    func buildSupportedSignatureAlgorithms_advertisesECCForAnECSigningKey() async throws {
        let signingCert = try #require(Data(base64Encoded: testCert))
        let secCert = try #require(SecCertificateCreateWithData(nil, signingCert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let result = try WebEidAlgorithmUtil.buildSupportedSignatureAlgorithms(publicKey: publicKey)

        #expect(result.allSatisfy { $0["cryptoAlgorithm"] as? String == "ECC" })
        #expect(result.allSatisfy { $0["paddingScheme"] as? String == "NONE" })
    }

    @Test
    func getAlgorithm_returnAlgorithmString() async throws {
        let signingCert = try #require(Data(base64Encoded: testCert))
        let secCert = try #require(SecCertificateCreateWithData(nil, signingCert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))
        let result = try WebEidAlgorithmUtil.getAlgorithm(publicKey: publicKey)
        #expect(result == "ES384")
    }

    @Test
    func getAlgorithm_throwUnsupportedKeyTypeWhenCertKeyIsUnsupported() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()
        let secCert = try #require(SecCertificateCreateWithData(nil, cert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        #expect(throws: WebEidAlgorithmUtilError.unsupportedKeyType) {
            try WebEidAlgorithmUtil.getAlgorithm(publicKey: publicKey)
        }
    }

    @Test
    func buildSignatureAlgorithm_returnJSONObjectWhenECCKey() async throws {
        let signingCert = Data(base64Encoded: testCert) ?? Data()
        let secCert = try #require(SecCertificateCreateWithData(nil, signingCert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let expected = ["cryptoAlgorithm": "ECC",
                        "hashFunction": "SHA-256",
                        "paddingScheme": "NONE"]

        let result = try WebEidAlgorithmUtil.buildSignatureAlgorithm(
            publicKey: publicKey,
            hashFunction: "SHA-256"
        )
        let resultTyped = result as? [String: String]
        #expect(resultTyped == expected)
    }

    @Test
    func buildSignatureAlgorithm_returnJSONObjectWhenRSAKey() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()
        let secCert = try #require(SecCertificateCreateWithData(nil, cert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let expected = [
            "cryptoAlgorithm": "RSA",
            "hashFunction": "SHA-256",
            "paddingScheme": "PKCS1.5"
        ]

        let result = try WebEidAlgorithmUtil.buildSignatureAlgorithm(
            publicKey: publicKey,
            hashFunction: "SHA-256"
        )
        let resultTyped = result as? [String: String]
        #expect(resultTyped == expected)
    }

    @Test
    func buildSignatureAlgorithm_throwUnsupportedHashFunctionWhenHashIsUnsupported() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()
        let secCert = try #require(SecCertificateCreateWithData(nil, cert as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        #expect(throws: WebEidAlgorithmUtilError.unsupportedHashFunction("SHA-255")) {
            try WebEidAlgorithmUtil.buildSignatureAlgorithm(
                publicKey: publicKey,
                hashFunction: "SHA-255"
            )
        }
    }

    @Test
    func parseCertificate_returnSecCertificatedWhenValidBase64String() async throws {
        let signingCertBase64 = TestCertificateUtil.getSampleCertificateString()

        let result = try WebEidAlgorithmUtil.parseCertificate(signingCertBase64: signingCertBase64)

        #expect(SecCertificateCopyKey(result) != nil)
    }

    @Test
    func parseCertificate_throwInvalidCertificateWhenInvalidCertString() async throws {
        let invalidCert = "MIIEwjC"

        #expect(throws: WebEidAlgorithmUtilError.invalidCertificate) {
            try WebEidAlgorithmUtil.parseCertificate(signingCertBase64: invalidCert)
        }
    }

    @Test
    func parseCertificate_throwInvalidBase64WhenInvalidBase64String() async throws {
        let invalidBase64String = "ÖÖÖÖÖÖÖ"

        #expect(throws: WebEidAlgorithmUtilError.invalidBase64) {
            try WebEidAlgorithmUtil.parseCertificate(signingCertBase64: invalidBase64String)
        }
    }

    @Test
    func certificate_returnSecCertificatedWhenValidDataBytes() async throws {
        let signingCert = TestCertificateUtil.getSampleCertificate()

        let result = try #require(WebEidAlgorithmUtil.certificate(from: signingCert))
        _ = try #require(SecCertificateCopyKey(result))
    }

    @Test
    func certificate_returnNilWhenInvalidDataBytes() async throws {
        let invalidCert = Data([0x00, 0x01, 0x02])

        let result = WebEidAlgorithmUtil.certificate(from: invalidCert)

        #expect(result == nil)
    }

    @Test
    func certificate_returnDataWhenBase64StringValid() async throws {
        let expected = Data("test result".utf8)
        let base64String = expected.base64EncodedString()

        let result = WebEidAlgorithmUtil.base64DecodeFlexible(base64String)

        #expect(result == expected)
    }

    @Test
    func certificate_returnNilWhenBase64StringInvalid() async throws {
        let base64String = "ÖÖÖÖÖÖÖ"

        let result = WebEidAlgorithmUtil.base64DecodeFlexible(base64String)

        #expect(result == nil)
    }

    @Test
    func buildSignatureAlgorithm_acceptsLowercaseHashFunctionAndReturnsCanonicalForm() async throws {
        let certData = try #require(Data(base64Encoded: testCert))
        let secCert = try #require(SecCertificateCreateWithData(nil, certData as CFData))
        let publicKey = try #require(SecCertificateCopyKey(secCert))

        let result = try WebEidAlgorithmUtil.buildSignatureAlgorithm(
            publicKey: publicKey,
            hashFunction: "sha-256"
        )

        #expect(result["hashFunction"] as? String == "SHA-256")
        #expect(result["cryptoAlgorithm"] as? String == "ECC")
    }

    @Test
    func base64DecodeFlexible_decodesBase64UrlAlphabet() async throws {
        let expected = Data([0xFB, 0xFF, 0xBE, 0x03, 0xEF, 0xFF])
        let base64Url = expected.base64EncodedString()
            .replacing("+", with: "-")
            .replacing("/", with: "_")

        let result = WebEidAlgorithmUtil.base64DecodeFlexible(base64Url)

        #expect(result == expected)
    }

    @Test
    func base64DecodeFlexible_decodesBase64UrlWithoutPadding() async throws {
        let expected = Data([0xFB, 0xFF, 0xBE, 0x03, 0xEF])
        let base64Url = expected.base64EncodedString()
            .replacing("+", with: "-")
            .replacing("/", with: "_")
            .replacing("=", with: "")

        let result = WebEidAlgorithmUtil.base64DecodeFlexible(base64Url)

        #expect(result == expected)
    }
}
