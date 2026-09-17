// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum RecipientDecryptionStatus: Sendable {
    case notEncrypted
    case notEncryptedExpired
    case expired
    case expiredWithoutDate
    case valid

    public static func resolve(
        validTo: Date?,
        isCDOC2Container: Bool,
        isEncryptedOrDecrypted: Bool,
        now: Date = Date()
    ) -> RecipientDecryptionStatus? {
        guard isCDOC2Container, let validTo else { return nil }

        if validTo.timeIntervalSince1970 <= 0 {
            return .expiredWithoutDate
        }

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
        case .expiredWithoutDate: return "Decryption expired without date"
        case .valid: return "Decryption until"
        }
    }
}
