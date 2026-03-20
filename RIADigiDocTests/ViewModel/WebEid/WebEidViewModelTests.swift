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
import Testing
import UtilsLib
import UtilsLibMocks
import WebEidLib
import WebEidLibMocks

@MainActor
final class WebEidViewModelTests {

    private let viewModel: WebEidViewModel

    private let mockDataStore: DataStoreProtocolMock
    private let mockKeychainStore: KeychainStoreProtocolMock
    private let mockAuthService: WebEidAuthServiceProtocolMock
    private let mockSignService: WebEidSignServiceProtocolMock

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockKeychainStore = KeychainStoreProtocolMock()
        mockAuthService = WebEidAuthServiceProtocolMock()
        mockSignService = WebEidSignServiceProtocolMock()

        mockAuthService.buildAuthTokenHandler = { _, _, _ in
            try JSONSerialization.data(withJSONObject: [
                "token": "test-token",
                "expires": 123456
            ])
        }

        mockSignService.buildCertificatePayloadHandler = { _ in
            try JSONSerialization.data(withJSONObject: [
                "certificate": "base64cert"
            ])
        }

        mockSignService.buildSignPayloadHandler = { _, _, _ in
            try JSONSerialization.data(withJSONObject: [
                "signature": "base64signature",
                "algorithm": "SHA-256"
            ])
        }

        viewModel = WebEidViewModel(
            dataStore: mockDataStore,
            keychainStore: mockKeychainStore,
            authService: mockAuthService,
            signService: mockSignService
        )
    }

    // MARK: - Helpers

    private func makeTestCertificate() throws -> SecCertificate {
        let base64 = "MIID7DCCA02gAwIBAgIQK33iqGajpAnSrLD7w+X3TjAKBggqhkjOPQQDBDBgMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRhDA5OVFJFRS0xMDc0NzAxMzEbMBkGA1UEAwwSVEVTVCBvZiBFU1RFSUQyMDE4MB4XDTI1MDQyMjEwMTg0OVoXDTMwMDQyMTIwNTk1OVowfzELMAkGA1UEBhMCRUUxKjAoBgNVBAMMIUrDlUVPUkcsSkFBSy1LUklTVEpBTiwzODAwMTA4NTcxODEQMA4GA1UEBAwHSsOVRU9SRzEWMBQGA1UEKgwNSkFBSy1LUklTVEpBTjEaMBgGA1UEBRMRUE5PRUUtMzgwMDEwODU3MTgwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATYWYk4C8W5+RAMeuvIQVa0sVdobkxXKASvA4lUh5K/whRAT5f3p8n2rw8O3nsCt/1LFyKXVVrZdtWZ1Vh894TA2QHEm6xaXnJs4ZmYo4blrm/nXE1PcEZan9023+73sE+jggGrMIIBpzAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMCEmSnETp87AjT2meEKVgAIKT57MHMGCCsGAQUFBwEBBGcwZTA1BggrBgEFBQcwAoYpaHR0cDovL2Muc2suZWUvVGVzdF9vZl9FU1RFSUQyMDE4LmRlci5jcnQwLAYIKwYBBQUHMAGGIGh0dHA6Ly9haWEuZGVtby5zay5lZS9lc3RlaWQyMDE4MEgGA1UdIARBMD8wMgYLKwYBBAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMAkGBwQAi+xAAQIwgYoGCCsGAQUFBwEDBH4wfDAIBgYEAI5GAQEwCAYGBACORgEEMBMGBgQAjkYBBjAJBgcEAI5GAQYBMFEGBgQAjkYBBTBHMEUWP2h0dHBzOi8vc2suZWUvZW4vcmVwb3NpdG9yeS9jb25kaXRpb25zLWZvci11c2Utb2YtY2VydGlmaWNhdGVzLxMCZW4wHQYDVR0OBBYEFFh+R2KDfE2Tdj///kXTCqcz6rRuMA4GA1UdDwEB/wQEAwIGQDAKBggqhkjOPQQDBAOBjAAwgYgCQgD7B3WI1xpXX94+9e3TdaIcUNCj5JkCX15pj1mjRqv/Vx9Hlg3tbgwW2yOhqnTF04+e9rVHCtA8YRINp5BfDFqj/wJCAVuUlCu7GNVSFeU7A6lEORkB6obIALZusUFxT4bsaFWTpKllmvlX6lZm3QEbHgeiD8k7VMPdcw5V51p+B+2WUWBh"

        guard
            let data = Data(base64Encoded: base64),
            let cert = SecCertificateCreateWithData(nil, data as CFData)
        else {
            throw NSError(domain: "WebEidViewModelTests", code: 1)
        }

        return cert
    }

    private func makeAuthRequest(getSigningCertificate: Bool = false) -> WebEidAuthRequest {
        WebEidAuthRequest(
            challenge: "challenge",
            loginUri: "https://example.com/auth-callback",
            getSigningCertificate: getSigningCertificate,
            origin: "https://example.com"
        )
    }

    private func makeCertificateRequest(responseUri: String = "https://example.com/certificate-callback")
    -> WebEidCertificateRequest {
        WebEidCertificateRequest(
            responseUri: responseUri,
            origin: "https://example.com"
        )
    }

    private func makeSignRequest(
        responseUri: String = "https://example.com/sign-callback",
        hash: String? = "hash",
        hashFunction: String? = "SHA-256"
    ) throws -> WebEidSignRequest {
        try WebEidSignRequest(
            responseUri: responseUri,
            origin: "https://example.com",
            signingCertificate: makeTestCertificate(),
            hash: hash,
            hashFunction: hashFunction,
            personalData: nil
        )
    }

    // MARK: - handleUnknown

    @Test
    func handleUnknown_setsInvalidRequestError() {
        let url = URL(string: "web-eid://unknown")!

        viewModel.handleUnknown(url: url)

        #expect(viewModel.errorKey == "Invalid Web eID request")
        #expect(viewModel.errorExtraArguments.isEmpty)
    }

    // MARK: - handleCertificate

    @Test
    func handleCertificate_setsErrorOnInvalidURL() {
        let url = URL(string: "https://example.com/not-a-valid-certificate-request")!

        viewModel.handleCertificate(url: url)

        #expect(viewModel.certRequest == nil)
        #expect(viewModel.errorKey == "Invalid Web eID request")
        #expect(viewModel.errorExtraArguments.isEmpty)
    }

    // MARK: - handleAuth

    @Test
    func handleAuth_setsErrorOrResponseOnInvalidURL() {
        let url = URL(string: "https://example.com/not-a-valid-auth-request")!

        viewModel.handleAuth(url: url)

        #expect(viewModel.authRequest == nil)
        #expect(
            viewModel.errorKey == "Invalid authentication request" ||
            viewModel.relyingPartyResponseEvents != nil
        )
    }

    // MARK: - handleSign

    @Test
    func handleSign_setsErrorOrResponseOnInvalidURL() {
        let url = URL(string: "https://example.com/not-a-valid-sign-request")!

        viewModel.handleSign(url: url)

        #expect(viewModel.signRequest == nil)
        #expect(
            viewModel.errorKey == "Invalid Web eID request" ||
            viewModel.relyingPartyResponseEvents != nil
        )
    }

    // MARK: - handleWebEidAuthResult

    @Test
    func handleWebEidAuthResult_returnsEarlyWhenAuthRequestMissing() async {
        viewModel.authRequest = nil

        await viewModel.handleWebEidAuthResult(
            authCert: Data("auth".utf8),
            signingCert: Data("sign".utf8),
            signature: Data("sig".utf8)
        )

        #expect(mockAuthService.buildAuthTokenCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidAuthResult_success_withoutSigningCertificate() async throws {
        viewModel.authRequest = makeAuthRequest(getSigningCertificate: false)

        mockAuthService.buildAuthTokenHandler = { authCert, signingCert, signature in
            #expect(authCert == Data("auth".utf8))
            #expect(signingCert == nil)
            #expect(signature == Data("sig".utf8))

            return try JSONSerialization.data(withJSONObject: [
                "token": "auth-token"
            ])
        }

        await viewModel.handleWebEidAuthResult(
            authCert: Data("auth".utf8),
            signingCert: Data("sign".utf8),
            signature: Data("sig".utf8)
        )

        #expect(mockAuthService.buildAuthTokenCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    @Test
    func handleWebEidAuthResult_success_withSigningCertificate() async throws {
        viewModel.authRequest = makeAuthRequest(getSigningCertificate: true)

        mockAuthService.buildAuthTokenHandler = { authCert, signingCert, signature in
            #expect(authCert == Data("auth".utf8))
            #expect(signingCert == Data("sign".utf8))
            #expect(signature == Data("sig".utf8))

            return try JSONSerialization.data(withJSONObject: [
                "token": "auth-token"
            ])
        }

        await viewModel.handleWebEidAuthResult(
            authCert: Data("auth".utf8),
            signingCert: Data("sign".utf8),
            signature: Data("sig".utf8)
        )

        #expect(mockAuthService.buildAuthTokenCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    @Test
    func handleWebEidAuthResult_buildsErrorResponseWhenAuthServiceThrows() async {
        viewModel.authRequest = makeAuthRequest(getSigningCertificate: true)

        mockAuthService.buildAuthTokenHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        await viewModel.handleWebEidAuthResult(
            authCert: Data("auth".utf8),
            signingCert: Data("sign".utf8),
            signature: Data("sig".utf8)
        )

        #expect(mockAuthService.buildAuthTokenCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    @Test
    func handleWebEidAuthResult_buildsErrorResponseWhenReturnedJsonIsInvalid() async {
        viewModel.authRequest = makeAuthRequest(getSigningCertificate: true)

        mockAuthService.buildAuthTokenHandler = { _, _, _ in
            Data("not-json".utf8)
        }

        await viewModel.handleWebEidAuthResult(
            authCert: Data("auth".utf8),
            signingCert: Data("sign".utf8),
            signature: Data("sig".utf8)
        )

        #expect(mockAuthService.buildAuthTokenCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    // MARK: - handleWebEidCertificateResult

    @Test
    func handleWebEidCertificateResult_returnsEarlyWhenRequestMissing() async {
        viewModel.certRequest = nil

        await viewModel.handleWebEidCertificateResult(
            signingCert: Data("cert".utf8)
        )

        #expect(mockSignService.buildCertificatePayloadCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidCertificateResult_returnsEarlyWhenResponseUriBlank() async {
        viewModel.certRequest = makeCertificateRequest(responseUri: "   ")

        await viewModel.handleWebEidCertificateResult(
            signingCert: Data("cert".utf8)
        )

        #expect(mockSignService.buildCertificatePayloadCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidCertificateResult_success() async throws {
        viewModel.certRequest = makeCertificateRequest()

        mockSignService.buildCertificatePayloadHandler = { signingCert in
            #expect(signingCert == Data("cert".utf8))
            return try JSONSerialization.data(withJSONObject: [
                "certificate": "base64cert"
            ])
        }

        await viewModel.handleWebEidCertificateResult(
            signingCert: Data("cert".utf8)
        )

        #expect(mockSignService.buildCertificatePayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    @Test
    func handleWebEidCertificateResult_returnsEarlyWhenPayloadJsonIsNotDictionary() async throws {
        viewModel.certRequest = makeCertificateRequest()

        mockSignService.buildCertificatePayloadHandler = { _ in
            try JSONSerialization.data(withJSONObject: ["one", "two"])
        }

        await viewModel.handleWebEidCertificateResult(
            signingCert: Data("cert".utf8)
        )

        #expect(mockSignService.buildCertificatePayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidCertificateResult_buildsErrorResponseWhenServiceThrows() async {
        viewModel.certRequest = makeCertificateRequest()

        mockSignService.buildCertificatePayloadHandler = { _ in
            throw NSError(domain: "TestError", code: 1)
        }

        await viewModel.handleWebEidCertificateResult(
            signingCert: Data("cert".utf8)
        )

        #expect(mockSignService.buildCertificatePayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    // MARK: - handleWebEidSignResult

    @Test
    func handleWebEidSignResult_returnsEarlyWhenSignRequestMissing() async {
        viewModel.signRequest = nil

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidSignResult_returnsEarlyWhenHashFunctionMissing() async throws {
        viewModel.signRequest = try makeSignRequest(hashFunction: nil)

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidSignResult_returnsEarlyWhenHashFunctionBlank() async throws {
        viewModel.signRequest = try makeSignRequest(hashFunction: "   ")

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 0)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidSignResult_success() async throws {
        viewModel.signRequest = try makeSignRequest(hashFunction: "SHA-256")

        mockSignService.buildSignPayloadHandler = { signingCert, signature, hashFunction in
            #expect(signingCert == "cert")
            #expect(signature == Data("sig".utf8))
            #expect(hashFunction == "SHA-256")

            return try JSONSerialization.data(withJSONObject: [
                "signature": "base64signature",
                "algorithm": "SHA-256"
            ])
        }

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    @Test
    func handleWebEidSignResult_returnsEarlyWhenPayloadJsonIsNotDictionary() async throws {
        viewModel.signRequest = try makeSignRequest(hashFunction: "SHA-256")

        mockSignService.buildSignPayloadHandler = { _, _, _ in
            try JSONSerialization.data(withJSONObject: ["one", "two"])
        }

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleWebEidSignResult_buildsErrorResponseWhenServiceThrows() async throws {
        viewModel.signRequest = try makeSignRequest(hashFunction: "SHA-256")

        mockSignService.buildSignPayloadHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        await viewModel.handleWebEidSignResult(
            signingCert: "cert",
            signature: Data("sig".utf8),
            responseUri: "https://example.com/sign-callback"
        )

        #expect(mockSignService.buildSignPayloadCallCount == 1)
        #expect(viewModel.relyingPartyResponseEvents != nil)
    }

    // MARK: - handleUserCancelled

    @Test
    func handleUserCancelled_usesAuthRequestLoginUriFirst() async throws {
        viewModel.authRequest = makeAuthRequest()
        viewModel.certRequest = makeCertificateRequest(responseUri: "https://example.com/cert-callback")
        viewModel.signRequest = try makeSignRequest(responseUri: "https://example.com/sign-callback")

        await viewModel.handleUserCancelled()

        #expect(viewModel.relyingPartyResponseEvents != nil)
        #expect(viewModel.relyingPartyResponseEvents?.absoluteString.contains("auth-callback") == true)
    }

    @Test
    func handleUserCancelled_usesCertificateUriWhenAuthRequestMissing() async throws {
        viewModel.authRequest = nil
        viewModel.certRequest = makeCertificateRequest(responseUri: "https://example.com/cert-callback")
        viewModel.signRequest = try makeSignRequest(responseUri: "https://example.com/sign-callback")

        await viewModel.handleUserCancelled()

        #expect(viewModel.relyingPartyResponseEvents != nil)
        #expect(viewModel.relyingPartyResponseEvents?.absoluteString.contains("cert-callback") == true)
    }

    @Test
    func handleUserCancelled_usesSignUriWhenOthersMissing() async throws {
        viewModel.authRequest = nil
        viewModel.certRequest = nil
        viewModel.signRequest = try makeSignRequest(responseUri: "https://example.com/sign-callback")

        await viewModel.handleUserCancelled()

        #expect(viewModel.relyingPartyResponseEvents != nil)
        #expect(viewModel.relyingPartyResponseEvents?.absoluteString.contains("sign-callback") == true)
    }

    @Test
    func handleUserCancelled_returnsEarlyWhenNoResponseUriAvailable() async {
        viewModel.authRequest = nil
        viewModel.certRequest = nil
        viewModel.signRequest = nil

        await viewModel.handleUserCancelled()

        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    @Test
    func handleUserCancelled_returnsEarlyWhenResponseUriBlank() async {
        viewModel.authRequest = nil
        viewModel.certRequest = makeCertificateRequest(responseUri: "   ")
        viewModel.signRequest = nil

        await viewModel.handleUserCancelled()

        #expect(viewModel.relyingPartyResponseEvents == nil)
    }

    // MARK: - resetErrors

    @Test
    func resetErrors_clearsAllErrorAndAlertState() {
        viewModel.showAlertMessage = true
        viewModel.alertMessageKey = "Alert"
        viewModel.alertMessageExtraArguments = ["arg1"]
        viewModel.alertMessageUrl = "https://example.com"

        viewModel.errorKey = "Error"
        viewModel.errorExtraArguments = ["arg2"]

        viewModel.resetErrors()

        #expect(viewModel.showAlertMessage == false)
        #expect(viewModel.alertMessageKey == nil)
        #expect(viewModel.alertMessageExtraArguments.isEmpty)
        #expect(viewModel.alertMessageUrl == nil)
        #expect(viewModel.errorKey == nil)
        #expect(viewModel.errorExtraArguments.isEmpty)
    }

    // MARK: - WebEid session active

    @Test
    func isWebEidSessionActive_returnsFalseWhenValueMissing() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .webEidSessionActive)
            return nil
        }

        let result = await viewModel.isWebEidSessionActive()

        #expect(result == false)
        #expect(mockKeychainStore.retrieveKeyCallCount == 1)
    }

    @Test
    func isWebEidSessionActive_returnsTrueWhenStoredByteIsOne() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .webEidSessionActive)
            return Data([1])
        }

        let result = await viewModel.isWebEidSessionActive()

        #expect(result == true)
        #expect(mockKeychainStore.retrieveKeyCallCount == 1)
    }

    @Test
    func isWebEidSessionActive_returnsFalseWhenStoredByteIsZero() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .webEidSessionActive)
            return Data([0])
        }

        let result = await viewModel.isWebEidSessionActive()

        #expect(result == false)
        #expect(mockKeychainStore.retrieveKeyCallCount == 1)
    }

    @Test
    func isWebEidSessionActive_returnsFalseWhenStoredDataIsEmpty() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .webEidSessionActive)
            return Data()
        }

        let result = await viewModel.isWebEidSessionActive()

        #expect(result == false)
        #expect(mockKeychainStore.retrieveKeyCallCount == 1)
    }

    @Test
    func setWebEidSessionActive_savesTrueAsOneByte() async {
        mockKeychainStore.saveKeyInfoHandler = { key, info in
            #expect(key == .webEidSessionActive)
            #expect(info == Data([1]))
            return true
        }

        await viewModel.setWebEidSessionActive(true)

        #expect(mockKeychainStore.saveKeyInfoCallCount == 1)
    }

    @Test
    func setWebEidSessionActive_savesFalseAsZeroByte() async {
        mockKeychainStore.saveKeyInfoHandler = { key, info in
            #expect(key == .webEidSessionActive)
            #expect(info == Data([0]))
            return true
        }

        await viewModel.setWebEidSessionActive(false)

        #expect(mockKeychainStore.saveKeyInfoCallCount == 1)
    }
}
