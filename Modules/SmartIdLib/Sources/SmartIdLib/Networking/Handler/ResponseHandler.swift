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

    func handleNetworkError(_ error: AFError, statusCode: Int?) throws {
        if let underlyingError = error.underlyingError as? URLError {
            try handleURLError(underlyingError)
        } else {
            try handleStatusCodeError(statusCode)
        }
    }

    func handleURLError(_ error: URLError) throws {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            throw SmartIdError.noInternetConnection
        case .timedOut:
            throw SmartIdError.timeout
        default:
            throw SmartIdError.noInternetConnection
        }
    }

    func handleStatusCodeError(_ statusCode: Int?) throws {
        switch statusCode ?? -1 {
        case 400:
            throw SmartIdError.incorrectParameters
        case 401:
            throw SmartIdError.invalidAccessRights
        case 409:
            throw SmartIdError.exceededUnsuccessfulRequests
        case 429:
            throw SmartIdError.tooManyRequests
        case 480:
            throw SmartIdError.oldApi
        case 580:
            throw SmartIdError.underMaintenance
        default:
            throw SmartIdError.technicalError
        }
    }
}
