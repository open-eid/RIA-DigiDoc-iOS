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
                if !isWebEidAuthenticating {
                    let origin: String = {
                        if let authRequest = viewModel.authRequest {
                            return authRequest.origin
                        } else {
                            return ""
                        }
                    }()
                    WebEidAuthInfo(origin: origin)
                }
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
                if !isWebEidAuthenticating {
                    let origin: String = {
                        if let certRequest = viewModel.certRequest {
                            return certRequest.origin
                        } else if let signRequest = viewModel.signRequest {
                            return signRequest.origin
                        } else {
                            return ""
                        }
                    }()

                    let signingPersonInfo: String? = viewModel.signRequest?.personalData.map {
                        "\($0.givenNames) \($0.surname), \($0.personalCode)"
                    }

                    WebEidSignOrCertificateInfo(
                        origin: origin,
                        isCertificateFlow: viewModel.certRequest != nil,
                        signingPersonInfo: signingPersonInfo,
                    )
                }
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
                        actionType: .signing,
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
            languageSettings.localized(
                viewModel.alertMessageKey ?? "",
                viewModel.alertMessageExtraArguments
            ),
            isPresented: $viewModel.showAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                viewModel.resetErrors()
            }

            if let messageUrl = viewModel.alertMessageUrl, !messageUrl.isEmpty {
                Button(languageSettings.localized("Additional information")) {
                    if let url = URL(string: languageSettings.localized(messageUrl)),
                       UIApplication.shared.canOpenURL(url) {
                        openURL(url)
                    }
                    viewModel.resetErrors()
                }
            }
        }
        .onAppear {
            if let host = webEidUrl.host {

                switch host {
                case "auth":
                    viewModel.handleAuth(url: webEidUrl)
                case "cert":
                    viewModel.handleCertificate(url: webEidUrl)
                case "sign":
                    viewModel.handleSign(url: webEidUrl)
                default:
                    viewModel.handleUnknown(url: webEidUrl)
                }
            }
        }
        .onChange(of: viewModel.relyingPartyResponseEvents) { _, responseURL in
            guard let responseURL else { return }

            openURL(responseURL)
            dismiss()

            viewModel.relyingPartyResponseEvents = nil
        }
        .onChange(of: viewModel.errorKey) { _, newKey in
            guard newKey != nil else { return }
            Toast.show(errorMessage)
        }
        .onChange(of: webEidUrl) {_, url in
            if let host = url.host {

                switch host {
                case "auth":
                    viewModel.handleAuth(url: url)
                case "cert":
                    viewModel.handleCertificate(url: url)
                case "sign":
                    viewModel.handleSign(url: url)
                default:
                    viewModel.handleUnknown(url: url)
                }
            }
        }
        .onChange(of: viewModel.authRequest) {_, _ in
            Task {
                if (await viewModel.isWebEidSessionActive()) {
                    await nfcViewModel.clearTempCAN()
                }
                await viewModel.setWebEidSessionActive(true)
            }
        }
        .onChange(of: viewModel.certRequest) {_, _ in
            Task {
                if (await viewModel.isWebEidSessionActive()) {
                    await nfcViewModel.clearTempCAN()
                }
                await viewModel.setWebEidSessionActive(true)
            }
        }
    }
}

#Preview {
    WebEidView(
        webEidUrl: URL(fileURLWithPath: "")
    )
}
