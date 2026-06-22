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
