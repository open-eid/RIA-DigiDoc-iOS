// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
            let (_, pin1Active) = try await cardCommands.readCodeTryCounterRecord(.pin1)
            if !pin1Active {
                throw IdCardInternalError.notActivated
            }

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
