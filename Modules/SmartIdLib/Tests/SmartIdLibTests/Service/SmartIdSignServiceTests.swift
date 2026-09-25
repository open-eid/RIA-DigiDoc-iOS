// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CommonsLib
import SmartIdLibMocks

@testable import SmartIdLib

struct SmartIdSignServiceTests {

    private let requestPerformer: RequestPerfomerProtocolMock

    private var service: SmartIdSignServiceProtocol

    private let url = "https://url.test"
    private let certificates: [SecCertificate] = []
    private let proxy = ProxyInfo()

    init() async throws {
        requestPerformer = RequestPerfomerProtocolMock()
        service = SmartIdSignService(requestPerfomer: requestPerformer)
    }

    @Test
    func getCertificateRequest_returnSessionIdResponse() async throws {
        let expected = SmartIdSessionIdResponse(sessionID: "abc")

        requestPerformer.performRequestHandler = { url, method, parameters, _, _, _ in
            #expect(method == .post)
            #expect(url.contains("PNOEE-12345678901"))
            #expect(parameters is SmartIdCertificateRequest)
            return expected
        }

        let result = try await service.getCertificateRequest(
            url: url,
            relyingPartyName: "RP",
            relyingPartyUUID: "UUID",
            country: "EE",
            nationalIdentityNumber: "12345678901",
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        #expect(result == expected)
    }

    // MARK: - getSignatureRequest

    @Test
    func getSignatureRequest_returnSessionIdResponse() async throws {
        let expected = SmartIdSessionIdResponse(sessionID: "sig")

        requestPerformer.performRequestHandler = { url, method, parameters, _, _, _ in
            let request = try #require(parameters as? SmartIdSignatureRequest)

            #expect(method == .post)
            #expect(url.hasSuffix("/DOC123"))
            #expect(request.hashType == "SHA256")
            #expect(request.allowedInteractionsOrder.first?.displayText200 == "Sign")

            return expected
        }

        let result = try await service.getSignatureRequest(
            url: url,
            relyingPartyName: "RP",
            relyingPartyUUID: "UUID",
            documentNumber: "DOC123",
            hash: Data([0x01, 0x02]),
            hashType: "SHA256",
            allowedInteractionsOrderType: "confirmationMessage",
            displayText200: "Sign",
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        #expect(result == expected)
    }

    @Test
    func getSessionRequest_returnResponseWhenStateComplete() async throws {
        let expected = SmartIdSessionResponse(
            state: .complete,
            result: nil,
            signature: nil,
            cert: nil
        )

        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            expected
        }

        let result = try await service.getSessionRequest(
            url: url,
            sessionId: "SESSION",
            pollingTimeout: 1,
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        #expect(result.state == .complete)
    }

    @Test
    func getSessionRequest_throwGeneralErrorWhenErrorThrownDuringRequest() async {
        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            throw SmartIdError.generalError
        }

        await #expect(throws: SmartIdError.generalError) {
            try await service.getSessionRequest(
                url: url,
                sessionId: "SESSION",
                pollingTimeout: 1,
                trustedCertificates: certificates,
                proxyInfo: proxy,
                userAgent: "TestUserAgent"
            )
        }
    }

    @Test
    func getVerificationCode_returnFourDigitCodeWithValidDigest() async {
        let digest = Data([0x00, 0x00, 0x12, 0x34])

        let code = await service.getVerificationCode(digest: digest)

        #expect(code.count == 4)
        #expect(code == "4660")
    }

    @Test
    func getVerificationCode_keepLeadingZeros() async {
        let digest = Data([0x00, 0x00, 0x00, 0x01])

        let code = await service.getVerificationCode(digest: digest)

        #expect(code == "0001")
    }
}
