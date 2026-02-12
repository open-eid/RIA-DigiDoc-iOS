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
import LibdigidocLibSwift
import CommonsLib
import IdCardLib
import UtilsLib

struct MyEidView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var selectedTab: MyEidViewTab = .myData

    @State private var isPin1Blocked: Bool = false
    @State private var isPin2Blocked: Bool = false
    @State private var isPukBlocked: Bool = false
    @State private var isPin2Activated: Bool = false

    @State private var pinChangeVariant: PinChangeVariant?

    @State private var viewModel: MyEidViewModel

    private let idCardData: IdCardData
    private let actionMethod: ActionMethod

    private var myDataTitle: String {
        languageSettings.localized("My data")
    }

    private var pinsAndCertificatesTitle: String {
        languageSettings.localized("PINs and certificates")
    }

    private var pin1Guidelines: String {
        """
        • \(languageSettings.localized("PIN1 guideline 1"))
        • \(languageSettings.localized("PIN1 guideline 2"))
        • \(languageSettings.localized("PIN1 guideline 3"))
        """
    }

    private var pin2Guidelines: String {
        """
        • \(languageSettings.localized("PIN2 guideline 1"))
        • \(languageSettings.localized("PIN2 guideline 2"))
        • \(languageSettings.localized("PIN2 guideline 3"))
        """
    }

    private var pukGuidelines: String {
        """
        • \(languageSettings.localized("PUK guideline 1"))
        • \(languageSettings.localized("PUK guideline 2"))
        """
    }

    init(
        idCardData: IdCardData,
        actionMethod: ActionMethod
    ) {
        _viewModel = State(wrappedValue: Container.shared.myEidViewModel())
        self.idCardData = idCardData
        self.actionMethod = actionMethod

        viewModel.setIsPinBlocked(.pin1, isBlocked: idCardData.retryCount.pin1 == 0)
        viewModel.setIsPinBlocked(.pin2, isBlocked: idCardData.retryCount.pin2 == 0)
        viewModel.setIsPinBlocked(.puk, isBlocked: idCardData.retryCount.puk == 0)
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: languageSettings.localized("Main home my eid title"),
                onLeftClick: {
                    Task {
                        await viewModel.stopDiscoveringReaders()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                },
                content: {
                    ScrollView {
                        VStack {
                            TabView(selectedTab: $selectedTab, titles: [
                                myDataTitle,
                                pinsAndCertificatesTitle
                            ]) {
                                if selectedTab == .myData {
                                    MyEidDataView(
                                        givenName: idCardData.publicData.givenName,
                                        surname: idCardData.publicData.surname,
                                        citizenship: idCardData.publicData.citizenship,
                                        personalCode: idCardData.publicData.personalCode,
                                        dateOfBirth: viewModel.parseDateOfBirth(
                                            personalCode: idCardData.publicData.personalCode
                                        ),
                                        idCardNumber: idCardData.publicData.documentNumber,
                                        dateOfExpiry: viewModel
                                            .parseExpiryDate(expiryDate: idCardData.publicData.dateOfExpiry),
                                        documentExpirationStatus: viewModel
                                            .getDocumentExpirationStatus(expiryDate: idCardData.publicData.dateOfExpiry)
                                    )
                                } else if selectedTab == .pinsAndCertificates {
                                    MyEidPinsAndCertificatesView(
                                        isPin1Blocked: $isPin1Blocked,
                                        isPin2Blocked: $isPin2Blocked,
                                        isPukBlocked: $isPukBlocked,
                                        pinChangeVariant: $pinChangeVariant,
                                        authCertValidTo: idCardData.authCertNotValidDate ?? "",
                                        signCertValidTo: idCardData.signCertNotValidDate ?? "",
                                        isPUKChangeable: idCardData.isPUKChangeable
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, Dimensions.Padding.SPadding)
                    }
                }
            )

            if let modal = pinChangeVariant {
                pinGuideline(
                    pinVariant: modal,
                    onConfirm: {
                        switch modal {
                        case .pin1Change:
                            pathManager.navigate(
                                to: .myEidPinView(
                                    pinAction: .change,
                                    codeType: .pin1,
                                    personalCode: idCardData.publicData.personalCode,
                                    actionMethod: actionMethod
                                )
                            )

                        case .pin1Unblock:
                            pathManager
                                .navigate(
                                    to: .myEidPinView(
                                        pinAction: .unblock,
                                        codeType: .pin1,
                                        personalCode: idCardData.publicData.personalCode,
                                        actionMethod: actionMethod
                                    )
                                )

                        case .pin2Change:
                            pathManager.navigate(
                                to: .myEidPinView(
                                    pinAction: .change,
                                    codeType: .pin2,
                                    personalCode: idCardData.publicData.personalCode,
                                    actionMethod: actionMethod
                                )
                            )

                        case .pin2Unblock:
                            pathManager
                                .navigate(
                                    to: .myEidPinView(
                                        pinAction: .unblock,
                                        codeType: .pin2,
                                        personalCode: idCardData.publicData.personalCode,
                                        actionMethod: actionMethod
                                    )
                                )

                        case .pukChange:
                            pathManager.navigate(
                                to: .myEidPinView(
                                    pinAction: .change,
                                    codeType: .puk,
                                    personalCode: idCardData.publicData.personalCode,
                                    actionMethod: actionMethod
                                )
                            )
                        }

                        pinChangeVariant = nil
                    },
                    onCancel: {
                        pinChangeVariant = nil
                    }
                )
            }
        }
        .task(id: viewModel.usbReaderStatus) {
            if actionMethod == .idCardViaUSB &&
                viewModel.usbReaderStatus != .sCardConnected {
                await viewModel.stopDiscoveringReaders()
                await MainActor.run {
                    pathManager.replaceLast(to: .myEidRootView)
                }
            }
        }
        .onAppear {
            isPin1Blocked = viewModel.getIsPinBlocked(for: .pin1)
            isPin2Blocked = viewModel.getIsPinBlocked(for: .pin2)
            isPukBlocked = viewModel.getIsPinBlocked(for: .puk)
        }
    }

    @ViewBuilder
    private func pinGuideline(
        pinVariant: PinChangeVariant,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {

        let config = configuration(for: pinVariant)

        ConfirmModalView(
            title: languageSettings.localized("PIN guideline title", [config.codeType.name]),
            message: config.guidelines,
            confirmButtonTitle: config.confirmTitle,
            cancelButtonTitle: languageSettings.localized("Close"),
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }

    private func configuration(
        for modal: PinChangeVariant
    ) -> (codeType: CodeType, guidelines: String, confirmTitle: String) {

        switch modal {
        case .pin1Change:
            return (
                .pin1,
                pin1Guidelines,
                languageSettings.localized("Change PIN", [CodeType.pin1.name])
            )

        case .pin1Unblock:
            return (
                .pin1,
                pin1Guidelines,
                languageSettings.localized("Unblock PIN", [CodeType.pin1.name])
            )

        case .pin2Change:
            return (
                .pin2,
                pin2Guidelines,
                languageSettings.localized("Change PIN", [CodeType.pin2.name])
            )

        case .pin2Unblock:
            return (
                .pin2,
                pin2Guidelines,
                languageSettings.localized("Unblock PIN", [CodeType.pin2.name])
            )

        case .pukChange:
            return (
                .puk,
                pukGuidelines,
                languageSettings.localized("Change PIN", [CodeType.puk.name])
            )
        }
    }

}

#Preview {
    MyEidView(
        idCardData: IdCardData(
            publicData: CardInfo(
                givenName: "Given name",
                surname: "Surname",
                personalCode: "12345678901",
                citizenship: "EST",
                documentNumber: "A123456789",
                dateOfExpiry: Date().formatted()
            ),
            authCertNotValidDate: nil,
            signCertNotValidDate: nil,
            retryCount: RetryCount(
                pin1: 3,
                pin2: 3,
                puk: 3
            ),
            isPUKChangeable: true
        ),
        actionMethod: .idCardViaNFC
    )
}
