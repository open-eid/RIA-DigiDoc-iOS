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

@testable import UtilsLib

struct PersonalCodeValidatorTests {

    @Test
    func isPersonalCodeValid_returnTrueWithValidEstonianPersonalCode() {
        let personalCode = "60001019906"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == true)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithInvalidLength() {
        let personalCode = "6000101990"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithNonNumericPersonalCode() {
        let personalCode = "60A01019906"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithInvalidBirthDate() {
        let personalCode = "39999019906"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithFutureBirthDate() {
        let personalCode = "69901019906"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithInvalidChecksum() {
        let personalCode = "60001019907"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnTrueWithValidLatvianPersonalCode() {
        let personalCode = "010101-12345"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == true)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithInvalidLatvianPersonalCodeFormat() {
        let personalCode = "01010112345"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithInvalidLatvianPersonalCodeLength() {
        let personalCode = "0101-123"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithEmptyString() {
        let result = PersonalCodeValidator.isPersonalCodeValid("")

        #expect(result == false)
    }

    @Test
    func isPersonalCodeValid_returnFalseWithUnknownCenturyDigit() {
        let personalCode = "90001019906"

        let result = PersonalCodeValidator.isPersonalCodeValid(personalCode)

        #expect(result == false)
    }
}
