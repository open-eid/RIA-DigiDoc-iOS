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

struct SmartIdView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var country = SmartIdCountry.estonia
    @State private var personalCode = ""
    @State private var rememberMe: Bool = true
    @State private var isSigningEnabled = false
    @State private var isSigning: Bool = false

    @StateObject private var viewModel: SmartIdViewModel

    @State private var task: Task<Void, Never>?

    private let signedContainer: SignedContainerProtocol
    private let onSuccess: (SignedContainerProtocol) -> Void

    init(
        signedContainer: SignedContainerProtocol,
        onSuccess: @escaping (SignedContainerProtocol) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.smartIdViewModel())
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
    }

    var body: some View {
        SignatureInputScreen(
            selectedSigningMethod: SigningMethod.smartId.rawValue,
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
                    let (inputCountry, inputPersonalCode) = rememberMe
                        ? (country, personalCode)
                        : (SmartIdCountry.estonia, "")

                    await viewModel.saveInputData(
                        country: inputCountry,
                        personalCode: inputPersonalCode,
                        rememberMe: rememberMe
                    )

                    isSigning = true
                    let updatedContainer = await viewModel.sign(
                        country: country,
                        personalCode: personalCode,
                        signedContainer: signedContainer
                    )
                    guard let container = updatedContainer else {
                        cancelSigning()
                        isSigning = false
                        if let messageKey = viewModel.smartIdMessageKey,
                           !messageKey.isEmpty {
                            let extraArguments = viewModel.smartIdAlertMessageExtraArguments
                            Toast.show(
                                languageSettings.localized(messageKey, extraArguments)
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
                    if #available(iOS 17.0, *) {
                        ControlCodeView(
                            icon: "smart_id_logo",
                            controlCode: $viewModel.controlCode
                        )
                        .onChange(of: scenePhase) { _, newPhase in
                            switch newPhase {
                            case .background:
                                viewModel.appDidEnterBackground()
                            case .active:
                                viewModel.appDidBecomeActive()
                            default:
                                break
                            }
                        }
                    } else {
                        ControlCodeView(
                            icon: "smart_id_logo",
                            controlCode: $viewModel.controlCode
                        )
                    }
                } else {
                    SmartIdInputView(
                        country: $country,
                        personalCode: $personalCode,
                        rememberMe: $rememberMe,
                        isSigningEnabled: $isSigningEnabled,
                        personalCodeError: $viewModel.personalCodeErrorKey,
                        onInputChange: {
                            isSigningEnabled = viewModel.isSigningEnabled(
                                personalCode: personalCode
                            )
                        }
                    )
                }
            }
        )
        .alert(
            languageSettings.localized(
                viewModel.smartIdAlertMessageKey ?? "",
                viewModel.smartIdAlertMessageExtraArguments
            ),
            isPresented: $viewModel.showSmartIdAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                viewModel.resetErrors()
            }

            if let messageUrl = viewModel.smartIdAlertMessageUrl, !messageUrl.isEmpty {
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
                country = inputData.country
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
    SmartIdView(
        signedContainer: SignedContainer(
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        ),
        onSuccess: { _ in }
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
