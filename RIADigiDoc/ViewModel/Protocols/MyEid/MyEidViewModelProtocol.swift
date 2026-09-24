// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

/// @mockable
@MainActor
public protocol MyEidViewModelProtocol: Sendable {
    func parseDateOfBirth(personalCode: String) -> String
    func parseExpiryDate(expiryDate: String) -> String
    func getDocumentExpirationStatus(expiryDate: String) -> MyEidDocumentStatus
    func setIsPinBlocked(_ codeType: CodeType, isBlocked: Bool)
    func getIsPinBlocked(for codeType: CodeType) -> Bool
}
