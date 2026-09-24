// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

/// @mockable
@MainActor
public protocol SharedMyEidSessionProtocol: Sendable {
    func setIsPinLocked(_ codeType: CodeType, isLocked: Bool)
    func getIsPinLocked(for codeType: CodeType) -> Bool
    func setIsPinBlocked(_ codeType: CodeType, isBlocked: Bool)
    func getIsPinBlocked(for codeType: CodeType) -> Bool
    func setCAN(_ can: String)
    func getCAN() -> String
}
