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

struct IdCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @State private var isInProgress: Bool = false

    @State private var idCardActionMessage: String = "ID card connect card reader"

    @State private var viewModel: IdCardViewModel

    let signedContainer: SignedContainerProtocol?
    let cryptoContainer: CryptoContainerProtocol?

    let onSuccess: (SignedContainerProtocol) -> Void
    let onSuccessDecrypt: (CryptoContainerProtocol) -> Void

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
            selectedActionMethod: ActionMethod.idCardViaUSB.rawValue,
            isActionEnabled: .constant(true),
            isInProgress: $isInProgress,
            showSubmitButton: false,
            onBackClick: {
                Task {
                    await viewModel.stopDiscoveringReaders()
                }

                guard isInProgress else {
                    dismiss()
                    return
                }
                isInProgress = false
            },
            onSubmit: {},
            content: {
                IdCardActionView(
                    icon: "ic_m3_smart_card_reader_48pt_wght400",
                    message: $idCardActionMessage
                )
            }
        )
        .task {
            await viewModel.startDiscoveringReaders()
        }
        .onChange(of: viewModel.usbReaderStatus) { _, newValue in
            idCardActionMessage = getStatusText(newValue)

            let notInProgressStates: [UsbReaderStatus] = [
                .sInitial,
                .sReaderNotConnected,
                .sReaderProcessFailed
            ]

            isInProgress = !notInProgressStates.contains(newValue)

            Task {
                switch actionType {
                case .decrypt:
                    // TODO: Implement decrypt action
                    isInProgress = true
                case .signing:
                    // TODO: Implement signing action
                    isInProgress = true
                case .myeid:
                    if newValue == .sCardConnected {
                        let idCardData = await viewModel.getIdCardData()

                        guard let cardData = idCardData else {
                            await viewModel.stopDiscoveringReaders()

                            await MainActor.run {
                                Toast.show(viewModel.errorMessage ?? "")
                                viewModel.resetErrors()
                                dismiss()
                            }
                            return
                        }

                        await MainActor.run {
                            isInProgress = true
                            pathManager.replaceLast(
                                to: .myEidView(
                                    idCardData: cardData
                                )
                            )
                        }
                    }
                }
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
}
