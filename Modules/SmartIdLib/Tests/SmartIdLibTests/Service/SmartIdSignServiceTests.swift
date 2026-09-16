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
    func getSessionRequest_returnsResponseWhenLaterPollCompletes() async throws {
        let running = SmartIdSessionResponse(state: .running, result: nil, signature: nil, cert: nil)
        let complete = SmartIdSessionResponse(state: .complete, result: nil, signature: nil, cert: nil)

        requestPerformer.performRequestHandler = { [requestPerformer] _, _, _, _, _, _ in
            requestPerformer.performRequestCallCount == 1 ? running : complete
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
        #expect(requestPerformer.performRequestCallCount == 2)
    }

    @Test
    func getSessionRequest_retriesImmediatelyOnMaintenanceOnceSessionHasAnswered() async throws {
        requestPerformer.performRequestHandler = { [requestPerformer] _, _, _, _, _, _ in
            if requestPerformer.performRequestCallCount == 1 {
                return SmartIdSessionResponse(state: .running, result: nil, signature: nil, cert: nil)
            }
            throw SmartIdError.underMaintenance
        }

        let elapsed = try await ContinuousClock().measure {
            await #expect(throws: SmartIdError.timeout) {
                try await service.getSessionRequest(
                    url: url,
                    sessionId: "SESSION",
                    pollingTimeout: 2,
                    trustedCertificates: certificates,
                    proxyInfo: proxy,
                    userAgent: "TestUserAgent"
                )
            }
        }

        #expect(elapsed < .seconds(5))
    }

    @Test
    func getSessionRequest_waitsBetweenMaintenanceRetriesWhenNoPollHasAnswered() async throws {
        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            throw SmartIdError.underMaintenance
        }

        let elapsed = try await ContinuousClock().measure {
            await #expect(throws: SmartIdError.underMaintenance) {
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

        #expect(elapsed > .seconds(2))
    }

    @Test
    func getSessionRequest_stopsPollingWhenAttemptIsCancelled() async {
        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            SmartIdSessionResponse(state: .running, result: nil, signature: nil, cert: nil)
        }

        let service = self.service
        let url = self.url
        let certificates = self.certificates
        let proxy = self.proxy

        let task = Task {
            try await service.getSessionRequest(
                url: url,
                sessionId: "SESSION",
                pollingTimeout: 1,
                trustedCertificates: certificates,
                proxyInfo: proxy,
                userAgent: "TestUserAgent"
            )
        }
        task.cancel()

        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }

    @Test
    func getSessionRequest_asksAgainWhenPollIsInterrupted() async throws {
        let expected = SmartIdSessionResponse(
            state: .complete,
            result: nil,
            signature: nil,
            cert: nil
        )

        requestPerformer.performRequestHandler = { [requestPerformer] _, _, _, _, _, _ in
            if requestPerformer.performRequestCallCount == 1 {
                throw SmartIdError.requestInterrupted
            }
            return expected
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
        #expect(requestPerformer.performRequestCallCount == 2)
    }

    @Test
    func getSessionRequest_throwRequestInterruptedWhenEveryRetryIsInterrupted() async {
        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            throw SmartIdError.requestInterrupted
        }

        await #expect(throws: SmartIdError.requestInterrupted) {
            try await service.getSessionRequest(
                url: url,
                sessionId: "SESSION",
                pollingTimeout: 1,
                trustedCertificates: certificates,
                proxyInfo: proxy,
                userAgent: "TestUserAgent"
            )
        }

        #expect(requestPerformer.performRequestCallCount == Constants.Signing.MaxPollRetries + 1)
    }

    @Test
    func getSessionRequest_asksAgainWhenServerReportsMaintenance() async throws {
        let expected = SmartIdSessionResponse(
            state: .complete,
            result: nil,
            signature: nil,
            cert: nil
        )

        requestPerformer.performRequestHandler = { [requestPerformer] _, _, _, _, _, _ in
            if requestPerformer.performRequestCallCount == 1 {
                throw SmartIdError.underMaintenance
            }
            return expected
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
        #expect(requestPerformer.performRequestCallCount == 2)
    }

    @Test
    func getSessionRequest_reportsExpiryWhenMaintenancePersistsAfterSessionAnswered() async {
        requestPerformer.performRequestHandler = { [requestPerformer] _, _, _, _, _, _ in
            if requestPerformer.performRequestCallCount == 1 {
                return SmartIdSessionResponse(state: .running, result: nil, signature: nil, cert: nil)
            }
            throw SmartIdError.underMaintenance
        }

        await #expect(throws: SmartIdError.timeout) {
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
    func getSessionRequest_throwUnderMaintenanceWhenEveryRetryReportsMaintenance() async {
        requestPerformer.performRequestHandler = { _, _, _, _, _, _ in
            throw SmartIdError.underMaintenance
        }

        await #expect(throws: SmartIdError.underMaintenance) {
            try await service.getSessionRequest(
                url: url,
                sessionId: "SESSION",
                pollingTimeout: 1,
                trustedCertificates: certificates,
                proxyInfo: proxy,
                userAgent: "TestUserAgent"
            )
        }

        #expect(requestPerformer.performRequestCallCount == Constants.Signing.MaxPollRetries + 1)
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
