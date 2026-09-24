// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import Alamofire
import MobileIdLibMocks

@testable import MobileIdLib

struct ResponseHandlerTests {
    private let handler: ResponseHandlerProtocol

    init() async throws {
        handler = ResponseHandler()
    }

    @Test
    func handleCancellationError_doesNotThrowError() {
        let afError = AFError.sessionTaskFailed(error: URLError(.timedOut))

        #expect(throws: Never.self) {
            try handler.handleCancellationError(afError)
        }
    }

    @Test
    func handleCancellationError_throwsExplicitlyCancelledError() {
        let afError = AFError.explicitlyCancelled

        #expect(throws: MobileIdError.explicitlyCancelled) {
            try handler.handleCancellationError(afError)
        }
    }

    @Test
    func handleNetworkError_throwsNoInternetError() {
        let afError = AFError.sessionTaskFailed(error: URLError(.notConnectedToInternet))

        #expect(throws: MobileIdError.noInternetConnection) {
            try handler.handleNetworkError(afError, statusCode: nil)
        }
    }

    @Test
    func handleNetworkError_throwsTimeoutError() {
        let afError = AFError.sessionTaskFailed(error: URLError(.timedOut))

        #expect(throws: MobileIdError.timeout) {
            try handler.handleNetworkError(afError, statusCode: nil)
        }
    }

    @Test
    func handleStatusCodeError_throwsStatusCodeErrors() {
        #expect(throws: MobileIdError.incorrectParameters) { try handler.handleStatusCodeError(400) }
        #expect(throws: MobileIdError.invalidAccessRights) { try handler.handleStatusCodeError(401) }
        #expect(throws: MobileIdError.exceededUnsuccessfulRequests) { try handler.handleStatusCodeError(409) }
        #expect(throws: MobileIdError.tooManyRequests) { try handler.handleStatusCodeError(429) }
        #expect(throws: MobileIdError.technicalError) { try handler.handleStatusCodeError(500) }
    }

    @Test
    func handleCertificateResponse_doesNotThrowError() {
        let response = MobileIdCertificateResponse(
            result: .ok,
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        #expect(throws: Never.self) {
            try handler.handleCertificateResponse(response)
        }
    }

    @Test
    func handleCertificateResponse_throwsNotMidClientError() {
        let response = MobileIdCertificateResponse(
            result: .notFound,
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        #expect(throws: MobileIdError.notMidClient) {
            try handler.handleCertificateResponse(response)
        }

        let response2 = MobileIdCertificateResponse(
            result: .notActive,
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        #expect(throws: MobileIdError.notMidClient) {
            try handler.handleCertificateResponse(response2)
        }
    }

    @Test
    func handleSessionResponse_throwsTimeoutError() {
        let sessionResponse = MobileIdSessionResponse(
            state: .complete,
            result: .timeout,
            signature: MobileIdSessionSignatureResponse(
                value: Data([1, 2, 3]),
                algorithm: "TestAlgorithm"
            ),
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        #expect(throws: MobileIdError.timeout) {
            try handler.handleSessionResponse(sessionResponse)
        }
    }

    @Test
    func handleSessionResponse_throwsUserCancelledError() {
        let sessionResponse = MobileIdSessionResponse(
            state: .complete,
            result: .userCancelled,
            signature: MobileIdSessionSignatureResponse(
                value: Data([1, 2, 3]),
                algorithm: "TestAlgorithm"
            ),
            cert: "TestCert",
            time: Date.now.formatted(),
            traceId: "TestTraceId"
        )

        #expect(throws: MobileIdError.userCancelled) {
            try handler.handleSessionResponse(sessionResponse)
        }
    }
}
