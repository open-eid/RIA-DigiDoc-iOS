// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
