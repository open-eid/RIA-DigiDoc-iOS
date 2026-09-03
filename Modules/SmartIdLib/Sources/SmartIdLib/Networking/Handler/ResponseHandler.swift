// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire

struct ResponseHandler: ResponseHandlerProtocol {
    func handleSessionResponse(_ responseValue: Any) throws {
        if let sessionResponse = responseValue as? SmartIdSessionResponse {
            guard sessionResponse.state == .complete else { return }

            guard let endResult = sessionResponse.result?.endResult else { return }

            try handleSessionResult(endResult)
        }
    }

    func handleSessionResult(_ response: SmartIdSessionStatusResponseCode) throws {
        switch response {
        case .timeout: throw SmartIdError.timeout
        case .userRefused,
                .userRefusedDisplayTextAndPin,
                .userRefusedVcChoice,
                .userRefusedConfirmationMessage,
                .userRefusedConfirmationMessageWithVcChoice,
                .userRefusedCertChoice:
            throw SmartIdError.userRefused
        case .wrongVc: throw SmartIdError.wrongVC
        case .documentUnusable: throw SmartIdError.documentUnusable
        case .requiredInteractionNotSupportedByApp: throw SmartIdError.oldApi
        case .unknown: throw SmartIdError.technicalError
        default: break
        }
    }

    func handleCancellationError(_ error: Error) throws {
        if let afError = error as? AFError {
            switch afError {
            case .explicitlyCancelled:
                throw SmartIdError.explicitlyCancelled
            default:
                return
            }
        }
    }

    func handleNetworkError(_ error: AFError, statusCode: Int?, responseType: Any.Type) throws {
        if let underlyingError = error.underlyingError as? URLError {
            try handleURLError(underlyingError)
        } else {
            try handleStatusCodeError(statusCode, responseType: responseType)
        }
    }

    func handleURLError(_ error: URLError) throws {
        switch error.code {
        case .notConnectedToInternet:
            throw SmartIdError.noInternetConnection
        case .networkConnectionLost, .timedOut:
            throw SmartIdError.requestInterrupted
        default:
            throw SmartIdError.noInternetConnection
        }
    }

    func handleStatusCodeError(_ statusCode: Int?, responseType: Any.Type) throws {
        guard let statusCode else {
            throw SmartIdError.requestInterrupted
        }

        switch statusCode {
        case 400:
            throw SmartIdError.incorrectParameters
        case 401, 403:
            throw SmartIdError.invalidAccessRights
        case 404:
            throw responseType == SmartIdSessionResponse.self ?
                SmartIdError.sessionNotFound :
                SmartIdError.accountNotFound
        case 409:
            throw SmartIdError.exceededUnsuccessfulRequests
        case 429:
            throw SmartIdError.tooManyRequests
        case 471:
            throw SmartIdError.notQualified
        case 480:
            throw SmartIdError.oldApi
        case 580:
            throw SmartIdError.underMaintenance
        default:
            throw SmartIdError.technicalError
        }
    }
}
