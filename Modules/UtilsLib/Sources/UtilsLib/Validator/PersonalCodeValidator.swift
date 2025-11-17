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
import OSLog
import CommonsLib

public struct PersonalCodeValidator {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "PersonalCodeValidator")

    public static func isPersonalCodeValid(_ personalCode: String) -> Bool {
        return (
            isPersonalCodeLengthValid(personalCode) &&
            isBirthDateValid(personalCode) &&
            isChecksumValid(personalCode)
        ) || (
            isPersonalCodeLengthValid(personalCode) &&
            isMobileIdTestCode(personalCode)
        ) || isLatvianPersonalCodeValid(personalCode)
    }

    private static func isLatvianPersonalCodeValid(_ personalCode: String) -> Bool {
        let pattern = "^\\d{6}-\\d{5}$"

        guard !personalCode.isEmpty,
              personalCode.count == Constants.Validation.MaximumLatvianPersonalCodeLength else {
            PersonalCodeValidator.logger.debug("Personal code is NOT Latvian")
            return false
        }

        return personalCode.range(of: pattern, options: .regularExpression) != nil
    }

    private static func isPersonalCodeNumeric(_ personalCode: String) -> Bool {
        return personalCode.allSatisfy { $0.isNumber }
    }

    private static func isBirthDateValid(_ personalCode: String) -> Bool {
        guard isPersonalCodeNumeric(personalCode) else {
            return false
        }

        do {
            let dateOfBirth = try parseDateOfBirth(personalCode)
            return dateOfBirth < Date()
        } catch {
            PersonalCodeValidator.logger.error("Invalid personal code or birth date: \(error)")
            return false
        }
    }

    private static func parseDateOfBirth(_ personalCode: String) throws -> Date {
        guard let firstDigit = personalCode.first?.wholeNumberValue else {
            PersonalCodeValidator.logger.error("Personal code cannot be empty")
            throw PersonalCodeError.invalidPersonalCode("Personal code cannot be empty")
        }

        let century: Int
        switch firstDigit {
        case 1, 2:
            century = 1800
        case 3, 4:
            century = 1900
        case 5, 6:
            century = 2000
        case 7, 8:
            century = 2100
        default:
            PersonalCodeValidator.logger.error("Unable to get century from: \(firstDigit)")
            throw PersonalCodeError.invalidPersonalCode("Unable to get century from: \(firstDigit)")
        }

        let yearString = String(personalCode.dropFirst().prefix(2))
        let monthString = String(personalCode.dropFirst(3).prefix(2))
        let dayString = String(personalCode.dropFirst(5).prefix(2))

        guard let yearOffset = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            PersonalCodeValidator.logger.error("Invalid date \(dayString).\(monthString).\(yearString)")
            throw PersonalCodeError.invalidDate("Invalid date \(dayString).\(monthString).\(yearString)")
        }

        let year = yearOffset + century

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        guard let date = Calendar.current.date(from: components) else {
            PersonalCodeValidator.logger.error("Invalid date \(components)")
            throw PersonalCodeError.invalidDate("Invalid date \(components)")
        }

        return date
    }

    private static func isChecksumValid(_ personalCode: String) -> Bool {
        var sum1 = 0
        var sum2 = 0

        var pos1 = 1
        var pos2 = 3

        for digitIndex in 0..<10 {
            let index = personalCode.index(personalCode.startIndex, offsetBy: digitIndex)
            let char = personalCode[index]

            guard let personalCodeNumber = Int(String(char)) else {
                PersonalCodeValidator.logger.error("Unable to parse personal code number at index \(digitIndex)")
                continue
            }

            sum1 += personalCodeNumber * pos1
            sum2 += personalCodeNumber * pos2

            pos1 = (pos1 == 9) ? 1 : pos1 + 1
            pos2 = (pos2 == 9) ? 1 : pos2 + 1
        }

        var result = sum1 % 11
        if result >= 10 {
            result = sum2 % 11
            if result >= 10 {
                result = 0
            }
        }

        guard let lastChar = personalCode.last,
              let lastNumber = Int(String(lastChar)) else {
            PersonalCodeValidator.logger.error("Personal code checksum is NOT valid")
            return false
        }

        return lastNumber == result
    }

    private static func isPersonalCodeLengthValid(_ personalCode: String) -> Bool { personalCode.count == 11 }

    private static func isMobileIdTestCode(_ personalCode: String) -> Bool {
        let testNumbers = [
            "14212128020",
            "14212128021",
            "14212128022",
            "14212128023",
            "14212128024",
            "14212128025",
            "14212128026",
            "14212128027",
            "38002240211",
            "14212128029"
        ]

        return testNumbers.contains(personalCode)
    }
}
