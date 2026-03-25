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
import CryptoSwift
import IdCardLib
import LibdigidocLibSwift
import CommonsLib
struct NFCView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @Binding private var isWebEidAuthenticating: Bool

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @State private var canNumber = ""
    @State private var pinNumber = ""
    @State private var pinType: CodeType?
    @State private var rememberMe: Bool = true
    @State private var rememberedCertInvalidated: Bool = false
    @State private var isActionEnabled = false
    @State private var isInProgress: Bool = false
    @State private var showRoleView: Bool = false
    @State private var roleData: RoleData?

    @State private var signingCert: String = ""

    @State private var nfcActionMessage: String = "NFC hold card"

    @State private var viewModel: NFCViewModel
    @State private var webEidViewModel: WebEidViewModel

    @State private var taskSign: Task<Void, Never>?
    @State private var taskDecrypt: Task<Void, Never>?
    @State private var taskMyEid: Task<Void, Never>?

    @State private var taskSignWebEid: Task<Void, Never>?
    @State private var taskAuth: Task<Void, Never>?
    @State private var taskCertificate: Task<Void, Never>?

    private var isNFCSupported: Bool {
        viewModel.isNFCSupported()
    }

    private var nfcErrorMessage: String {
        languageSettings.localized(
            viewModel.nfcErrorKey ?? "",
            viewModel.nfcErrorExtraArguments
        )
    }

    private var canNumberError: Binding<String?> {
        Binding(
            get: { languageSettings.localized(
                viewModel.canNumberErrorKey ?? "",
                viewModel.canNumberErrorExtraArguments
            ) },
            set: { _ in }
        )
    }

    private var pinNumberError: Binding<String?> {
        Binding(
            get: { languageSettings.localized(
                viewModel.pinNumberErrorKey ?? "",
                viewModel.pinNumberErrorExtraArguments
            ) },
            set: { _ in }
        )
    }

    private var displayedMessage: Binding<String> {
        Binding(
            get: {
                isNFCSupported ? nfcActionMessage : "NFC not supported"
            },
            set: { newValue in
                nfcActionMessage = newValue
            }
        )
    }

    private var nfcStringsUtil: NFCSessionStringsUtil {
        NFCSessionStringsUtil { key, args in
            languageSettings.localized(key, args)
        }
    }

    let signedContainer: SignedContainerProtocol?
    let cryptoContainer: CryptoContainerProtocol?

    let onSuccess: (SignedContainerProtocol) -> Void
    let onSuccessDecrypt: (CryptoContainerProtocol) -> Void
    let onSuccessWebEid: () -> Void
    let onErrorWebEid: () -> Void

    init(
        actionType: ActionType,
        actionMethods: [ActionMethod],
        pinType: CodeType? = nil,
        isWebEidAuthenticating: Binding<Bool>,
        rememberMe: Bool = true,
        cryptoContainer: CryptoContainerProtocol? = nil,
        signedContainer: SignedContainerProtocol? = nil,
        onSuccess: @escaping (SignedContainerProtocol) -> Void = { _ in },
        onSuccessDecrypt: @escaping (CryptoContainerProtocol) -> Void = { _ in },
        onSuccessWebEid: @escaping () -> Void = {  },
        onErrorWebEid: @escaping () -> Void = {  },
        webEidViewModel: WebEidViewModel = Container.shared.webEidViewModel()
    ) {
        _viewModel = State(wrappedValue: Container.shared.nfcViewModel())
        _webEidViewModel = State(wrappedValue: webEidViewModel)
        self.actionType = actionType
        self.pinType = pinType
        self._isWebEidAuthenticating = isWebEidAuthenticating
        self.rememberMe = rememberMe
        self.actionMethods = actionMethods
        self.cryptoContainer = cryptoContainer
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
        self.onSuccessDecrypt = onSuccessDecrypt
        self.onSuccessWebEid = onSuccessWebEid
        self.onErrorWebEid = onErrorWebEid
    }

    var body: some View {
        ActionInputScreen(
            actionType: actionType,
            actionMethods: actionMethods,
            selectedActionMethod: .idCardViaNFC,
            isActionEnabled: $isActionEnabled,
            isInProgress: $isInProgress,
            onBackClick: {
                onErrorWebEid()
                if actionType == .signingWebEid || actionType == .auth || actionType == .certificate {
                    Task {
                        await webEidViewModel.handleUserCancelled()
                        if let urlToOpen = webEidViewModel.relyingPartyResponseEvents {
                            openURL(urlToOpen)
                        }
                    }
                }
                Task {
                    await viewModel.clearTempCAN()
                    await webEidViewModel.setWebEidSessionActive(false)
                }
                cancelDecrypt()
                cancelSigning()
                cancelMyEid()
                cancelAuth()
                cancelCertificate()
                cancelSigningWebEid()
                guard isInProgress else {
                    dismiss()
                    return
                }
                isInProgress = false
            },
            onSubmit: {
                switch actionType {
                case .auth:
                    saveInputData()
                    isInProgress = true

                    if !isNFCSupported {
                        return
                    }

                    isWebEidAuthenticating = true
                    Task {
                        auth()
                    }
                case .certificate:
                    saveInputData()
                    isInProgress = true

                    if !isNFCSupported {
                        return
                    }

                    isWebEidAuthenticating = true
                    Task {
                        certificate()
                    }
                case .signingWebEid:
                    saveInputData()
                    isInProgress = true
                    if !isNFCSupported {
                        return
                    }
                    Task {
                        let isRoleDataEnabled = await viewModel.isRoleDataEnabled()
                        if isRoleDataEnabled {
                            showRoleView = true
                        } else {
                            signWebEid()
                        }
                    }
                case .decrypt:
                    saveInputData()
                    isInProgress = true
                    if !isNFCSupported {
                        return
                    }
                    Task {
                        decrypt()
                    }
                case .signing:
                    saveInputData()
                    isInProgress = true
                    if !isNFCSupported {
                        return
                    }
                    Task {
                        let isRoleDataEnabled = await viewModel.isRoleDataEnabled()
                        if isRoleDataEnabled {
                            showRoleView = true
                        } else {
                            sign()
                        }
                    }
                case .myeid:
                    saveInputData()
                    isInProgress = true
                    if !isNFCSupported {
                        return
                    }
                    loadMyEid()
                }
            },
            content: {
                if webEidViewModel.authRequest != nil {
                    if !isWebEidAuthenticating {
                        let origin: String = {
                            if let authRequest = webEidViewModel.authRequest {
                                return authRequest.origin
                            } else {
                                return ""
                            }
                        }()
                        WebEidAuthInfo(origin: origin)
                    }
                }
                if webEidViewModel.certRequest != nil || webEidViewModel.signRequest != nil {
                    if !isWebEidAuthenticating {
                        let origin: String = {
                            if let certRequest = webEidViewModel.certRequest {
                                return certRequest.origin
                            } else if let signRequest = webEidViewModel.signRequest {
                                return signRequest.origin
                            } else {
                                return ""
                            }
                        }()
                        
                        let signingPersonInfo: String? = webEidViewModel.signRequest?.personalData.map {
                            "\($0.givenNames) \($0.surname), \($0.personalCode)"
                        }
                        
                        WebEidSignOrCertificateInfo(
                            origin: origin,
                            isCertificateFlow: webEidViewModel.certRequest != nil,
                            signingPersonInfo: signingPersonInfo,
                        )
                    }
                }
                if isInProgress {
                    NFCActionView(
                        leftIcon: "ic_m3_phonelink_ring_48pt_wght400",
                        rightIcon: "ic_m3_id_card_48pt_wght400",
                        message: displayedMessage
                    )
                } else {
                    NFCInputView(
                        canNumber: $canNumber,
                        rememberMe: $rememberMe,
                        isActionEnabled: $isActionEnabled,
                        canNumberError: canNumberError,
                        pinNumber: $pinNumber,
                        pinError: pinNumberError,
                        pinType: pinType,
                        onInputChange: {
                            isActionEnabled = viewModel
                                .isActionEnabled(
                                    canNumber: canNumber,
                                    pinNumber: pinNumber,
                                    pinType: pinType,
                                    actionType: actionType
                                )
                        },
                        showPinField: actionType != .myeid && actionType != .certificate,
                        isWebEidAuthenticating: isWebEidAuthenticating,
                    )
                }
            }
        )
        .alert(
            languageSettings.localized(
                viewModel.nfcAlertMessageKey ?? "",
                viewModel.nfcAlertMessageExtraArguments
            ),
            isPresented: $viewModel.showNfcAlertMessage
        ) {
            Button(languageSettings.localized("OK")) {
                viewModel.resetErrors()
            }

            if let messageUrl = viewModel.nfcAlertMessageUrl, !messageUrl.isEmpty {
                Button(languageSettings.localized("Additional information")) {
                    if let url = URL(string: languageSettings.localized(messageUrl)),
                       UIApplication.shared.canOpenURL(url) {
                        openURL(url)
                    }
                    viewModel.resetErrors()
                    isInProgress = false
                }
            }
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
        .onAppear {
            Task {
                let inputData = await viewModel.getInputData(actionType, isWebEidAuthenticating)
                canNumber = inputData.canNumber
                rememberMe = inputData.rememberMe

                signingCert = await viewModel.getSigningCertificate()
            }
        }
        .onChange(of: viewModel.nfcErrorKey) { _, newKey in
            guard newKey != nil else { return }
            Toast.show(nfcErrorMessage)
        }
        .onChange(of: viewModel.certMismatch) { _, mismatch in
            if mismatch {
                canNumber = ""
            }
            viewModel.certMismatch = false
        }
        .onDisappear {
            Task {
                let webEidActive = await webEidViewModel.isWebEidSessionActive()
                if !rememberMe && !webEidActive {
                    await viewModel.clearTempCAN()
                }
            }
            cancelMyEid()
            cancelDecrypt()
            cancelSigning()
            cancelAuth()
            cancelCertificate()
            cancelSigningWebEid()
        }
    }

    func saveInputData() {
        Task {
            let (inputCANNumber) = rememberMe ? (canNumber) : ("")
            await viewModel.saveInputData(
                canNumber: inputCANNumber,
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )
        }
    }

    private func decrypt() {
        taskDecrypt = Task {
            guard let container = cryptoContainer else { return }

            let (inputCANNumber) = rememberMe ? (canNumber) : ("")

            await viewModel.saveInputData(
                canNumber: inputCANNumber,
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeForDecrypt(pinName: CodeType.pin1.name)

            let decryptedContainer = await viewModel.decrypt(
                CAN: canNumber,
                pin1: pinNumber,
                cryptoContainer: container,
                strings: strings
            )

            guard let container = decryptedContainer else {
                cancelDecrypt()
                isInProgress = false
                return
            }

            cancelDecrypt()
            isInProgress = false

            onSuccessDecrypt(container)
            dismiss()
        }
    }

    private func sign(roleData: RoleData? = nil) {
        taskSign = Task {
            guard let container = signedContainer else { return }

            await viewModel.saveInputData(
                canNumber: rememberMe ? canNumber : "",
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeForSigning(pinName: CodeType.pin2.name)

            let updatedContainer = await viewModel.sign(
                canNumber: canNumber,
                pin2: pinNumber,
                roleData: roleData ?? RoleData(
                    roles: [],
                    city: "",
                    state: "",
                    country: "",
                    zipCode: ""
                ),
                signedContainer: container,
                strings: strings
            )
            cancelSigning()
            isInProgress = false

            guard let container = updatedContainer else {
                return
            }

            onSuccess(container)
            dismiss()
        }
    }

    private func loadMyEid() {
        taskMyEid = Task {
            await viewModel.saveInputData(
                canNumber: rememberMe ? canNumber : "",
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeDefault()
            let cardData = await viewModel.readCardData(
                CAN: canNumber,
                strings: strings
            )

            isInProgress = false
            guard let cardData else {
                cancelMyEid()
                return
            }

            viewModel.saveMyEidCAN(canNumber)
            await MainActor.run {
                pathManager.replaceLast(
                    to: .myEidView(
                        idCardData: cardData,
                        actionMethod: .idCardViaNFC
                    )
                )
            }
        }
    }

    private func auth() {
        taskAuth = Task {
            await viewModel.saveInputData(
                canNumber: canNumber,
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeDefault(pinName: CodeType.pin1.name)

            let webEidAuthResult = await viewModel.auth(
                canNumber: canNumber,
                pin1: pinNumber,
                origin: webEidViewModel.authRequest?.origin ?? "",
                challenge: webEidViewModel.authRequest?.challenge ?? "",
                strings: strings
            )

            cancelAuth()
            isInProgress = false

            guard let result = webEidAuthResult else {
                onErrorWebEid()
                return
            }

            let encodedCert = result.signingCert.base64EncodedString()
            await viewModel.setSigningCertificate(encodedCert)

            await webEidViewModel.handleWebEidAuthResult(
                authCert: result.authCert,
                signingCert: result.signingCert,
                signature: result.signatureArray
            )

            onSuccessWebEid()
            dismiss()
        }
    }

    private func certificate() {
        taskCertificate = Task {
            await viewModel.saveInputData(
                canNumber: canNumber,
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeDefault()

            let cachedCert = await viewModel.getSigningCertificate()

            let rememberedCan = await viewModel.retrieveEncryptedCAN() ?? ""

            let canSkipCertificateRead = rememberMe && !cachedCert.isEmpty &&
                    !rememberedCan.isEmpty && canNumber == rememberedCan

            if canSkipCertificateRead {
                guard let certBytes = Data(base64Encoded: cachedCert) else {
                    onErrorWebEid()
                    return
                }

                await webEidViewModel.handleWebEidCertificateResult(signingCert: certBytes)
                onSuccessWebEid()
            } else {
                let webEidCertResult = await viewModel.certificate(
                    canNumber: canNumber,
                    strings: strings
                )

                guard let signCert = webEidCertResult else {
                    onErrorWebEid()
                    return
                }

                await viewModel.setSigningCertificate(signCert)
                guard let certBytes = Data(base64Encoded: signCert) else {
                    onErrorWebEid()
                    return
                }
                await webEidViewModel.handleWebEidCertificateResult(signingCert: certBytes)
                onSuccessWebEid()
            }

            cancelCertificate()
            isInProgress = false

            dismiss()
        }
    }

    private func signWebEid() {
        taskSignWebEid = Task {
            await viewModel.saveInputData(
                canNumber: canNumber,
                rememberMe: rememberMe,
                actionType: actionType,
                isWebEidAuthenticating: isWebEidAuthenticating
            )

            isInProgress = true
            nfcActionMessage = "NFC hold card"

            let strings = nfcStringsUtil.makeForSigning(pinName: CodeType.pin2.name)

            let expectedSigningCertBase64 = await viewModel.getSigningCertificate()
            let webEidSignResult = await viewModel.signWebEid(
                canNumber: canNumber,
                pin2: pinNumber,
                responseUri: webEidViewModel.signRequest?.responseUri ?? "",
                hash: webEidViewModel.signRequest?.hash ?? "",
                expectedSigningCertBase64: expectedSigningCertBase64,
                strings: strings
            )

            cancelSigningWebEid()
            isInProgress = false

            guard let result = webEidSignResult else {
                onErrorWebEid()
                return
            }

            await webEidViewModel.handleWebEidSignResult(
                signingCert: result.signerCertB64,
                signature: result.signatureArray,
                responseUri: result.responseUri
            )

            onSuccessWebEid()
            dismiss()
        }
    }

    private func cancelDecrypt() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
        taskDecrypt?.cancel()
        taskDecrypt = nil
    }

    private func cancelSigning() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
        taskSign?.cancel()
        taskSign = nil
    }

    private func cancelMyEid() {
        taskMyEid?.cancel()
        taskMyEid = nil
    }

    private func cancelAuth() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
        taskAuth?.cancel()
        taskAuth = nil
    }

    private func cancelSigningWebEid() {
        pinNumber.isEmpty ? () : (pinNumber.removeAll())
        isActionEnabled = viewModel
            .isActionEnabled(canNumber: canNumber, pinNumber: pinNumber, pinType: pinType)
        taskSignWebEid?.cancel()
        taskSignWebEid = nil
    }

    private func cancelCertificate() {
        taskCertificate?.cancel()
        taskCertificate = nil
    }
}

#Preview {
    NFCView(
        actionType: .signing,
        actionMethods: [
            .idCardViaNFC,
            .idCardViaUSB,
            .mobileId,
            .smartId
        ],
        pinType: CodeType.pin2,
        isWebEidAuthenticating: .constant(false),
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
