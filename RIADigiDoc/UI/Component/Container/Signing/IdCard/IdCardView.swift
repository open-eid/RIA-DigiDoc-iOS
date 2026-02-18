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
import LibdigidocLibSwift
import IdCardLib
import CommonsLib

struct IdCardView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @State private var isActionEnabled = false
    @State private var isInProgress: Bool = false
    @State private var isShowingPinView: Bool = false
    @State private var isShowingLoadingView: Bool = false
    @State private var showRoleView: Bool = false
    @State private var pinNumber = ""
    @State private var idCardActionMessage: String = "ID card connect card reader"

    @State private var viewModel: IdCardViewModel

    @State private var usbReaderStatus: UsbReaderStatus = .sInitial
    @State private var idCardData: IdCardData?

    @State private var task: Task<Void, Never>?

    let signedContainer: SignedContainerProtocol?
    let cryptoContainer: CryptoContainerProtocol?

    let onSuccess: (SignedContainerProtocol) -> Void
    let onSuccessDecrypt: (CryptoContainerProtocol) -> Void

    var localizedPinBlockedMessage: String? {
        guard let messageKey = viewModel.idCardAlertMessageKey else { return nil }
        if messageKey == "PIN blocked" {
            let pinBlockedMessage = languageSettings.localized(
                messageKey,
                viewModel.idCardAlertMessageExtraArguments
            )

            let unblockMessage = languageSettings.localized(
                "PIN blocked unblock message"
            )

            return "\(pinBlockedMessage) \(unblockMessage)"
        }

        return messageKey
    }

    var localizedArguments: [String] {
        var localized: [String] = []
        for arg in viewModel.idCardAlertMessageExtraArguments {
            localized.append(languageSettings.localized(arg))
        }

        return localized
    }

    private var errorMessage: String {
        languageSettings.localized(
            viewModel.errorMessage ?? "",
            viewModel.errorExtraArguments
        )
    }

    private var pinNumberError: Binding<String> {
        Binding(
            get: { languageSettings.localized(
                viewModel.pinNumberErrorKey ?? "",
                viewModel.pinNumberErrorExtraArguments
            ) },
            set: { _ in }
        )
    }

    private var personIdentifier: String {
        let publicData = idCardData?.publicData
        guard let personData = publicData else { return "" }
        return viewModel
            .formatPersonalIdentifier(
                givenName: personData.givenName,
                surname: personData.surname,
                personalCode: personData.personalCode
            )
    }

    private var pinCodeType: CodeType {
        actionType == .signing ? .pin2 : .pin1
    }

    private var isIdCardAlertError: Bool {
        viewModel.idCardAlertMessageKey?.isEmpty == false
    }

    init(
        actionType: ActionType,
        actionMethods: [ActionMethod],
        signedContainer: SignedContainerProtocol? = nil,
        cryptoContainer: CryptoContainerProtocol? = nil,
        onSuccess: @escaping (SignedContainerProtocol) -> Void = { _ in },
        onSuccessDecrypt: @escaping (CryptoContainerProtocol) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: Container.shared.idCardViewModel())
        self.actionType = actionType
        self.actionMethods = actionMethods
        self.signedContainer = signedContainer
        self.cryptoContainer = cryptoContainer
        self.onSuccess = onSuccess
        self.onSuccessDecrypt = onSuccessDecrypt
    }

    var body: some View {
        ActionInputScreen(
            actionType: actionType,
            actionMethods: actionMethods,
            selectedActionMethod: .idCardViaUSB,
            isActionEnabled: $isActionEnabled,
            isInProgress: $isInProgress,
            showSubmitButton: isShowingPinView,
            onBackClick: {
                Task {
                    await viewModel.stopDiscoveringReaders()
                }

                guard isInProgress else {
                    dismiss()
                    return
                }
                isInProgress = false
                isShowingPinView = false
                isShowingLoadingView = false
            },
            onSubmit: {
                switch actionType {
                case .decrypt:
                    isInProgress = true
                    isShowingPinView = false
                    isShowingLoadingView = true

                    guard let container = cryptoContainer else { return }

                    if usbReaderStatus == .sCardConnected {
                        Task {
                            let decryptedContainer = await viewModel.decrypt(
                                pin1: pinNumber,
                                cryptoContainer: container
                            )

                            pinNumber = ""

                            let shouldDismiss = viewModel.shouldDismissForError

                            guard let container = decryptedContainer else {
                                if shouldDismiss {
                                    cancelIdCardAction()
                                    await viewModel.stopDiscoveringReaders()
                                }

                                await MainActor.run {
                                    Toast.show(errorMessage)
                                    viewModel.resetErrors()
                                    if shouldDismiss {
                                        dismiss()
                                    }

                                    isInProgress = !viewModel.shouldDismissForError
                                    isShowingPinView = !viewModel.shouldDismissForError
                                    isShowingLoadingView = false
                                    return
                                }

                                return
                            }

                            await viewModel.stopDiscoveringReaders()
                            cancelIdCardAction()
                            isInProgress = false
                            isShowingPinView = false
                            isShowingLoadingView = false

                            onSuccessDecrypt(container)
                            dismiss()
                        }
                    }
                case .signing:
                    isInProgress = true
                    isShowingPinView = false
                    isShowingLoadingView = true

                    if usbReaderStatus == .sCardConnected {
                        Task {
                            let isRoleDataEnabled = await viewModel.isRoleDataEnabled()
                            if isRoleDataEnabled {
                                showRoleView = true
                            } else {
                                sign()
                            }
                        }
                    }
                case .myeid:
                    // Do nothing
                    break
                }
            },
            content: {
                if !isShowingPinView && !isShowingLoadingView {
                    IdCardActionView(
                        icon: "ic_m3_smart_card_reader_48pt_wght400",
                        message: $idCardActionMessage
                    )
                } else if isInProgress && isShowingPinView {
                    IdCardInputView(
                        personIdentifier: personIdentifier,
                        pinNumber: $pinNumber,
                        pinError: pinNumberError,
                        actionType: actionType,
                        pinType: pinCodeType,
                        onInputChange: {
                            isActionEnabled = viewModel
                                .isActionEnabled(pinNumber: pinNumber, pinType: pinCodeType)
                        }
                    )
                } else if isInProgress && isShowingLoadingView {
                    IdCardLoadingView(
                        actionType: actionType
                    )
                }
            }
        )
        .task {
            await viewModel.startDiscoveringReaders()
        }
        .fullScreenCover(isPresented: $showRoleView) {
            RoleView(
                onComplete: { roles, city, state, country, zipCode in
                    showRoleView = false
                    sign(
                        roleData: RoleData(
                            roles: roles
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) },
                            city: city,
                            state: state,
                            country: country,
                            zipCode: zipCode
                        )
                    )
                }
            )
        }
        .alert(
            languageSettings.localized(
                localizedPinBlockedMessage ?? "",
                localizedArguments
            ),
            isPresented: $viewModel.showIdCardAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                Task {
                    await viewModel.stopDiscoveringReaders()
                }
                viewModel.resetErrors()
                viewModel.resetAlertErrors()
                dismiss()
            }

            if let messageUrl = viewModel.idCardAlertMessageUrl, !messageUrl.isEmpty {
                Button(languageSettings.localized("Additional information")) {
                    if let url = URL(string: languageSettings.localized(messageUrl)),
                       UIApplication.shared.canOpenURL(url) {
                        openURL(url)
                    }
                    viewModel.resetErrors()
                    viewModel.resetAlertErrors()
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.usbReaderStatus) { _, newValue in
            usbReaderStatus = newValue
            idCardActionMessage = getStatusText(newValue)

            let notInProgressStates: [UsbReaderStatus] = [
                .sInitial,
                .sReaderNotConnected,
                .sReaderProcessFailed
            ]

            isInProgress = !notInProgressStates.contains(newValue)

            pinNumber = ""

            Task {
                switch actionType {
                case .decrypt:
                    guard newValue == .sCardConnected else {
                        await MainActor.run {
                            isShowingPinView = false
                            isShowingLoadingView = false
                        }
                        return
                    }

                    idCardData = await viewModel.getIdCardData(for: .pin1)
                    guard idCardData != nil else {
                        await handleCardError()
                        return
                    }

                    await MainActor.run {
                        isShowingLoadingView = false
                        isShowingPinView = true
                    }

                case .signing:
                    guard newValue == .sCardConnected else {
                        await MainActor.run {
                            isShowingPinView = false
                            isShowingLoadingView = false
                        }
                        return
                    }

                    idCardData = await viewModel.getIdCardData(for: .pin2)
                    guard idCardData != nil else {
                        await handleCardError()
                        return
                    }

                    await MainActor.run {
                        isShowingLoadingView = false
                        isShowingPinView = true
                    }

                case .myeid:
                    guard newValue == .sCardConnected else { return }

                    let cardData = await viewModel.getIdCardDataMyEid()
                    guard let cardData else {
                        await handleCardError()
                        return
                    }

                    await MainActor.run {
                        isInProgress = true
                        pathManager.replaceLast(
                            to: .myEidView(
                                idCardData: cardData,
                                actionMethod: .idCardViaUSB
                            )
                        )
                    }
                }
            }
        }
        .onDisappear {
            pinNumber.removeAll()
            cancelIdCardAction()
        }
    }

    private func handleCardError() async {
        await viewModel.stopDiscoveringReaders()
        await MainActor.run {
            Toast.show(errorMessage)
            viewModel.resetErrors()

            // Let ID-card alert closure handle dismiss
            // Dismiss is run when user has pressed OK button on alert
            if !isIdCardAlertError {
                dismiss()
            }
        }
    }

    private func getStatusText(_ status: UsbReaderStatus) -> String {
        switch status {
        case .sInitial, .sReaderNotConnected:
            return languageSettings.localized("ID card connect card reader")
        case .sReaderConnected:
            return languageSettings.localized("ID card reader connected")
        case .sCardConnected:
            return languageSettings.localized("ID card detected")
        case .sReaderProcessFailed:
            return languageSettings.localized("ID card reader process failed")
        default:
            return languageSettings.localized("ID card connect card reader")
        }
    }

    private func cancelIdCardAction() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(pinNumber: pinNumber, pinType: pinCodeType)
        resetIdCardAction()
    }

    private func resetIdCardAction() {
        task?.cancel()
        task = nil
        viewModel.resetErrors()
    }

    private func sign(roleData: RoleData? = nil) {
        resetIdCardAction()

        guard let container = signedContainer else {
            Toast.show(
                languageSettings.localized("General error")
            )
            return
        }

        task = Task {
            let updatedContainer = await viewModel.sign(
                pin2: pinNumber,
                signedContainer: container,
                roleData: roleData ?? RoleData(
                    roles: [],
                    city: "",
                    state: "",
                    country: "",
                    zipCode: ""
                )
            )

            pinNumber = ""

            let shouldDismiss = viewModel.shouldDismissForError

            guard let container = updatedContainer else {
                if shouldDismiss {
                    cancelIdCardAction()
                    await viewModel.stopDiscoveringReaders()
                }

                await MainActor.run {
                    Toast.show(errorMessage)
                    viewModel.resetErrors()
                    if shouldDismiss {
                        dismiss()
                    }

                    if viewModel.showIdCardAlertMessage {
                        idCardActionMessage = "ID card connect card reader"
                        isInProgress = false
                        isShowingPinView = false
                        isShowingLoadingView = false
                    } else {
                        isInProgress = !viewModel.shouldDismissForError
                        isShowingPinView = !viewModel.shouldDismissForError
                        isShowingLoadingView = false
                    }
                    return
                }

                return
            }

            await viewModel.stopDiscoveringReaders()
            cancelIdCardAction()
            isInProgress = false
            isShowingPinView = false
            isShowingLoadingView = false

            Toast.show(languageSettings.localized("Signature added"))

            onSuccess(container)
            dismiss()
        }
    }
}

#Preview {
    IdCardView(
        actionType: .signing,
        actionMethods: [
            .idCardViaNFC,
            .idCardViaUSB,
            .mobileId,
            .smartId
        ],
        signedContainer: SignedContainer(
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        ),
        onSuccess: { _ in }
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
