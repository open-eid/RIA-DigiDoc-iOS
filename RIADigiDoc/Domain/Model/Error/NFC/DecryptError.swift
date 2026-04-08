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
