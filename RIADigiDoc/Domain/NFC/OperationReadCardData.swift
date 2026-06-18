// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
