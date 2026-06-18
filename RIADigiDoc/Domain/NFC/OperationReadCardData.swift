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
import CoreNFC
import nfclib
import UtilsLib

@MainActor
final public class OperationReadCardData: NFCOperationBase, OperationReadCardDataProtocol {
    public func startReading(
        canNumber: String,
        strings: NFCSessionStrings,
    ) async throws -> NFCCardData {
        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            OperationReadCardData.logger().info("Reading public data...")
            let cardInfo = try await cardCommands.readPublicData()

            updateAlertMessage(step: 3)
            OperationReadCardData.logger().info("Reading authentication certificate")
            let authenticationCertificate = try await cardCommands.readAuthenticationCertificate()

            OperationReadCardData.logger().info("Reading signature certificate")
            let signatureCertificate = try await cardCommands.readSignatureCertificate()

            updateAlertMessage(step: 4)
            OperationReadCardData.logger().info("Reading PIN retry counts...")
            let pin1Response = try await cardCommands.readCodeTryCounterRecord(.pin1)
            let pin2Response = try await cardCommands.readCodeTryCounterRecord(.pin2)
            let pukResponse = try await cardCommands.readCodeTryCounterRecord(.puk)

            let pinResponse = PinResponse(
                pin1RetryCount: pin1Response.retryCount,
                pin1Active: pin1Response.pinActive,
                pin2RetryCount: pin2Response.retryCount,
                pin2Active: pin2Response.pinActive,
                pukRetryCount: pukResponse.retryCount,
                pukActive: pukResponse.pinActive,
            )

            return NFCCardData(
                publicData: cardInfo,
                authenticationCertificate: authenticationCertificate,
                signatureCertificate: signatureCertificate,
                pinResponse: pinResponse,
                isPUKChangable: cardCommands.canChangePUK
            )
        }
    }
}
