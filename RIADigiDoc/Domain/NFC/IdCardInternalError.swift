// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
