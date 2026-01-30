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

import SwiftUI
import FactoryKit
import CryptoSwift
import IdCardLib
import LibdigidocLibSwift
import CommonsLib
struct NFCView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @State private var canNumber = ""
    @State private var pinNumber = ""
    @State private var pinType: CodeType?
    @State private var rememberMe: Bool = true
    @State private var isActionEnabled = false
    @State private var isInProgress: Bool = false

    @State private var nfcActionMessage: String = "NFC hold card"

    @State private var viewModel: NFCViewModel
    @State private var sharedNfcViewModel: SharedNFCViewModel

    @State private var taskDecrypt: Task<Void, Never>?

    private var isNFCSupported: Bool {
        sharedNfcViewModel.isNFCSupported()
    }

    private var nfcErrorMessage: String {
        languageSettings.localized(
            viewModel.nfcErrorKey ?? "",
            viewModel.nfcErrorExtraArguments
        )
    }

    private var canNumberError: Binding<String?> {
        Binding(
            get: { languageSettings.localized(
                viewModel.canNumberErrorKey ?? "",
                viewModel.canNumberErrorExtraArguments
            ) },
            set: { _ in }
        )
    }

    private var pinNumberError: Binding<String?> {
        Binding(
            get: { languageSettings.localized(
                viewModel.pinNumberErrorKey ?? "",
                viewModel.pinNumberErrorExtraArguments
            ) },
            set: { _ in }
        )
    }

    private var displayedMessage: Binding<String> {
        Binding(
            get: {
                isNFCSupported ? nfcActionMessage : "NFC not supported"
            },
            set: { newValue in
                nfcActionMessage = newValue
            }
        )
    }

    let signedContainer: SignedContainerProtocol?
    let cryptoContainer: CryptoContainerProtocol?

    let onSuccess: (SignedContainerProtocol) -> Void
    let onSuccessDecrypt: (CryptoContainerProtocol) -> Void

    init(
        actionType: ActionType,
        actionMethods: [ActionMethod],
        pinType: CodeType? = nil,
        cryptoContainer: CryptoContainerProtocol? = nil,
        signedContainer: SignedContainerProtocol? = nil,
        onSuccess: @escaping (SignedContainerProtocol) -> Void = { _ in },
        onSuccessDecrypt: @escaping (CryptoContainerProtocol) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: Container.shared.nfcViewModel())
        _sharedNfcViewModel = State(wrappedValue: Container.shared.sharedNfcViewModel())
        self.actionType = actionType
        self.pinType = pinType
        self.actionMethods = actionMethods
        self.cryptoContainer = cryptoContainer
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
        self.onSuccessDecrypt = onSuccessDecrypt
    }

    var body: some View {
        ActionInputScreen(
            actionType: actionType,
            actionMethods: actionMethods,
            selectedActionMethod: ActionMethod.idCardViaNFC.rawValue,
            isActionEnabled: $isActionEnabled,
            isInProgress: $isInProgress,
            onBackClick: {
                cancelDecrypt()
                guard isInProgress else {
                    dismiss()
                    return
                }
                isInProgress = false
            },
            onSubmit: {
                switch actionType {
                case .decrypt:
                    saveInputData()
                    Task {
                        decrypt()
                    }
                    isInProgress = true
                case .signing:
                    saveInputData()

                    // TODO: Implement signing action
                    isInProgress = true
                case .myeid:
                    saveInputData()
                    // TODO: Implement My eID personal data loading action
                    isInProgress = true

                    // TODO: Replace with real loading
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        pathManager.replaceLast(
                            to: .myEidView(
                                idCardData: IdCardData(
                                    publicData: CardInfo(),
                                    authCertNotValidDate: nil,
                                    signCertNotValidDate: nil,
                                    retryCount: RetryCount(
                                        pin1: 3,
                                        pin2: 3,
                                        puk: 3
                                    ),
                                    isPUKChangeable: true
                                )
                            )
                        )
                    }
                }
            },
            content: {
                if isInProgress {
                    NFCActionView(
                        leftIcon: "ic_m3_phonelink_ring_48pt_wght400",
                        rightIcon: "ic_m3_id_card_48pt_wght400",
                        message: displayedMessage
                    )
                } else {
                    NFCInputView(
                        canNumber: $canNumber,
                        rememberMe: $rememberMe,
                        isActionEnabled: $isActionEnabled,
                        canNumberError: canNumberError,
                        pinNumber: $pinNumber,
                        pinError: pinNumberError,
                        pinType: pinType,
                        onInputChange: {
                            isActionEnabled = viewModel
                                .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
                        }
                    )
                }
            }
        )
        .onAppear {
            Task {
                let inputData = await viewModel.getInputData()
                canNumber = inputData.canNumber
                rememberMe = inputData.rememberMe
            }
        }
        .onChange(of: viewModel.nfcErrorKey) { _, newKey in
            guard newKey != nil else { return }
            Toast.show(nfcErrorMessage)
        }
    }

    func saveInputData() {
        Task {
            let (inputCANNumber) = rememberMe ? (canNumber) : ("")
            await viewModel.saveInputData(
                canNumber: inputCANNumber,
                rememberMe: rememberMe
            )
        }
    }

    private func decrypt() {
        taskDecrypt = Task {
            guard let container = cryptoContainer else { return }

            let (inputCANNumber) = rememberMe ? (canNumber) : ("")

            await viewModel.saveInputData(
                canNumber: inputCANNumber,
                rememberMe: rememberMe
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = NFCSessionStrings(
                initialMessage: languageSettings.localized("Please place your ID card against the smart device"),
                step1Message:
                    languageSettings.localized(
                        "Hold your ID card against your smart device until the data is read"
                    ),
                step2Message: languageSettings.localized("Reading data please wait"),
                step3Message: languageSettings.localized("Reading certificate"),
                step4Message: languageSettings.localized("Decrypting in progress please wait"),
                successMessage: languageSettings.localized("Data read"),
                canErrorMessage: languageSettings.localized("Wrong CAN"),
                pin1WrongMultipleErrorMessage:
                    languageSettings.localized(
                        "PIN verification error multiple",
                        [CodeType.pin1.name, "2"]
                    ),
                pin1WrongErrorMessage: languageSettings.localized("PIN verification error one", [CodeType.pin1.name]),
                pin1BlockedErrorMessage: languageSettings.localized("PIN blocked", [CodeType.pin1.name]),
                technicalErrorMessage: languageSettings.localized("NFC technical error"),
                sessionErrorMessage: languageSettings.localized("NFC session error")
            )

            let decryptedContainer = await viewModel.decrypt(
                CAN: canNumber,
                pin1: pinNumber,
                cryptoContainer: container,
                strings: strings
            )

            guard let container = decryptedContainer else {
                cancelDecrypt()
                isInProgress = false
                return
            }

            cancelDecrypt()
            isInProgress = false

            onSuccessDecrypt(container)
            dismiss()
        }
    }

    private func cancelDecrypt() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
        taskDecrypt?.cancel()
        taskDecrypt = nil
    }
}

#Preview {
    NFCView(
        actionType: .signing,
        actionMethods: [
            .idCardViaNFC,
            .idCardViaUSB,
            .mobileId,
            .smartId
        ],
        pinType: CodeType.pin2,
        signedContainer: SignedContainer(
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        ),
        onSuccess: { _ in }
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
