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

struct WebEidAuthServiceTests {
    private var service: WebEidAuthServiceProtocol

    // swiftlint:disable line_length
    private let testAuthCert = "MIIEDjCCA2+gAwIBAgIQfS1XPVaqF6id70AX3+4UQzAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OFoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAASJtW601r+uC3ipDFbn4st6lxtAjqICVTUTIQ0Wq/hsxHPjzSUfWDJqhWXuDBg0E9hDnnQlkIiX+c7vYeBOhHG0kbzjhQ+iz9xF3fnuDHVb/QtXBbXrh4fXWu5tVOb6IkejggHNMIIByTAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MB8GA1UdEQQYMBaBFDM4MDAxMDg1NzE4QGVlc3RpLmVlMEcGA1UdIARAMD4wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAgGBgQAj3oBAjAgBgNVHSUBAf8EFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwawYIKwYBBQUHAQMEXzBdMAgGBgQAjkYBATBRBgYEAI5GAQUwRzBFFj9odHRwczovL3NrLmVlL2VuL3JlcG9zaXRvcnkvY29uZGl0aW9ucy1mb3ItdXNlLW9mLWNlcnRpZmljYXRlcy8TAmVuMB0GA1UdDgQWBBRR540dJ/FCuVZGORkQFu/jLdK1PDAOBgNVHQ8BAf8EBAMCA4gwCgYIKoZIzj0EAwQDgYwAMIGIAkIBSoNaxY9V3Z7w0/tKUcLvzHLfJVb0v6OPHPlBm1wXQBw0dXSOoz3b67OFINismuBWLnvSHvIzLWZv73wth37ERIICQgDCQAFgi70IOKSLBbEGJEmJpjPq+r3VcbfBy/lXhuPOxzaIkAaCejOuehBl31gogGSIQp4LmFmR/4OOszWPOvu41w=="
    private let testSignCert = "MIID7DCCA02gAwIBAgIQK33iqGajpAnSrLD7w+X3TjAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OVoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATYWYk4C8W5+RAMeuvIQVa0sVdobkxXKASvA4lUh5K/whRAT5f3p8n2rw8O3nsCt/1LFyKXVVrZdtWZ1Vh894TA2QHEm6xaXnJs4ZmYo4blrm/nXE1PcEZan9023+73sE+jggGrMIIBpzAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MEgGA1UdIARBMD8wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAkGBwQAi+xAAQIwgYoGCCsGAQUFBwEDBH4wfDAIBgYEAI5GAQEwCAYGBACORgEEMBMGBgQAjkYBBjAJBgcEAI5GAQYBMFEGBgQAjkYBBTBHMEUWP2h0dHBzOi8vc2suZWUvZW4vcmVwb3NpdG9yeS9jb25kaXRpb25zLWZvci11c2Utb2YtY2VydGlmaWNhdGVzLxMCZW4wHQYDVR0OBBYEFFh+R2KDfE2Tdj///kXTCqcz6rRuMA4GA1UdDwEB/wQEAwIGQDAKBggqhkjOPQQDBAOBjAAwgYgCQgD7B3WI1xpXX94+9e3TdaIcUNCj5JkCX15pj1mjRqv/Vx9Hlg3tbgwW2yOhqnTF04+e9rVHCtA8YRINp5BfDFqj/wJCAVuUlCu7GNVSFeU7A6lEORkB6obIALZusUFxT4bsaFWTpKllmvlX6lZm3QEbHgeiD8k7VMPdcw5V51p+B+2WUWBh"
    private let testSignature =
        "UYyRpzkKNwFgtgcbI1YQc2l1XQQTj7gy+FW/x94TsEberwzS2Rnu4dqC/JhYB3se2iOk1c6FAK2TN5WJTiIcQ9Nt3o/x7kfEsdkc5c39eUXuD83GXfUsyUxR9IQBQrpL"
    // swiftlint:enable line_length

    init() async throws {
        service = WebEidAuthService()
    }

    @Test
    func buildAuthToken_returnJSONPayloadData() async throws {
        let authCert = Data(base64Encoded: testAuthCert) ?? Data()
        let signature = Data(base64Encoded: testSignature) ?? Data()
        let token: [String: Any] = [
            "unverifiedCertificate": testAuthCert,
            "issuerApp": "https://web-eid.eu/web-eid-mobile-app/releases/v1.0.0",
            "algorithm": "ES384",
            "format": "web-eid:1.0",
            "signature": testSignature]

        let expected = try JSONSerialization.data(
            withJSONObject: token,
            options: []
        )
        let result = try await service.buildAuthToken(
            authCert: authCert,
            signingCert: nil,
            signature: signature
        )

        #expect(result.count == expected.count)
    }
    
    @Test
    func buildAuthToken_returnJSONPayloadData_whenSignCertProvided() async throws {
        let authCert = Data(base64Encoded: testAuthCert) ?? Data()
        let signCert = Data(base64Encoded: testSignCert) ?? Data()
        let signature = Data(base64Encoded: testSignature) ?? Data()
        let token: [String: Any] = [
            "issuerApp": "https://web-eid.eu/web-eid-mobile-app/releases/v1.0.0",
            "format": "web-eid:1.1",
            "algorithm": "ES384",
            "unverifiedCertificate": testAuthCert,
            "signature": testSignature,
            "unverifiedSigningCertificates": [
                [
                    "supportedSignatureAlgorithms": [
                        ["cryptoAlgorithm": "ECC", "hashFunction": "SHA-224", "paddingScheme": "NONE"],
                        ["cryptoAlgorithm": "ECC", "paddingScheme": "NONE", "hashFunction": "SHA-256"],
                        ["cryptoAlgorithm": "ECC", "hashFunction": "SHA-384", "paddingScheme": "NONE"],
                        ["hashFunction": "SHA-512", "paddingScheme": "NONE", "cryptoAlgorithm": "ECC"],
                        ["cryptoAlgorithm": "ECC", "hashFunction": "SHA3-224", "paddingScheme": "NONE"],
                        ["hashFunction": "SHA3-256", "cryptoAlgorithm": "ECC", "paddingScheme": "NONE"],
                        ["paddingScheme": "NONE", "hashFunction": "SHA3-384", "cryptoAlgorithm": "ECC"],
                        ["hashFunction": "SHA3-512", "cryptoAlgorithm": "ECC", "paddingScheme": "NONE"]
                    ],
                    "certificate": testSignCert
                ]
            ]
        ]
        
        let expected = try JSONSerialization.data(
            withJSONObject: token,
            options: []
        )
        let result = try await service.buildAuthToken(
            authCert: authCert,
            signingCert: signCert,
            signature: signature
        )

        #expect(result.count == expected.count)
    }

    @Test
    func buildAuthToken_throwinvalidCertificateWhenCertIsInvalid() async throws {
        let invalidCert = Data([0x00, 0x01, 0x02])
        let signature = Data(base64Encoded: testSignature) ?? Data()

        await #expect(throws: WebEidBuilderError.invalidCertificate) {
            try await service.buildAuthToken(
                authCert: invalidCert,
                signingCert: nil,
                signature: signature
            )
        }
    }

    @Test
    func buildAuthToken_throwUnsupportedKeyTypeWhenCertKeyIsUnsupported() async throws {
        let cert = TestCertificateUtil.getSampleCertificate()
        let signature = Data(base64Encoded: testSignature) ?? Data()

        await #expect(throws: WebEidAlgorithmUtilError.unsupportedKeyType) {
            try await service.buildAuthToken(
                authCert: cert,
                signingCert: nil,
                signature: signature
            )
        }
    }
}
