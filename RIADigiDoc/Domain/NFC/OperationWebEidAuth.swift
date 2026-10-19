// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonCrypto
import CommonsLib
import CryptoKit
import CryptoTokenKit
import Security
import nfclib
import LibdigidocLibSwift
import UtilsLib

public struct WebEidAuthReturnData: Sendable {
    var authCert: Data
    var signingCert: Data
    var signatureArray: Data
}

@MainActor
public class OperationWebEidAuth: NFCOperationBase, OperationWebEidAuthProtocol {
    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin1Number: SecureData,
        origin: String,
        challenge: String,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidAuthReturnData {
        guard !userAgent.isEmpty else {
            Self.logger().error("NFC: \(ReadCertAndSignError.userAgentEmpty.localizedDescription)")
            throw ReadCertAndSignError.userAgentEmpty
        }

        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            Self.logger().info("NFC: Checks complete starting authentication")
            updateAlertMessage(step: 3)

            let (retryCount, pinActive) = try await cardCommands.readCodeTryCounterRecord(.pin1)

            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }
            if !pinActive {
                throw IdCardInternalError.pinLocked
            }
            let authCert = try await cardCommands.readAuthenticationCertificate()
            let signerCert = try await cardCommands.readSignatureCertificate()

            guard let certificate = SecCertificateCreateWithData(nil, authCert as CFData) else {
                throw ReadCertAndSignError.invalidCertificate
            }

            guard let publicKey = SecCertificateCopyKey(certificate) else {
                throw ReadCertAndSignError.missingPublicKey
            }

            updateAlertMessage(step: 4)

            guard let hashAlgorithm = try resolveHashAlgorithm(from: publicKey) else {
                throw ReadCertAndSignError.missingPublicKey
            }

            let originHash = digest(Data(origin.utf8), using: hashAlgorithm)
            let challengeHash = digest(Data(challenge.utf8), using: hashAlgorithm)

            let signedData = originHash + challengeHash
            let tbsHash = digest(signedData, using: hashAlgorithm)

            let signatureArray = try await cardCommands.authenticate(for: tbsHash, withPin1: pin1Number)

            return WebEidAuthReturnData(
                authCert: authCert,
                signingCert: signerCert,
                signatureArray: signatureArray
            )
        }
    }

    // MARK: - Helpers
    private func resolveHashAlgorithm(from publicKey: SecKey) throws -> HashAlgorithm? {
        guard let attrs = SecKeyCopyAttributes(publicKey) as? [CFString: Any],
              let keyType = attrs[kSecAttrKeyType] as? String,
              let keySizeBits = attrs[kSecAttrKeySizeInBits] as? Int else {
            return nil
        }

        guard keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) else {
            return nil
        }

        switch keySizeBits {
        case 256: return .sha256
        case 384: return .sha384
        case 521: return .sha512
        default:
            return nil
        }
    }

    private enum HashAlgorithm {
        case sha256
        case sha384
        case sha512
    }

    private func digest(_ data: Data, using algorithm: HashAlgorithm) -> Data {
        switch algorithm {
        case .sha256:
            return Data(SHA256.hash(data: data))
        case .sha384:
            return Data(SHA384.hash(data: data))
        case .sha512:
            return Data(SHA512.hash(data: data))
        }
    }
}
