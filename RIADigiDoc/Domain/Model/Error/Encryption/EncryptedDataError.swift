// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum EncryptedDataError: Error, LocalizedError {
    case unableToLocateAppSupportDirectory
    case keyFileDoesNotExist
    case encryptionFailed
    case decryptionFailed

    public var errorDescription: String? {
        switch self {
        case .unableToLocateAppSupportDirectory:
            return "Unable to locate Application Support directory"
        case .keyFileDoesNotExist:
            return "Encryption key file does not exist"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        }
    }
}
