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
import CommonsLib

public struct PhoneNumberValidator: Loggable {
    private static let minimumPhoneNumberLength = Constants.Validation.MinimumPhoneNumberLength
    private static let allowedPhoneNumberCountryCodes = Constants.Validation.AllowedPhoneNumberCountryCodes

    public static func isCountryCodeMissing(_ phoneNumber: String) -> Bool {
        let isCountryCodeMissing = (4..<minimumPhoneNumberLength).contains(phoneNumber.count) &&
               !isCountryCodeCorrect(phoneNumber)
        PhoneNumberValidator.logger().info("isCountryCodeMissing: \(isCountryCodeMissing)")
        return isCountryCodeMissing
    }

    public static func isCountryCodeCorrect(_ phoneNumber: String) -> Bool {
        for allowedCountryCode in allowedPhoneNumberCountryCodes where phoneNumber.hasPrefix(allowedCountryCode) {
            PhoneNumberValidator.logger().info("Phone number country code is correct")
            return true
        }
        PhoneNumberValidator.logger().info("Phone number country code is NOT correct")
        return false
    }

    public static func isPhoneNumberCorrect(_ phoneNumber: String) -> Bool {
        let isCorrect = phoneNumber.count >= minimumPhoneNumberLength
        PhoneNumberValidator.logger().info("Is phone number correct: \(isCorrect)")
        return isCorrect
    }
}
