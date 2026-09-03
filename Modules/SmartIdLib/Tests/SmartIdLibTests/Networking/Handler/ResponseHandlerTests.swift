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

import Testing
import Foundation
import Alamofire
import SmartIdLibMocks

@testable import SmartIdLib

struct ResponseHandlerTests {
    private let handler: ResponseHandlerProtocol

    init() async throws {
        handler = ResponseHandler()
    }

    @Test
    func handleSessionResponse_doesNotThrowWhenComplete() {
        #expect(throws: Never.self) {
            try handler.handleSessionResponse(
                SmartIdSessionResponse(
                    state: .complete,
                    result: .init(
                        endResult: .ok,
                        documentNumber: "TestDocumentNumber"
                    ),
                    signature: SmartIdSessionSignatureResponse(
                        value: Data([1, 2, 3]),
                        algorithm: "TestAlgorithm"
                    ),
                    cert: SmartIdSessionCertResponse(
                        value: Data([1, 2, 3]),
                        certificateLevel: .ADVANCED
                    )
                )
            )
        }
    }

    @Test
    func handleSessionResponse_throwsTimeoutWhenEndResultTimeout() {

        let response = SmartIdSessionResponse(
            state: .complete,
            result: .init(
                endResult: .timeout,
                documentNumber: "TestDocumentNumber"
            ),
            signature: nil,
            cert: nil
        )

        #expect(throws: SmartIdError.timeout) {
            try handler.handleSessionResponse(response)
        }
    }

    @Test
    func handleSessionResponse_doesNotThrowWhenSessionIncomplete() {
        let response = SmartIdSessionResponse(
            state: .running,
            result: .init(
                endResult: .timeout,
                documentNumber: "TestDocumentNumber"
            ),
            signature: nil,
            cert: nil
        )

        #expect(throws: Never.self) {
            try handler.handleSessionResponse(response)
        }
    }

    @Test
    func handleSessionResponse_doesNotThrowWhenCompleteWithoutResult() {
        let response = SmartIdSessionResponse(
            state: .complete,
            result: nil,
            signature: nil,
            cert: nil
        )

        #expect(throws: Never.self) {
            try handler.handleSessionResponse(response)
        }
    }

    @Test
    func handleSessionResponse_throwsUserRefusedWhenCompleteWithUserRefused() {
        let response = SmartIdSessionResponse(
            state: .complete,
            result: .init(
                endResult: .userRefused,
                documentNumber: "TestDocumentNumber"
            ),
            signature: nil,
            cert: nil
        )

        #expect(throws: SmartIdError.userRefused) {
            try handler.handleSessionResponse(response)
        }
    }

    @Test
    func handleSessionResult_doesNotThrowWhenResponseOk() {
        #expect(throws: Never.self) {
            try handler.handleSessionResult(.ok)
        }
    }

    @Test
    func handleSessionResult_throwsWrongVCWhenResponseWrongVc() {
        #expect(throws: SmartIdError.wrongVC) {
            try handler.handleSessionResult(.wrongVc)
        }
    }

    @Test
    func handleSessionResult_throwsDocumentUnusableWhenResponseDocumentUnusable() {
        #expect(throws: SmartIdError.documentUnusable) {
            try handler.handleSessionResult(.documentUnusable)
        }
    }

    @Test
    func handleCancellationError_throwsExplicitlyCancelledWhenExplicitlyCancelled() {
        let error = AFError.explicitlyCancelled

        #expect(throws: SmartIdError.explicitlyCancelled) {
            try handler.handleCancellationError(error)
        }
    }

    @Test
    func handleCancellationError_doesNotThrowWithSessionTaskFailedError() {
        let error = AFError.sessionTaskFailed(error: URLError(.badURL))

        #expect(throws: Never.self) {
            try handler.handleCancellationError(error)
        }
    }

    @Test
    func handleNetworkError_throwsNoInternetConnectionWhenNoInternetConnection() {
        let urlError = URLError(.notConnectedToInternet)
        let afError = AFError.sessionTaskFailed(error: urlError)

        #expect(throws: SmartIdError.noInternetConnection) {
            try handler.handleNetworkError(afError, statusCode: nil, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsTimeoutWhenSessionTaskFailedErrorWithTimeout() {
        let urlError = URLError(.timedOut)
        let afError = AFError.sessionTaskFailed(error: urlError)

        #expect(throws: SmartIdError.timeout) {
            try handler.handleNetworkError(afError, statusCode: nil, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsInvalidAccessRightsWhenUnacceptableStatusCode401Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))

        #expect(throws: SmartIdError.invalidAccessRights) {
            try handler.handleNetworkError(afError, statusCode: 401, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsIncorrectParametersWhenUnacceptableStatusCode400Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400))

        #expect(throws: SmartIdError.incorrectParameters) {
            try handler.handleNetworkError(afError, statusCode: 400, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsNotQualifiedWhenUnacceptableStatusCode471Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 471))

        #expect(throws: SmartIdError.notQualified) {
            try handler.handleNetworkError(afError, statusCode: 471, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsAccountNotFoundWhenStatusCode404ReturnedForSignatureRequest() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))

        #expect(throws: SmartIdError.accountNotFound) {
            try handler.handleNetworkError(afError, statusCode: 404, responseType: SmartIdSessionIdResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsSessionNotFoundWhenStatusCode404ReturnedForSessionStatusRequest() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))

        #expect(throws: SmartIdError.sessionNotFound) {
            try handler.handleNetworkError(afError, statusCode: 404, responseType: SmartIdSessionResponse.self)
        }
    }

    @Test
    func handleNetworkError_throwsTechnicalErrorWhenUnacceptableStatusCode999Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 999))

        #expect(throws: SmartIdError.technicalError) {
            try handler.handleNetworkError(afError, statusCode: 999, responseType: SmartIdSessionIdResponse.self)
        }
    }
}
