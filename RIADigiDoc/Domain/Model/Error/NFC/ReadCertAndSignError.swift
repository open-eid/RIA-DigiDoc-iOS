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
import IdCardLib

public enum ReadCertAndSignError: Error {
    case signedContainerNil
    case roleDataNil
    case containerPathNil
    case userAgentEmpty
    case certMismatch
    case hashInvalid
    case invalidCertificate
    case missingPublicKey
    case unsupportedAlgorithm
    case cancelled
    case unknown(Error)
}

extension ReadCertAndSignError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .signedContainerNil:
            return "Signed container is nil"
        case .roleDataNil:
            return "Role data is nil"
        case .containerPathNil:
            return "Container path is nil"
        case .userAgentEmpty:
            return "User agent is empty"
        case .certMismatch:
            return "Web eID signing certificate mismatch"
        case .hashInvalid:
            return "Invalid hash encoding"
        case .invalidCertificate:
            return "Invalid X.509 certificate"
        case .missingPublicKey:
            return "Certificate public key is missing"
        case .unsupportedAlgorithm:
            return "Unsupported algorithm"
        case .cancelled:
            return "Operation cancelled by user"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
