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

import nfclib

public enum IdCardInternalError: Error {
    case missingRESTag
    case missingMACTag
    case invalidMACValue
    case failedReadingField(nfclib.CardField)
    case hexConversionFailed
    case AESCBCError
    case sendCommandFailed(message: String)
    case invalidResponse(message: String)
    case swError(UInt16)
    case pinVerificationFailed
    case remainingPinRetryCount(Int)
    case invalidNewPin
    case notSupportedCodeType
    case dataPaddingError
    case invalidAPDU
    case authenticationFailed
    case canAuthenticationFailed
    case invalidTag
    case cardNotSupported
    case nfcNotSupported
    case connectionFailed
    case multipleTagsDetected
    case couldNotVerifyChipsMAC
    case cancelledByUser
    case sessionInvalidated
    case readerProcessFailed
    case failedToRemovePadding
    case notSupportedAlgorithm
    case pinLocked
    case notActivated

    public func getIdCardError() -> IdCardError {
        switch self {
        case .canAuthenticationFailed:
            return .wrongCAN
        case .remainingPinRetryCount(let count):
            return .wrongPIN(triesLeft: count)
        case .pinVerificationFailed:
            return .wrongPIN(triesLeft: 0)
        case .pinLocked:
            return .pinLocked
        case .notActivated:
            return .notActivated
        case .cancelledByUser:
            return .cancelledByUser
        case .invalidNewPin:
            return .invalidNewPIN
        default:
            return .sessionError
        }
    }
}
