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

public enum RecipientDecryptionStatus: Sendable {
    case notEncrypted
    case notEncryptedExpired
    case expired
    case valid

    public static func resolve(
        validTo: Date?,
        isCDOC2Container: Bool,
        isEncryptedOrDecrypted: Bool,
        now: Date = Date()
    ) -> RecipientDecryptionStatus? {
        guard isCDOC2Container, let validTo else { return nil }

        let isExpired = validTo < now

        switch (isEncryptedOrDecrypted, isExpired) {
        case (false, true): return .notEncryptedExpired
        case (false, false): return .notEncrypted
        case (true, true): return .expired
        case (true, false): return .valid
        }
    }

    public static func allExpiredDate(
        validTos: [Date?],
        isCDOC2Container: Bool,
        now: Date = Date()
    ) -> Date? {
        guard isCDOC2Container, !validTos.isEmpty else { return nil }

        guard validTos.allSatisfy({ validTo in
            guard let validTo else { return false }
            return validTo < now
        }) else {
            return nil
        }

        return validTos.compactMap { $0 }.max()
    }

    public var localizationKey: String {
        switch self {
        case .notEncrypted: return "Expires on"
        case .notEncryptedExpired: return "Expired on"
        case .expired: return "Decryption expired"
        case .valid: return "Decryption until"
        }
    }
}
