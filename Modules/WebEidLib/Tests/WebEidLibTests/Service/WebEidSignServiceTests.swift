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

@testable import WebEidLib

struct WebEidSignServiceTests {
    private var service: WebEidSignServiceProtocol
    
    // swiftlint:disable line_length
    private let testCert = "MIID7DCCA02gAwIBAgIQK33iqGajpAnSrLD7w+X3TjAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OVoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATYWYk4C8W5+RAMeuvIQVa0sVdobkxXKASvA4lUh5K/whRAT5f3p8n2rw8O3nsCt/1LFyKXVVrZdtWZ1Vh894TA2QHEm6xaXnJs4ZmYo4blrm/nXE1PcEZan9023+73sE+jggGrMIIBpzAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MEgGA1UdIARBMD8wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAkGBwQAi+xAAQIwgYoGCCsGAQUFBwEDBH4wfDAIBgYEAI5GAQEwCAYGBACORgEEMBMGBgQAjkYBBjAJBgcEAI5GAQYBMFEGBgQAjkYBBTBHMEUWP2h0dHBzOi8vc2suZWUvZW4vcmVwb3NpdG9yeS9jb25kaXRpb25zLWZvci11c2Utb2YtY2VydGlmaWNhdGVzLxMCZW4wHQYDVR0OBBYEFFh+R2KDfE2Tdj///kXTCqcz6rRuMA4GA1UdDwEB/wQEAwIGQDAKBggqhkjOPQQDBAOBjAAwgYgCQgD7B3WI1xpXX94+9e3TdaIcUNCj5JkCX15pj1mjRqv/Vx9Hlg3tbgwW2yOhqnTF04+e9rVHCtA8YRINp5BfDFqj/wJCAVuUlCu7GNVSFeU7A6lEORkB6obIALZusUFxT4bsaFWTpKllmvlX6lZm3QEbHgeiD8k7VMPdcw5V51p+B+2WUWBh"
    private let testSignature =
        "jfrC/H3mn+ySpYCJrzIMm5Wm7sC0VRLyyuA6Jkc7cTt1JwjobbdAleQucJfc71f0MOeGtXouKIjs/HvETPZZNfjtgx/9bzwQCnws9TvZly1XCbscFFYP4rAbz4HNF+wk"
    // swiftlint:enable line_length
    
    init() async throws {
        service = WebEidSignService()
    }

    @Test
    func buildCertificatePayload_returnJSONPayloadData() async throws {
        let signingCert = Data(base64Encoded: testCert) ?? Data()
        
        let payload: [String: Any] = [
            "certificate": testCert,
            "supportedSignatureAlgorithms": [
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
        ]
        
        let expected = try JSONSerialization.data(withJSONObject: payload, options: [])
        let result = try await service.buildCertificatePayload(signingCert: signingCert)
        
        #expect(result.count == expected.count)
    }
    
    @Test
    func buildCertificatePayload_throwInvalidCertificateWhenCertIsInvalid() async throws {
        let invalidCert = Data([0x00, 0x01, 0x02])

        await #expect(throws: WebEidBuilderError.invalidCertificate) {
            try await service.buildCertificatePayload(signingCert: invalidCert)
        }
    }
    
    @Test
    func buildCertificatePayload_throwUnsupportedKeyTypeWhenCertKeyIsUnsupported() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()

        await #expect(throws: WebEidAlgorithmUtilError.unsupportedKeyType) {
            try await service.buildCertificatePayload(signingCert: cert)
        }
    }
    
    @Test
    func buildSignPayload_returnJSONPayloadData() async throws {
        let signature = Data(base64Encoded: testSignature) ?? Data()
        let payload: [String: Any] = [
            "signatureAlgorithm":
                [
                    "hashFunction": "SHA-256",
                    "paddingScheme": "NONE",
                    "cryptoAlgorithm": "ECC"
                ],
            "signature": testSignature
        ]
        
        let expected = try JSONSerialization.data(withJSONObject: payload, options: [])
        let result = try await service.buildSignPayload(signingCert: testCert,
                                                        signature: signature,
                                                        hashFunction: "SHA-256")

        #expect(result.count == expected.count)
    }
    
    @Test
    func buildSignPayload_throwUnsupportedHashFunctionWhenHashIsUnsupported() async throws {
        let cert = TestCertificateUtil.getSampleCertificateString()
        let signature = Data(base64Encoded: testSignature) ?? Data()
        await #expect(throws: WebEidAlgorithmUtilError.unsupportedHashFunction("SHA-255")) {
            try await service.buildSignPayload(signingCert: cert,
                                               signature: signature,
                                               hashFunction: "SHA-255")
        }
    }
}
