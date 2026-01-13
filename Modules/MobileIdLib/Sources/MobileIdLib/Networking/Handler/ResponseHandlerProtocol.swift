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
