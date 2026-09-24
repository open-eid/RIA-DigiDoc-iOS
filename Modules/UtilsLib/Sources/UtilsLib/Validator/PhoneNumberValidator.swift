// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
