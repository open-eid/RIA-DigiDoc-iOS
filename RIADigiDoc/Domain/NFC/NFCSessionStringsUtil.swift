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

public struct NFCSessionStringsUtil {
    private let localize: (String, [String]) -> String

    public init(localize: @escaping (String, [String]) -> String) {
        self.localize = localize
    }

    public func makeDefault(pinName: String = "") -> NFCSessionStrings {
        customLocalizations(pinName: pinName)
    }

    public func makeForDecrypt(pinName: String) -> NFCSessionStrings {
        customLocalizations(
            pinName: pinName,
            step4Message: localize("Decrypting in progress", []),
            successMessage: localize("Container successfully decrypted", [])
        )
    }

    public func makeForSigning(pinName: String) -> NFCSessionStrings {
        customLocalizations(
            pinName: pinName,
            step4Message: localize("Signing in progress", []),
            successMessage: localize("Signature added", [])
        )
    }

    public func makeForUnblock(pinName: String) -> NFCSessionStrings {
        customLocalizations(
            pinName: pinName,
            successMessage: localize("PIN unblocked", [pinName])
        )
    }

    public func makeForChangePin(pinName: String) -> NFCSessionStrings {
        customLocalizations(
            pinName: pinName,
            successMessage: localize("PIN changed", [pinName])
        )
    }

    public func customLocalizations(
        pinName: String,
        initialMessage: String? = nil,
        step1Message: String? = nil,
        step2Message: String? = nil,
        step3Message: String? = nil,
        step4Message: String? = nil,
        successMessage: String? = nil,
        canErrorMessage: String? = nil,
        pinWrongMultipleErrorMessage: String? = nil,
        pinWrongErrorMessage: String? = nil,
        pinBlockedErrorMessage: String? = nil,
        technicalErrorMessage: String? = nil,
        sessionErrorMessage: String? = nil,
        ocspTimeslotErrorMessage: String? = nil,
        certificateRevokedErrorMessage: String? = nil,
        tooManyRequestsErrorMessage: String? = nil,
        networkErrorMessage: String? = nil,
        sslErrorMessage: String? = nil
    ) -> NFCSessionStrings {
        NFCSessionStrings(
            initialMessage: initialMessage ?? localize("Please place your ID card against the smart device", []),
            step1Message: step1Message ?? localize(
                "Hold your ID card against your smart device until the data is read", []),
            step2Message: step2Message ?? localize("Reading data", []),
            step3Message: step3Message ?? localize("Reading certificate", []),
            step4Message: step4Message ?? localize("Reading data", []),
            successMessage: successMessage ?? localize("Data read", []),
            canErrorMessage: canErrorMessage ?? localize("Wrong CAN", []),
            pinWrongMultipleErrorMessage: pinWrongMultipleErrorMessage ?? localize(
                "PIN verification error multiple", [pinName, "2"]),
            pinWrongErrorMessage: pinWrongErrorMessage ?? localize("PIN verification error one", [pinName]),
            pinBlockedErrorMessage: pinBlockedErrorMessage ?? localize("PIN blocked", [pinName]),
            technicalErrorMessage: technicalErrorMessage ?? localize("NFC technical error", []),
            sessionErrorMessage: sessionErrorMessage ?? localize("NFC session error", []),
            ocspTimeslotErrorMessage: ocspTimeslotErrorMessage ?? localize("OCSP response not in valid time slot", []),
            certificateRevokedErrorMessage: certificateRevokedErrorMessage ?? localize(
                "Certificate status revoked", []),
            tooManyRequestsErrorMessage: tooManyRequestsErrorMessage ?? localize("Too many requests", ["NFC"]),
            networkErrorMessage: networkErrorMessage ?? localize("No Internet connection", []),
            sslErrorMessage: sslErrorMessage ?? localize("SSL handshake failed", []),
        )
    }
}
