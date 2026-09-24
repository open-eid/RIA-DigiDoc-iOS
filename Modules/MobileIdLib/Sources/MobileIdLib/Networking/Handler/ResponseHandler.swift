// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire

struct ResponseHandler: ResponseHandlerProtocol {
    func handleSigningError<T: Decodable>(_ response: DataResponse<T, AFError>) throws {
        if let error = response.error {
            try handleCancellationError(error)
            try handleNetworkError(error, statusCode: response.response?.statusCode)
            return
        }

        let responseValue = try response.result.get()

        try handleCertificateResponse(responseValue)
        try handleSessionResponse(responseValue)
    }

    func handleCertificateResponse(_ responseValue: Any) throws {
        if let certificateResponse = responseValue as? MobileIdCertificateResponse {
            if [.notFound, .notActive].contains(certificateResponse.result) {
                throw MobileIdError.notMidClient
            }
        }
    }

    func handleSessionResponse(_ responseValue: Any) throws {
        if let sessionResponse = responseValue as? MobileIdSessionResponse {
            guard sessionResponse.state == .complete else { return }

            try handleSessionResult(sessionResponse)
        }
    }

    func handleSessionResult(_ response: MobileIdSessionResponse) throws {
        switch response.result {
        case .timeout:
            throw MobileIdError.timeout
        case .notMidClient:
            throw MobileIdError.notMidClient
        case .userCancelled:
            throw MobileIdError.userCancelled
        case .signatureHashMismatch:
            throw MobileIdError.signatureHashMismatch
        case .phoneAbsent:
            throw MobileIdError.phoneAbsent
        case .deliveryError:
            throw MobileIdError.deliveryError
        case .simError:
            throw MobileIdError.simError
        default:
            break
        }
    }

    func handleCancellationError(_ error: Error) throws {
        if let afError = error as? AFError {
            switch afError {
            case .explicitlyCancelled:
                throw MobileIdError.explicitlyCancelled
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
            throw MobileIdError.noInternetConnection
        case .timedOut:
            throw MobileIdError.timeout
        default:
            throw MobileIdError.noInternetConnection
        }
    }

    func handleStatusCodeError(_ statusCode: Int?) throws {
        switch statusCode ?? -1 {
        case 400:
            throw MobileIdError.incorrectParameters
        case 401:
            throw MobileIdError.invalidAccessRights
        case 404:
            throw MobileIdError.notMidClient
        case 409:
            throw MobileIdError.exceededUnsuccessfulRequests
        case 429:
            throw MobileIdError.tooManyRequests
        default:
            throw MobileIdError.technicalError
        }
    }
}
