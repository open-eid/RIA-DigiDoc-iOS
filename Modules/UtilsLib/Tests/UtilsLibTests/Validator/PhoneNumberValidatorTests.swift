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
import Testing
import CommonsLib

@testable import UtilsLib

struct PhoneNumberValidatorTests {

    @Test
    func isCountryCodeCorrect_returnTrueWithAllowedCountryCode() {
        let phoneNumber = "37251234567"

        let result = PhoneNumberValidator.isCountryCodeCorrect(phoneNumber)

        #expect(result == true)
    }

    @Test
    func isCountryCodeCorrect_returnFalseWithNotAllowedCountryCode() {
        let phoneNumber = "99951234567"

        let result = PhoneNumberValidator.isCountryCodeCorrect(phoneNumber)

        #expect(result == false)
    }

    @Test
    func isCountryCodeMissing_returnTrueMissingCountryCode() {
        let phoneNumber = "5123456"

        let result = PhoneNumberValidator.isCountryCodeMissing(phoneNumber)

        #expect(result == true)
    }

    @Test
    func isCountryCodeMissing_returnFalseWithCountryCodePresent() {
        let phoneNumber = "37251234567"

        let result = PhoneNumberValidator.isCountryCodeMissing(phoneNumber)

        #expect(result == false)
    }

    @Test
    func isCountryCodeMissing_returnFalseWithTooShortPhoneNumber() {
        let phoneNumber = "123"

        let result = PhoneNumberValidator.isCountryCodeMissing(phoneNumber)

        #expect(result == false)
    }

    @Test
    func isCountryCodeMissing_returnFalseWithoutCountryCode() {
        let phoneNumber = "512345678901"

        let result = PhoneNumberValidator.isCountryCodeMissing(phoneNumber)

        #expect(result == false)
    }

    // MARK: - isPhoneNumberCorrect

    @Test
    func isPhoneNumberCorrect_success() {
        let phoneNumber = "37251234567"

        let result = PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber)

        #expect(result == true)
    }

    @Test
    func isPhoneNumberCorrect_returnTrueWhenPhoneNumberLongerThanMinimum() {
        let phoneNumber = "37251234567890"

        let result = PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber)

        #expect(result == true)
    }

    @Test
    func isPhoneNumberCorrect_returnFalseWhenPhoneNumberShorterThanMinimumRequirement() {
        let phoneNumber = "37251234"

        let result = PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber)

        #expect(result == false)
    }

    @Test
    func phoneNumberValidator_successWithMulipleConditions() {
        let phoneNumber = "37251234567"

        #expect(PhoneNumberValidator.isCountryCodeCorrect(phoneNumber) == true)
        #expect(PhoneNumberValidator.isCountryCodeMissing(phoneNumber) == false)
        #expect(PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber) == true)
    }

    @Test
    func phoneNumberValidator_unsuccessfulWithMissingCountryCode() {
        let phoneNumber = "5123456"

        #expect(PhoneNumberValidator.isCountryCodeCorrect(phoneNumber) == false)
        #expect(PhoneNumberValidator.isCountryCodeMissing(phoneNumber) == true)
        #expect(PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber) == false)
    }
}
