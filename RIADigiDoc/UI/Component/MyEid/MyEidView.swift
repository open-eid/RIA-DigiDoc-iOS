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

import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import nfclib
import UtilsLib

struct MyEidView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AccessibilityFocusState private var isTabFocused: Bool

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

        viewModel.setIsPinLocked(.pin1, isLocked: idCardData.pinResponse.pin1Active != true)
        viewModel.setIsPinLocked(.pin2, isLocked: idCardData.pinResponse.pin2Active != true)
        viewModel.setIsPinLocked(.puk, isLocked: idCardData.pinResponse.pukActive != true)

        viewModel.setIsPinBlocked(.pin1, isBlocked: idCardData.pinResponse.pin1RetryCount == 0)
        viewModel.setIsPinBlocked(.pin2, isBlocked: idCardData.pinResponse.pin2RetryCount == 0)
        viewModel.setIsPinBlocked(.puk, isBlocked: idCardData.pinResponse.pukRetryCount == 0)
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: languageSettings.localized("Main home my eid title"),
                titleAccessibility: languageSettings.localized("My eid title accessibility"),
                onLeftClick: {
                    dismiss()
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
                                    .padding(.top, Dimensions.Padding.SPadding)
                                } else if selectedTab == .pinsAndCertificates {
                                    MyEidPinsAndCertificatesView(
                                        isPin1Blocked: $isPin1Blocked,
                                        isPin2Blocked: $isPin2Blocked,
                                        isPukBlocked: $isPukBlocked,
                                        isPin2Activated: $isPin2Activated,
                                        pinChangeVariant: $pinChangeVariant,
                                        authCertValidTo: idCardData.authCertNotValidDate ?? "",
                                        signCertValidTo: idCardData.signCertNotValidDate ?? "",
                                        isPUKChangeable: idCardData.isPUKChangeable
                                    )
                                    .padding(.top, Dimensions.Padding.SPadding)
                                }
                            }
                            .padding(.top, Dimensions.Padding.SPadding)
                            .accessibilityFocused($isTabFocused)
                            .onAppear {
                                DispatchQueue.main.async {
                                    isTabFocused = true
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
                .accessibilityAddTraits(.isModal)
            }
        }
        .onAppear {
            isPin2Activated = !viewModel.getIsPinLocked(for: .pin2)
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
        let isConfirmButtonVisible =
            if config.codeType == .puk {
                idCardData.isPUKChangeable
            } else {
                true
            }
        ConfirmModalView(
            title: languageSettings.localized("PIN guideline title", [config.codeType.name]),
            message: config.guidelines,
            isConfirmButtonVisible: isConfirmButtonVisible,
            messageAccessibility: config.guidelines.replacing("•", with: ""),
            confirmButtonTitle: config.confirmTitle,
            cancelButtonTitle: languageSettings.localized("Close"),
            onConfirm: onConfirm,
            onCancel: onCancel
        )
        .accessibilityAddTraits(.isModal)
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
            pinResponse: PinResponse(
                pin1RetryCount: 3,
                pin1Active: true,
                pin2RetryCount: 3,
                pin2Active: true,
                pukRetryCount: 3,
                pukActive: true,
            ),
            isPUKChangeable: true
        ),
        actionMethod: .idCardViaNFC
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
