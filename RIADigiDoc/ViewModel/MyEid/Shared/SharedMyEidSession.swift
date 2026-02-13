/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
import IdCardLib

@Observable
@MainActor
final class SharedMyEidSession: SharedMyEidSessionProtocol {

    var usbReaderStatus: UsbReaderStatus = .sInitial

    private var isPin1Blocked = false
    private var isPin2Blocked = false
    private var isPukBlocked = false

    private var canNumber = ""

    private var isPin1Locked = false
    private var isPin2Locked = false
    private var isPukLocked = false

    private let idCardRepository: IdCardRepositoryProtocol
    private var task: Task<Void, Never>?

    init(idCardRepository: IdCardRepositoryProtocol) {
        self.idCardRepository = idCardRepository
        startStatusStream()
    }

    public func setIsPinLocked(_ codeType: CodeType, isLocked: Bool) {
        switch codeType {
        case .pin1:
            self.isPin1Locked = isLocked
        case .pin2:
            self.isPin2Locked = isLocked
        case .puk:
            self.isPukLocked = isLocked
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
        }
    }

    private func startStatusStream() {
        task = Task {
            for await status in await idCardRepository.statusStream() {
                usbReaderStatus = status
            }
        }
    }

    public func stopStatusStream() {
        task?.cancel()
    }

    // MARK: - NFC methods

    public func setCAN(_ can: String) {
        self.canNumber = can
    }

    public func getCAN() -> String {
        self.canNumber
    }
}
