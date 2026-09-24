// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

@Observable
@MainActor
final class SharedMyEidSession: SharedMyEidSessionProtocol {

    private var isPin1Blocked = false
    private var isPin2Blocked = false
    private var isPukBlocked = false

    private var canNumber = ""

    private var isPin1Locked = false
    private var isPin2Locked = false
    private var isPukLocked = false

    init() { }

    public func setIsPinLocked(_ codeType: CodeType, isLocked: Bool) {
        switch codeType {
        case .pin1:
            self.isPin1Locked = isLocked
        case .pin2:
            self.isPin2Locked = isLocked
        case .puk:
            self.isPukLocked = isLocked
        @unknown default:
            break
        }
    }

    public func getIsPinLocked(for codeType: CodeType) -> Bool {
        switch codeType {
        case .pin1:
            return self.isPin1Locked
        case .pin2:
            return self.isPin2Locked
        case .puk:
            return self.isPukLocked
        @unknown default:
            return false
        }
    }

    public func setIsPinBlocked(_ codeType: CodeType, isBlocked: Bool) {
        switch codeType {
        case .pin1:
            self.isPin1Blocked = isBlocked
        case .pin2:
            self.isPin2Blocked = isBlocked
        case .puk:
            self.isPukBlocked = isBlocked
        @unknown default:
            break
        }
    }

    public func getIsPinBlocked(for codeType: CodeType) -> Bool {
        switch codeType {
        case .pin1:
            return self.isPin1Blocked
        case .pin2:
            return self.isPin2Blocked
        case .puk:
            return self.isPukBlocked
        @unknown default:
            return false
        }
    }

    public func setCAN(_ can: String) {
        self.canNumber = can
    }

    public func getCAN() -> String {
        self.canNumber
    }
}
