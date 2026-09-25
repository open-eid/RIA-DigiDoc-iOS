// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum ChangePinError: Error {
    case missingRequiredParameter
    case cancelled
    case unknown(Error)
}

extension ChangePinError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingRequiredParameter:
            return "Missing required parameter"
        case .cancelled:
            return "Operation cancelled by user"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
