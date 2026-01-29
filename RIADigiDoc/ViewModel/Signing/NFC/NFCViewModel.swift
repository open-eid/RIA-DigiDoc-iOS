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

@Observable
@MainActor
class NFCViewModel: NFCViewModelProtocol, Loggable {

    var canNumberErrorKey: String?
    var canNumberErrorExtraArguments: [String] = []

    var pinNumberErrorKey: String?
    var pinNumberErrorExtraArguments: [String] = []

    var nfcErrorKey: String?
    var nfcErrorExtraArguments: [String] = []

    private let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
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
        do {
            let containerFile = await cryptoContainer?.getRawContainerFile() ?? URL(fileURLWithPath: "")
            let recipients = await cryptoContainer?.getRecipients() ?? []
            let pinSecureData = SecureData(Array(pin1.utf8))

            let container = try await OperationDecrypt().processDecrypt(
                CAN: CAN,
                PIN1: pinSecureData,
                containerFile: containerFile,
                recipients: recipients,
                strings: strings
            )
            return container
        } catch {
            guard let exception = error as? IdCardInternalError else {
                NFCViewModel.logger().error("NFC: ID Card General error.")
                nfcErrorKey = "General error"

                return nil
            }

            let error  = exception.getIdCardError()
            handleIdCardError(error, pinType: CodeType.pin1)

            return nil
        }
    }

    private func handleIdCardError(_ error: IdCardError, pinType: CodeType) {
        NFCViewModel.logger().error("NFC: ID Card error: \(error)")

        switch error {
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

    func sign() async -> SignedContainerProtocol? {
        // TODO: Implement with NFC signing
        return nil
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
