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
import IdCardLib
import UtilsLib

struct WebEidView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var viewModel: WebEidViewModel
    @State private var nfcViewModel: NFCViewModel
    @State private var isWebEidAuthenticating: Bool = false

    private var webEidUrl: URL

    private let signedContainer: GeneralContainer?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    private var errorMessage: String {
        languageSettings.localized(
            viewModel.errorKey ?? "",
            viewModel.errorExtraArguments
        )
    }

    private var alertTitle: String {
        languageSettings.localized(
            viewModel.alertMessageKey ?? "",
            viewModel.alertMessageExtraArguments
        )
    }

    private var alertInfoURL: URL? {
        guard
            let messageUrl = viewModel.alertMessageUrl,
            !messageUrl.isEmpty
        else {
            return nil
        }

        let localizedUrl = languageSettings.localized(messageUrl)
        guard let url = URL(string: localizedUrl), UIApplication.shared.canOpenURL(url) else {
            return nil
        }

        return url
    }

    private func handleWebEidOperation(for url: URL) {
        if let operation = WebEidUriUtil.getOperation(from: url) {
            switch operation {
            case .auth:
                viewModel.handleAuth(url: url)
            case .cert:
                viewModel.handleCertificate(url: url)
            case .sign:
                viewModel.handleSign(url: url)
            }
        } else {
            viewModel.handleUnknown(url: url)
        }
    }

    private func activateWebEidSession() {
        Task {
            if await viewModel.isWebEidSessionActive() {
                await nfcViewModel.clearTempCAN()
            }
            await viewModel.setWebEidSessionActive(true)
        }
    }

    init(
        webEidUrl: URL,
    ) {
        _viewModel = State(wrappedValue: Container.shared.webEidViewModel())
        _nfcViewModel = State(wrappedValue: Container.shared.nfcViewModel())
        self.webEidUrl = webEidUrl
        self.sharedContainerViewModel = Container.shared.sharedContainerViewModel()
        self.signedContainer = sharedContainerViewModel.currentContainer()
    }

    var body: some View {
        ZStack {
            if viewModel.authRequest != nil {
                NFCView(
                    actionType: .auth,
                    actionMethods: [
                        .idCardViaNFC
                    ],
                    pinType: CodeType.pin1,
                    isWebEidAuthenticating: $isWebEidAuthenticating,
                    onSuccessWebEid: {
                        isWebEidAuthenticating = false
                    },
                    onErrorWebEid: {
                        isWebEidAuthenticating = false
                    },
                    webEidViewModel: viewModel
                )
            }
            if viewModel.certRequest != nil || viewModel.signRequest != nil {
                if viewModel.certRequest != nil {
                    NFCView(
                        actionType: .certificate,
                        actionMethods: [
                            .idCardViaNFC
                        ],
                        isWebEidAuthenticating: $isWebEidAuthenticating,
                        onSuccessWebEid: {
                            isWebEidAuthenticating = false
                        },
                        onErrorWebEid: {
                            isWebEidAuthenticating = false
                        },
                        webEidViewModel: viewModel
                    )
                } else {
                    NFCView(
                        actionType: .signingWebEid,
                        actionMethods: [
                            .idCardViaNFC
                        ],
                        pinType: CodeType.pin2,
                        isWebEidAuthenticating: $isWebEidAuthenticating,
                        onSuccessWebEid: {
                            isWebEidAuthenticating = false
                            Task {
                                await nfcViewModel.clearTempCAN()
                                await viewModel.setWebEidSessionActive(false)
                            }
                        },
                        onErrorWebEid: {
                            isWebEidAuthenticating = false
                        },
                        webEidViewModel: viewModel
                    )
                }
            }
        }
        .alert(
            alertTitle,
            isPresented: $viewModel.showAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                viewModel.resetErrors()
            }

            if let alertInfoURL {
                Button(languageSettings.localized("Additional information")) {
                    openURL(alertInfoURL)
                    viewModel.resetErrors()
                }
            }
        }
        .onAppear {
            handleWebEidOperation(for: webEidUrl)
        }
        .onChange(of: viewModel.relyingPartyResponseEvents) { _, responseURL in
            guard let responseURL else { return }

            openURL(responseURL)

            viewModel.relyingPartyResponseEvents = nil
        }
        .onChange(of: viewModel.errorKey) { _, newKey in
            guard newKey != nil else { return }
            Toast.show(errorMessage)
        }
        .onChange(of: webEidUrl) {_, url in
            handleWebEidOperation(for: url)
        }
        .onChange(of: viewModel.authRequest) {_, _ in
            activateWebEidSession()
        }
        .onChange(of: viewModel.certRequest) {_, _ in
            activateWebEidSession()
        }
    }
}

#Preview {
    WebEidView(
        webEidUrl: URL(fileURLWithPath: "")
    )
}
