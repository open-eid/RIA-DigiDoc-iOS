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

import SwiftUI
import LibdigidocLibSwift

struct SignatureUtil: SignatureUtilProtocol {
    func getSignatureStatusText(status: SignatureStatus, isTimestamp: Bool) -> String {
        switch status {
            case .valid:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid"
            case .warning:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid with warnings"
            case .nonQSCD:
                return isTimestamp ? "Timestamp is valid" : "Signature is valid non qscd"
            case .invalid:
                return isTimestamp ? "Timestamp is invalid" : "Signature is invalid"
            case .unknown:
                return isTimestamp ? "Timestamp is unknown" : "Signature is unknown"
            }
    }
}
