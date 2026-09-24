// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum DecryptError: Error {
    case containerFileInvalid
    case recipientsEmpty
    case noCertLock
    case cancelled
    case unknown(Error)
}

extension DecryptError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .containerFileInvalid:
            return "Container file is invalid"
        case .recipientsEmpty:
            return "Person or company does not own a valid certificate"
        case .noCertLock:
            return "Failed to find lock for cert"
        case .cancelled:
            return "Operation cancelled by user"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
