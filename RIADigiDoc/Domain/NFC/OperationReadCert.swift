// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib
import UtilsLib

@MainActor
final public class OperationReadCert: NFCOperationBase, OperationReadCertProtocol {
    public func startReading(
        canNumber: String,
        strings: NFCSessionStrings,
    ) async throws -> String {
        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            updateAlertMessage(step: 3)

            Self.logger().info("Reading signature certificate")
            let signerCert = try await cardCommands.readSignatureCertificate()

            updateAlertMessage(step: 4)

            return signerCert.base64EncodedString()
        }
    }
}
