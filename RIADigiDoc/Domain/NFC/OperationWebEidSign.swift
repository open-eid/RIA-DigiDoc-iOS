// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonCrypto
import CommonsLib
import CryptoTokenKit
import Security
import nfclib
import LibdigidocLibSwift
import UtilsLib

public struct WebEidSignReturnData: Sendable {
    var signerCertB64: String
    var signatureArray: Data
    var responseUri: String
}

@MainActor
public class OperationWebEidSign: NFCOperationBase, OperationWebEidSignProtocol {
    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        responseUri: String,
        hash: String,
        expectedSigningCertBase64: String?,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidSignReturnData {
        guard let expectedSigningCertBase64,
              !expectedSigningCertBase64.isEmpty,
              let expectedCert = Data(base64Encoded: expectedSigningCertBase64) else {
            throw ReadCertAndSignError.invalidCertificate
        }

        guard let hashBytes = Data(base64Encoded: hash), !hashBytes.isEmpty else {
            throw ReadCertAndSignError.hashInvalid
        }

        guard !userAgent.isEmpty else {
            Self.logger().error("NFC: \(ReadCertAndSignError.userAgentEmpty.localizedDescription)")
            throw ReadCertAndSignError.userAgentEmpty
        }

        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            Self.logger().info("NFC: Checks complete starting signing")
            updateAlertMessage(step: 3)

            let (retryCount, pinActive) = try await cardCommands.readCodeTryCounterRecord(.pin2)

            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }
            if !pinActive {
                throw IdCardInternalError.pinLocked
            }

            let signerCert = try await cardCommands.readSignatureCertificate()

            if expectedCert != signerCert {
                throw ReadCertAndSignError.certMismatch
            }

            let signatureArray = try await cardCommands.calculateSignature(for: hashBytes, withPin2: pin2Number)

            updateAlertMessage(step: 4)
            return WebEidSignReturnData(
                signerCertB64: signerCert.base64EncodedString(),
                signatureArray: signatureArray,
                responseUri: responseUri
            )
        }
    }
}
