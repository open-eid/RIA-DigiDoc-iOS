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

struct SmartIdView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var country = SmartIdCountry.estonia
    @State private var personalCode = ""
    @State private var rememberMe: Bool = true
    @State private var isSigningEnabled = false
    @State private var isSigning: Bool = false
    @State private var showRoleView: Bool = false

    @State private var viewModel: SmartIdViewModel

    @State private var task: Task<Void, Never>?

    private var liveActivityTexts: SmartIdLiveActivityTexts {
        SmartIdLiveActivityTexts(
            initialMessage: languageSettings.localized("Smart-ID signing info message"),
            controlCodeTitle: languageSettings.localized("Smart-ID notification title"),
            compactTitle: languageSettings.localized("Code")
        )
    }

    private let signedContainer: SignedContainerProtocol
    private let onSuccess: (SignedContainerProtocol) -> Void

    init(
        signedContainer: SignedContainerProtocol,
        onSuccess: @escaping (SignedContainerProtocol) -> Void
    ) {
        _viewModel = State(wrappedValue: Container.shared.smartIdViewModel())
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
    }

    var body: some View {
        ActionInputScreen(
            selectedActionMethod: .smartId,
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
                        icon: "smart_id_logo",
                        controlCode: $viewModel.controlCode,
                        infoMessage: $viewModel.infoMessage
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
        .onChange(of: viewModel.smartIdSuccessMessageKey, { _, newValue in
            if let messageKey = newValue, !messageKey.isEmpty {
                Toast.show(
                    languageSettings.localized(messageKey),
                    type: .success
                )
                viewModel.smartIdSuccessMessageKey = nil
            }
        })
        .onChange(of: viewModel.smartIdErrorMessageKey, { _, newValue in
            if let messageKey = newValue, !messageKey.isEmpty {
                let extraArguments = viewModel.smartIdAlertMessageExtraArguments
                Toast.show(
                    languageSettings.localized(messageKey, extraArguments)
                )
                viewModel.smartIdErrorMessageKey = nil
                viewModel.smartIdAlertMessageExtraArguments = []
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
                country = inputData.country
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
                roleData: roleData ?? RoleData(
                    roles: [],
                    city: "",
                    state: "",
                    country: "",
                    zipCode: ""
                ),
                signedContainer: signedContainer,
                liveActivityTexts: liveActivityTexts
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
    SmartIdView(
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
