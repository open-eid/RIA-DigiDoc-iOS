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

struct MobileIdView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var phoneNumber = Constants.MobileId.DefaultCountryCode
    @State private var personalCode = ""
    @State private var rememberMe: Bool = true
    @State private var isSigningEnabled = false
    @State private var isSigning: Bool = false

    @StateObject private var viewModel: MobileIdViewModel

    @State private var task: Task<Void, Never>?

    let signedContainer: SignedContainerProtocol
    let onSuccess: (SignedContainerProtocol) -> Void

    init(
        signedContainer: SignedContainerProtocol,
        onSuccess: @escaping (SignedContainerProtocol) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.mobileIdViewModel())
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
    }

    var body: some View {
        SignatureInputScreen(
            selectedSigningMethod: "Mobile-ID",
            isSigningEnabled: $isSigningEnabled,
            isSigning: $isSigning,
            onBackClick: {
                cancelSigning()
                guard isSigning else {
                    dismiss()
                    return
                }
                isSigning = false
            },
            onSign: {
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
                        signedContainer: signedContainer
                    )
                    guard let container = updatedContainer else {
                        cancelSigning()
                        isSigning = false
                        if let messageKey = viewModel.mobileIdMessageKey,
                           !messageKey.isEmpty {
                            Toast.show(
                                languageSettings.localized(messageKey)
                            )
                        }

                        return
                    }

                    cancelSigning()

                    onSuccess(container)
                    dismiss()
                }
            },
            content: {
                if isSigning {
                    ControlCodeView(
                        icon: "mobile_id_logo",
                        controlCode: $viewModel.controlCode
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

    func cancelSigning() {
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
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
