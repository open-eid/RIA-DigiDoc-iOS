// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Testing

@MainActor
final class SharedMyEidSessionTests {
    private let sharedMyEidSession: SharedMyEidSession

    init() async throws {
        sharedMyEidSession = SharedMyEidSession()
    }

    // MARK: - PIN1 tests

    @Test
    func setIsPinBlocked_pin1Success() {
        sharedMyEidSession.setIsPinBlocked(.pin1, isBlocked: true)

        let result = sharedMyEidSession.getIsPinBlocked(for: .pin1)

        #expect(result == true)
    }

    @Test
    func getIsPinBlocked_pin1ReturnsFalseByDefault() {
        let result = sharedMyEidSession.getIsPinBlocked(for: .pin1)

        #expect(result == false)
    }

    @Test
    func setIsPinBlocked_pin1CanBeUnblocked() {
        sharedMyEidSession.setIsPinBlocked(.pin1, isBlocked: true)
        sharedMyEidSession.setIsPinBlocked(.pin1, isBlocked: false)

        let result = sharedMyEidSession.getIsPinBlocked(for: .pin1)

        #expect(result == false)
    }

    // MARK: - PIN2 tests

    @Test
    func setIsPinBlocked_pin2Success() {
        sharedMyEidSession.setIsPinBlocked(.pin2, isBlocked: true)

        let result = sharedMyEidSession.getIsPinBlocked(for: .pin2)

        #expect(result == true)
    }

    @Test
    func getIsPinBlocked_pin2ReturnsFalseByDefault() {
        let result = sharedMyEidSession.getIsPinBlocked(for: .pin2)

        #expect(result == false)
    }

    @Test
    func setIsPinBlocked_pin2CanBeUnblocked() {
        sharedMyEidSession.setIsPinBlocked(.pin2, isBlocked: true)
        sharedMyEidSession.setIsPinBlocked(.pin2, isBlocked: false)

        let result = sharedMyEidSession.getIsPinBlocked(for: .pin2)

        #expect(result == false)
    }

    // MARK: - PUK tests

    @Test
    func setIsPinBlocked_pukSuccess() {
        sharedMyEidSession.setIsPinBlocked(.puk, isBlocked: true)

        let result = sharedMyEidSession.getIsPinBlocked(for: .puk)

        #expect(result == true)
    }

    @Test
    func getIsPinBlocked_pukReturnsFalseByDefault() {
        let result = sharedMyEidSession.getIsPinBlocked(for: .puk)

        #expect(result == false)
    }

    @Test
    func setIsPinBlocked_pukCanBeUnblocked() {
        sharedMyEidSession.setIsPinBlocked(.puk, isBlocked: true)
        sharedMyEidSession.setIsPinBlocked(.puk, isBlocked: false)

        let result = sharedMyEidSession.getIsPinBlocked(for: .puk)

        #expect(result == false)
    }

    // MARK: - CAN tests

    @Test
    func setCAN_success() {
        let testCAN = "123456"

        sharedMyEidSession.setCAN(testCAN)

        let result = sharedMyEidSession.getCAN()

        #expect(result == testCAN)
    }

    @Test
    func getCAN_returnsEmptyStringByDefault() {
        let result = sharedMyEidSession.getCAN()

        #expect(result == "")
    }

    @Test
    func setCAN_canBeUpdated() {
        let firstCAN = "111111"
        let secondCAN = "222222"

        sharedMyEidSession.setCAN(firstCAN)
        sharedMyEidSession.setCAN(secondCAN)

        let result = sharedMyEidSession.getCAN()

        #expect(result == secondCAN)
    }
}
