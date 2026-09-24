// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import nfclib

public enum IdCardError: Error {
    case cancelledByUser
    case wrongCAN
    case wrongPIN(triesLeft: Int)
    case invalidNewPIN
    case sessionError
    case pinLocked
    case notActivated
}

extension IdCardError {
    public init(_ nfcError: nfclib.IdCardError) {
        switch nfcError {
        case .wrongCAN: self = .wrongCAN
        case .wrongPIN(let tries): self = .wrongPIN(triesLeft: tries)
        case .invalidNewPIN: self = .invalidNewPIN
        case .sessionError: self = .sessionError
        @unknown default: self = .sessionError
        }
    }
}
