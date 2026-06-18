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
import CommonCrypto
import CommonsLib
import CryptoTokenKit
import Security
import nfclib
import LibdigidocLibSwift
import UtilsLib

@MainActor
public class OperationReadCertAndSign: NFCOperationBase, OperationReadCertAndSignProtocol {
    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        signedContainer: SignedContainerProtocol,
        containerPath: URL,
        roleData: RoleData,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> SignedContainerProtocol {
        defer {
            pin2Number.secureZero()
        }

        guard !userAgent.isEmpty else {
            OperationReadCertAndSign.logger().error("NFC: \(ReadCertAndSignError.userAgentEmpty.localizedDescription)")
            throw ReadCertAndSignError.userAgentEmpty
        }

        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            updateAlertMessage(step: 3)
            let (retryCount, pinActive) = try await cardCommands.readCodeTryCounterRecord(.pin2)
            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }
            if !pinActive {
                throw IdCardInternalError.pinLocked
            }

            let cert = try await cardCommands.readSignatureCertificate()
            let hashToSign = try await signedContainer.prepareSignature(
                cert: cert,
                containerPath: containerPath,
                roleData: roleData,
                userAgent: userAgent
            )

            let signatureValue = try await cardCommands.calculateSignature(for: hashToSign, withPin2: pin2Number)
            pin2Number.secureZero()

            updateAlertMessage(step: 4)
            return try await signedContainer.addSignature(
                signature: signatureValue,
                containerFile: containerPath
            )
        }
    }
}
