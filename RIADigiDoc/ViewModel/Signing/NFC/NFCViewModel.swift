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
import CryptoObjCWrapper
import CryptoSwift
import IdCardLib
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CoreNFC
import X509

@Observable
@MainActor
class NFCViewModel: NFCViewModelProtocol, Loggable {
    var canNumberErrorKey: String?
    var canNumberErrorExtraArguments: [String] = []

    var pinNumberErrorKey: String?
    var pinNumberErrorExtraArguments: [String] = []

    var nfcErrorKey: String?
    var nfcErrorExtraArguments: [String] = []

    var showNfcAlertMessage: Bool = false
    var nfcAlertMessageKey: String?
    var nfcAlertMessageExtraArguments: [String] = []
    var nfcAlertMessageUrl: String?

    private let dataStore: DataStoreProtocol
    private let userAgentUtil: UserAgentUtilProtocol

    init(
        dataStore: DataStoreProtocol,
        userAgentUtil: UserAgentUtilProtocol
    ) {
        self.dataStore = dataStore
        self.userAgentUtil = userAgentUtil
    }

    func isNFCSupported() -> Bool {
        if NFCTagReaderSession.readingAvailable { return true }
        NFCViewModel.logger().error("NFC: NFC not available on this device")
        return false
    }

    func isActionEnabled(canNumber: String, pinNumber: String, pinType: CodeType?) -> Bool {
        checkCANNumberValidity(canNumber: canNumber)
        checkPINNumberValidity(pinNumber: pinNumber, pinType: pinType)
        let result = (!canNumber.isEmpty && canNumberErrorKey?.isEmpty == true)
            && (!pinNumber.isEmpty && pinNumberErrorKey?.isEmpty == true)
        return result
    }

    func saveInputData(canNumber: String, rememberMe: Bool) async {
        await dataStore
            .setNFCInputData(
                NFCInputData(
                    canNumber: canNumber,
                    rememberMe: rememberMe
                )
            )
    }

    func getInputData() async -> NFCInputData {
        return await dataStore.getNFCInputData()
    }

    func resetErrors() {
        canNumberErrorKey = nil
        canNumberErrorExtraArguments = []
        pinNumberErrorKey = nil
        pinNumberErrorExtraArguments = []
        nfcErrorKey = nil
        nfcErrorExtraArguments = []
    }

    func loadPersonalData() {
        // TODO: Implement with My eID
    }

    func decrypt(
        CAN: String,
        pin1: String,
        cryptoContainer: CryptoContainerProtocol?,
        strings: NFCSessionStrings
    ) async
    -> CryptoContainerProtocol? {
        NFCViewModel.logger().info("NFC: Starting NFC decryption")
        let containerFile = await cryptoContainer?.getRawContainerFile() ?? URL(fileURLWithPath: "")
        let recipients = await cryptoContainer?.getRecipients() ?? []
        let pinSecureData = SecureData(Array(pin1.utf8))

        do {
            NFCViewModel.logger().info("NFC: Starting decryption operation")
            let container = try await OperationDecrypt().processDecrypt(
                canNumber: CAN,
                pin1Number: pinSecureData,
                containerFile: containerFile,
                recipients: recipients,
                strings: strings
            )
            NFCViewModel.logger().info("NFC: Decryption completed successfully")
            return container
        } catch {
            NFCViewModel.logger().error("NFC: Decryption operation failed")

            if let idCardInternalError = error as? IdCardInternalError {
                let idCardError = idCardInternalError.getIdCardError()
                NFCViewModel.logger().error("NFC: IdCardError: \(idCardError)")
                handleIdCardError(idCardError, pinType: CodeType.pin1)
                return nil
            }

            if let decryptError = error as? DecryptError {
                NFCViewModel.logger().error("NFC: ReadCertAndDecryptError: \(decryptError.localizedDescription)")
                handleDecryptError(error: decryptError)
                return nil
            }

            NFCViewModel.logger().error("NFC: Unexpected error type: \(type(of: error))")
            NFCViewModel.logger().error("NFC: Error details: \(error)")
            nfcErrorKey = "NFC session error"
            nfcErrorExtraArguments = []
            return nil
        }
    }

    private func handleIdCardError(_ error: IdCardError, pinType: CodeType) {
        NFCViewModel.logger().error("NFC: ID Card error: \(error)")

        switch error {
        case .cancelledByUser:
            nfcErrorKey = nil
            nfcErrorExtraArguments = []
        case .wrongCAN:
            nfcErrorKey = "Wrong CAN"
            nfcErrorExtraArguments = []
        case .wrongPIN(let triesLeft):
            if triesLeft > 1 {
                nfcErrorKey = "PIN verification error multiple"
                nfcErrorExtraArguments = [pinType.name, String(triesLeft)]
            } else if triesLeft == 1 {
                nfcErrorKey = "PIN verification error one"
                nfcErrorExtraArguments = [pinType.name]
            } else {
                nfcErrorKey = "PIN blocked"
                nfcErrorExtraArguments = [pinType.name]
            }
        case .sessionError:
            nfcErrorKey = "NFC session error"
            nfcErrorExtraArguments = []
        default:
            nfcErrorKey = "NFC technical error"
            nfcErrorExtraArguments = []
        }
    }

    private func handleReadCertAndSignError(error: ReadCertAndSignError) {
        switch error {
        case .cancelled:
            nfcErrorKey = nil
        case .signedContainerNil, .roleDataNil, .containerPathNil, .userAgentEmpty:
            NFCViewModel.logger().error("NFC: Configuration error")
            nfcErrorKey = "NFC session error"
        case .unknown(let underlying):
            NFCViewModel.logger().error("NFC: Unknown error - \(underlying)")
            nfcErrorKey = "General error"
        }
    }

    private func handleDigiDocError(error: DigiDocError) {
        switch error {
        case .signatureAddingFailed(let underlying):
            handleDigiDocSignError(errorDetail: underlying)
        default:
            NFCViewModel.logger().error("NFC: Unknown DigiDoc error - \(error)")
            nfcErrorKey = "General error"
        }
    }

    private func handleDigiDocSignError(errorDetail: ErrorDetail) {
        NFCViewModel.logger().error("NFC: DigiDoc signature adding error - \(errorDetail.description)")
        switch errorDetail.code {
        case 5, 6:
            nfcErrorKey = "Certificate status revoked"
        case 7:
            showNfcAlertMessage = true
            nfcAlertMessageKey = "OCSP response not in valid time slot"
            nfcAlertMessageUrl = "OCSP response not in valid time slot url"
        case 18:
            showNfcAlertMessage = true
            nfcAlertMessageKey = "Too many requests"
            nfcAlertMessageUrl = "Too many requests url"
            nfcAlertMessageExtraArguments = ["NFC"]
        case 20:
            nfcErrorKey = "No Internet connection"
        case 101, 102:
            nfcErrorKey = "SSL handshake failed"
        default:
            nfcErrorKey = "General error"
        }
    }

    private func handleDecryptError(error: DecryptError) {
        switch error {
        case .cancelled:
            nfcErrorKey = nil
        case .containerFileInvalid, .recipientsEmpty:
            NFCViewModel.logger().error("NFC: Configuration error")
            nfcErrorKey = "NFC session error"
        case .unknown(let underlying):
            NFCViewModel.logger().error("NFC: Unknown error - \(underlying)")
            nfcErrorKey = "General error"
        }
    }

    func isRoleDataEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    private func checkCANNumberValidity(canNumber: String) {
        guard canNumber.isEmpty || (
            canNumber.count == Constants.Validation.CANNumberLength &&
            canNumber.allSatisfy { $0.isNumber }
        ) else {
            canNumberErrorKey = "CAN length requirement"
            canNumberErrorExtraArguments = [String(
                Constants.Validation.CANNumberLength
            )]
            return
        }
        canNumberErrorKey = ""
    }

    func sign(
        canNumber: String,
        pin2: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        strings: NFCSessionStrings
    ) async -> SignedContainerProtocol? {
        NFCViewModel.logger().info("NFC: Starting NFC signing")
        let pin2Data = pin2.data(using: .utf8)
        guard let pin2Data else {
            NFCViewModel.logger().error("NFC: Failed to convert PIN2 to Data")
            return nil
        }

        guard let containerFile = await signedContainer.getRawContainerFile() else {
            NFCViewModel.logger().error("NFC: Failed to get container file path")
            return nil
        }

        NFCViewModel.logger().info("NFC: Getting language")
        let appLanguage = await dataStore.getSelectedLanguage()

        NFCViewModel.logger().info("NFC: Getting User-Agent")
        let userAgent = userAgentUtil.userAgent(diagnostics: .nfc, language: appLanguage)

        do {
            NFCViewModel.logger().info("NFC: Starting signing operation")
            let result = try await OperationReadCertAndSign().startOperation(
                canNumber: canNumber,
                pin2Number: SecureData(pin2Data),
                signedContainer: signedContainer,
                containerPath: containerFile,
                roleData: roleData,
                userAgent: userAgent,
                strings: strings
            )
            NFCViewModel.logger().info("NFC: Signature added successfully")
            return result
        } catch {
            NFCViewModel.logger().error("NFC: Signing operation failed")

            if let idCardInternalError = error as? IdCardInternalError {
                let idCardError = idCardInternalError.getIdCardError()
                NFCViewModel.logger().error("NFC: IdCardError: \(idCardError)")
                handleIdCardError(idCardError, pinType: .pin2)
                return nil
            }

            if let readCertSignError = error as? ReadCertAndSignError {
                NFCViewModel.logger().error("NFC: ReadCertAndSignError: \(readCertSignError.localizedDescription)")
                handleReadCertAndSignError(error: readCertSignError)
                return nil
            }

            if let digiDocError = error as? DigiDocError {
                NFCViewModel.logger().error("NFC: DigiDocError: \(digiDocError.localizedDescription)")
                handleDigiDocError(error: digiDocError)
                return nil
            }

            NFCViewModel.logger().error("NFC: Unexpected error type: \(type(of: error))")
            NFCViewModel.logger().error("NFC: Error details: \(error)")
            nfcErrorKey = "General error"
            return nil
        }
    }

    private func checkPINNumberValidity(pinNumber: String, pinType: CodeType?) {
        let minLen = if pinType == .pin1 {
            Constants.Validation.Pin1MinimumLength
        } else if pinType == .pin2 {
            Constants.Validation.Pin2MinimumLength
        } else {
            Constants.Validation.PukMinimumLength
        }

        let maxLen = Constants.Validation.PinMaximumLength

        guard pinNumber.isEmpty || (
            pinNumber.count >= minLen &&
            pinNumber.count <= maxLen &&
            pinNumber.allSatisfy { $0.isNumber }
        ) else {
            pinNumberErrorKey = "PIN length requirement"
            pinNumberErrorExtraArguments = [pinType?.name ?? "", String(minLen), String(maxLen)]
            return
        }
        pinNumberErrorKey = ""
    }
}
