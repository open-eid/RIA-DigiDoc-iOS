// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

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
