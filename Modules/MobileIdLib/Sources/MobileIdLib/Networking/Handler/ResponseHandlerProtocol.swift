// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire

/// @mockable
public protocol ResponseHandlerProtocol: Sendable {
    func handleSigningError<T: Decodable>(_ response: DataResponse<T, AFError>) throws
    func handleCertificateResponse(_ responseValue: Any) throws
    func handleSessionResponse(_ responseValue: Any) throws
    func handleSessionResult(_ response: MobileIdSessionResponse) throws
    func handleCancellationError(_ error: Error) throws
    func handleNetworkError(_ error: AFError, statusCode: Int?) throws
    func handleURLError(_ error: URLError) throws
    func handleStatusCodeError(_ statusCode: Int?) throws
}
