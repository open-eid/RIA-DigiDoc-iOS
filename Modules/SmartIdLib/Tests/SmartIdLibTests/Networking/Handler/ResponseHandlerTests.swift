// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
            try handler.handleNetworkError(afError, statusCode: nil)
        }
    }

    @Test
    func handleNetworkError_throwsTimeoutWhenSessionTaskFailedErrorWithTimeout() {
        let urlError = URLError(.timedOut)
        let afError = AFError.sessionTaskFailed(error: urlError)

        #expect(throws: SmartIdError.timeout) {
            try handler.handleNetworkError(afError, statusCode: nil)
        }
    }

    @Test
    func handleNetworkError_throwsInvalidAccessRightsWhenUnacceptableStatusCode401Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))

        #expect(throws: SmartIdError.invalidAccessRights) {
            try handler.handleNetworkError(afError, statusCode: 401)
        }
    }

    @Test
    func handleNetworkError_throwsIncorrectParametersWhenUnacceptableStatusCode400Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400))

        #expect(throws: SmartIdError.incorrectParameters) {
            try handler.handleNetworkError(afError, statusCode: 400)
        }
    }

    @Test
    func handleNetworkError_throwsTechnicalErrorWhenUnacceptableStatusCode999Returned() {
        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 999))

        #expect(throws: SmartIdError.technicalError) {
            try handler.handleNetworkError(afError, statusCode: 999)
        }
    }
}
