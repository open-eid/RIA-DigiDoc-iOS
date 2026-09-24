// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

public struct DateOfBirthUtil: Sendable, Loggable {
    public static func parseDateOfBirth(_ personalCode: String) throws -> Date {
        guard let firstDigit = personalCode.first?.wholeNumberValue else {
            DateOfBirthUtil.logger().error("Personal code cannot be empty")
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
            DateOfBirthUtil.logger().error("Unable to get century from: \(firstDigit)")
            throw PersonalCodeError.invalidPersonalCode("Unable to get century from: \(firstDigit)")
        }

        let yearString = String(personalCode.dropFirst().prefix(2))
        let monthString = String(personalCode.dropFirst(3).prefix(2))
        let dayString = String(personalCode.dropFirst(5).prefix(2))

        guard let yearOffset = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            DateOfBirthUtil.logger().error("Invalid date \(dayString).\(monthString).\(yearString)")
            throw PersonalCodeError.invalidDate("Invalid date \(dayString).\(monthString).\(yearString)")
        }

        let year = yearOffset + century

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        guard let date = Calendar.current.date(from: components) else {
            DateOfBirthUtil.logger().error("Invalid date \(components)")
            throw PersonalCodeError.invalidDate("Invalid date \(components)")
        }

        return date
    }
}
