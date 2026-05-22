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
