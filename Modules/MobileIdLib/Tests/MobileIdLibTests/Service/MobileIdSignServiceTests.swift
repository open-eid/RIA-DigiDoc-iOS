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

        mockRequestPerfomer.performRequestHandler = { _, method, parameters, _, _ in

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
            proxyInfo: ProxyInfo()
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

        mockRequestPerfomer.performRequestHandler = { _, _, parameters, _, _ in

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
            proxyInfo: ProxyInfo()
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

        mockRequestPerfomer.performRequestHandler = { _, method, _, _, _ in
            #expect(method == .get)
            return completedResponse
        }

        let response = try await service.getSessionRequest(
            url: "https://url.test/session",
            sessionId: "abc",
            pollingTimeout: 1,
            trustedCertificates: [],
            proxyInfo: ProxyInfo()
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
}
