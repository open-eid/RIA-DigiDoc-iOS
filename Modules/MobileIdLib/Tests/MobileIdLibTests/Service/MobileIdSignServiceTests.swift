// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import MobileIdLibMocks
import CommonsLib

@testable import MobileIdLib

struct MobileIdSignServiceTests {

    private let mockRequestPerfomer: RequestPerfomerProtocolMock

    private let service: MobileIdSignServiceProtocol

    init() async throws {
        mockRequestPerfomer = RequestPerfomerProtocolMock()

        service = MobileIdSignService(
            requestPerfomer: mockRequestPerfomer
        )
    }

    @Test
    func getCertificateRequest_buildsRequestAndReturnsResponse() async throws {
        let expectedResponse = MobileIdCertificateResponse(
            result: .ok,
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        mockRequestPerfomer.performRequestHandler = { _, method, parameters, _, _, _ in

            #expect(method == .post)

            let request = parameters as? MobileIdCertificateRequest
            #expect(request?.phoneNumber == "+372000000")
            #expect(request?.nationalIdentityNumber == "12345678901")

            return expectedResponse
        }

        let response = try await service.getCertificateRequest(
            url: "https://url.test",
            relyingPartyName: "RP",
            relyingPartyUUID: "UUID",
            phoneNumber: "372000000",
            nationalIdentityNumber: "12345678901",
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "MobileIdSignServiceTestsUserAgent"
        )

        #expect(response.result == .ok)
    }

    @Test
    func getSignatureRequest_encodesHashAndReturnsResponse() async throws {
        let hash = Data([0x01, 0x02, 0x03])
        let expectedSessionID = "session123"
        let expectedResponse = MobileIdSignatureResponse(
            sessionID: expectedSessionID
        )

        mockRequestPerfomer.performRequestHandler = { _, _, parameters, _, _, _ in

            let request = parameters as? MobileIdSignatureRequest

            #expect(request?.hash == hash.base64EncodedString())
            #expect(request?.language == "ENG")
            #expect(request?.displayText == "Sign")

            return expectedResponse
        }

        let response = try await service.getSignatureRequest(
            url: "https://url.test",
            relyingPartyName: "RP",
            relyingPartyUUID: "UUID",
            phoneNumber: "372000000",
            nationalIdentityNumber: "12345678901",
            hash: hash,
            hashType: "SHA256",
            language: "ENG",
            displayText: "Sign",
            displayTextFormat: "GSM-7",
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "MobileIdSignServiceTestsUserAgent"
        )

        #expect(response.sessionID == expectedSessionID)
    }

    @Test
    func getSessionRequest_returnsWhenStateIsComplete() async throws {
        let completedResponse = MobileIdSessionResponse(
            state: .complete,
            result: .ok,
            signature: MobileIdSessionSignatureResponse(
                value: Data([0xAA, 0xBB]),
                algorithm: "TestAlgorithm"
            ),
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        mockRequestPerfomer.performRequestHandler = { _, method, _, _, _, _ in
            #expect(method == .get)
            return completedResponse
        }

        let response = try await service.getSessionRequest(
            url: "https://url.test/session",
            sessionId: "abc",
            pollingTimeout: 1,
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "MobileIdSignServiceTestsUserAgent"
        )

        #expect(response.state == .complete)
        #expect(mockRequestPerfomer.performRequestCallCount == 1)
    }

    @Test
    func getVerificationCode_success() async {
        let hash = Data([0xAA, 0xBB])
        let code = await service.getVerificationCode(hash: hash)

        #expect(code?.count == 4)
    }

    @Test
    func getVerificationCode_returnsNilForEmptyHash() async {
        let code = await service.getVerificationCode(hash: Data())

        #expect(code == nil)
    }

    @Test
    func getSessionRequest_retriesPollWhenRequestIsInterrupted() async throws {
        let completedResponse = MobileIdSessionResponse(
            state: .complete,
            result: .ok,
            signature: MobileIdSessionSignatureResponse(
                value: Data([0xAA, 0xBB]),
                algorithm: "TestAlgorithm"
            ),
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        mockRequestPerfomer.performRequestHandler = { [mockRequestPerfomer] _, _, _, _, _, _ in
            if mockRequestPerfomer.performRequestCallCount == 1 {
                throw MobileIdError.requestInterrupted
            }
            return completedResponse
        }

        let response = try await service.getSessionRequest(
            url: "https://url.test/session",
            sessionId: "abc",
            pollingTimeout: 1,
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "MobileIdSignServiceTestsUserAgent"
        )

        #expect(response.state == .complete)
        #expect(mockRequestPerfomer.performRequestCallCount == 2)
    }

    @Test
    func getSessionRequest_throwsRequestInterruptedWhenEveryRetryIsInterrupted() async {
        mockRequestPerfomer.performRequestHandler = { _, _, _, _, _, _ in
            throw MobileIdError.requestInterrupted
        }

        await #expect(throws: MobileIdError.requestInterrupted) {
            try await service.getSessionRequest(
                url: "https://url.test/session",
                sessionId: "abc",
                pollingTimeout: 1,
                trustedCertificates: [],
                proxyInfo: ProxyInfo(),
                userAgent: "MobileIdSignServiceTestsUserAgent"
            )
        }

        #expect(mockRequestPerfomer.performRequestCallCount == Constants.Signing.MaxPollRetries + 1)
    }

    @Test
    func getSessionRequest_resetsRetryCountAfterASuccessfulPoll() async throws {
        let runningResponse = MobileIdSessionResponse(
            state: .running,
            result: nil,
            signature: nil,
            cert: nil,
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )
        let completedResponse = MobileIdSessionResponse(
            state: .complete,
            result: .ok,
            signature: MobileIdSessionSignatureResponse(
                value: Data([0xAA, 0xBB]),
                algorithm: "TestAlgorithm"
            ),
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        // Interrupt, recover, interrupt again: the second run of interruptions must get a full
        // retry budget, so the poll still completes instead of giving up.
        mockRequestPerfomer.performRequestHandler = { [mockRequestPerfomer] _, _, _, _, _, _ in
            switch mockRequestPerfomer.performRequestCallCount {
            case 1, 2, 3, 5, 6, 7:
                throw MobileIdError.requestInterrupted
            case 4:
                return runningResponse
            default:
                return completedResponse
            }
        }

        let response = try await service.getSessionRequest(
            url: "https://url.test/session",
            sessionId: "abc",
            pollingTimeout: 1,
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "MobileIdSignServiceTestsUserAgent"
        )

        #expect(response.state == .complete)
        #expect(mockRequestPerfomer.performRequestCallCount == 8)
    }

    @Test
    func getSessionRequest_endsWithCancellationErrorWhenTaskIsCancelled() async {
        // Tearing the signing screen down (for example when a container opened from another app
        // replaces the one being signed) cancels the task mid-poll. That must surface as a
        // CancellationError, which the view model swallows, and never as a MobileIdError that
        // would show the user an error about the container they just left.
        mockRequestPerfomer.performRequestHandler = { _, _, _, _, _, _ in
            throw MobileIdError.requestInterrupted
        }

        let task = Task { [service] in
            try await service.getSessionRequest(
                url: "https://url.test/session",
                sessionId: "abc",
                pollingTimeout: 1,
                trustedCertificates: [],
                proxyInfo: ProxyInfo(),
                userAgent: "MobileIdSignServiceTestsUserAgent"
            )
        }
        task.cancel()

        await #expect(throws: CancellationError.self) {
            _ = try await task.value
        }
    }
}
