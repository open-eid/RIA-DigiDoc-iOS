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

struct MobileIdView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var phoneNumber = Constants.MobileId.DefaultCountryCode
    @State private var personalCode = ""
    @State private var rememberMe: Bool = true
    @State private var isSigningEnabled = false
    @State private var isSigning: Bool = false
    @State private var showRoleView: Bool = false

    @State private var viewModel: MobileIdViewModel

    @State private var task: Task<Void, Never>?

    private var infoMessage: String {
        languageSettings.localized(viewModel.infoMessage)
    }

    let signedContainer: SignedContainerProtocol
    let onSuccess: (SignedContainerProtocol) -> Void

    init(
        signedContainer: SignedContainerProtocol,
        onSuccess: @escaping (SignedContainerProtocol) -> Void
    ) {
        _viewModel = State(wrappedValue: Container.shared.mobileIdViewModel())
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
    }

    var body: some View {
        ActionInputScreen(
            selectedActionMethod: .mobileId,
            isActionEnabled: $isSigningEnabled,
            isInProgress: $isSigning,
            onBackClick: {
                cancelSigning()
                guard isSigning else {
                    dismiss()
                    return
                }
                isSigning = false
            },
            onSubmit: {
                Task {
                    let isRoleDataEnabled = await viewModel.isRoleDataEnabled()
                    if isRoleDataEnabled {
                        showRoleView = true
                    } else {
                        sign()
                    }
                }
            },
            content: {
                if isSigning {
                    ControlCodeView(
                        icon: "mobile_id_logo",
                        controlCode: $viewModel.controlCode,
                        infoMessage: $viewModel.infoMessage
                    )
                } else {
                    MobileIdInputView(
                        phoneNumber: $phoneNumber,
                        personalCode: $personalCode,
                        rememberMe: $rememberMe,
                        isSigningEnabled: $isSigningEnabled,
                        countryCodeAndPhoneError: $viewModel.countryCodeAndPhoneErrorKey,
                        personalCodeError: $viewModel.personalCodeErrorKey,
                        onInputChange: {
                            isSigningEnabled = viewModel.isSigningEnabled(
                                phoneNumber: phoneNumber,
                                personalCode: personalCode
                            )
                        }
                    )
                }
            }
        )
        .alert(
            languageSettings.localized(
                viewModel.mobileIdAlertMessageKey ?? "",
                viewModel.mobileIdAlertMessageExtraArguments
            ),
            isPresented: $viewModel.showMobileIdAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                viewModel.resetErrors()
            }

            if let messageUrl = viewModel.mobileIdAlertMessageUrl, !messageUrl.isEmpty {
                Button(languageSettings.localized("Additional information")) {
                    if let url = URL(string: languageSettings.localized(messageUrl)),
                       UIApplication.shared.canOpenURL(url) {
                        openURL(url)
                    }
                    viewModel.resetErrors()
                    isSigning = false
                }
            }
        }
        .onChange(of: viewModel.mobileIdSuccessMessageKey, { _, newValue in
            if let messageKey = newValue,
               !messageKey.isEmpty {
                Toast.show(
                    languageSettings.localized(messageKey),
                    type: .success
                )
                viewModel.mobileIdSuccessMessageKey = nil
            }
        })
        .onChange(of: viewModel.mobileIdErrorMessageKey, { _, newValue in
            if let messageKey = newValue,
               !messageKey.isEmpty {
                let extraArguments = viewModel.mobileIdAlertMessageExtraArguments
                Toast.show(
                    languageSettings.localized(messageKey, extraArguments)
                )
                viewModel.mobileIdErrorMessageKey = nil
                viewModel.mobileIdAlertMessageExtraArguments = []
            }
        })
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
        .onAppear {
            Task {
                let inputData = await viewModel.getInputData()
                phoneNumber = inputData.phoneNumber
                personalCode = inputData.personalCode
                rememberMe = inputData.rememberMe
            }
        }
        .onDisappear {
            cancelSigning()
        }
    }

    private func sign(roleData: RoleData? = nil) {
        cancelSigning()

        task = Task {
            let (inputPhoneNumber, inputPersonalCode) = rememberMe
                ? (phoneNumber, personalCode)
                : (Constants.MobileId.DefaultCountryCode, "")

            await viewModel.saveInputData(
                phoneNumber: inputPhoneNumber,
                personalCode: inputPersonalCode,
                rememberMe: rememberMe
            )

            isSigning = true
            let updatedContainer = await viewModel.sign(
                phoneNumber: phoneNumber,
                personalCode: personalCode,
                roleData: roleData ?? RoleData(
                    roles: [],
                    city: "",
                    state: "",
                    country: "",
                    zipCode: ""
                ),
                signedContainer: signedContainer
            )
            guard let container = updatedContainer else {
                cancelSigning()
                isSigning = false
                return
            }

            cancelSigning()
            isSigning = false

            onSuccess(container)
            dismiss()
        }
    }

    private func cancelSigning() {
        task?.cancel()
        task = nil
    }
}

#Preview {
    MobileIdView(
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
