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

struct IdCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @State private var isInProgress: Bool = false

    @State private var idCardActionMessage: String = "ID card connect card reader"

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
                guard isInProgress else {
                    dismiss()
                    return
                }
                isInProgress = false
            },
            onSubmit: {
                switch actionType {
                case .decrypt:
                    // TODO: Implement decrypt action
                    isInProgress = true
                case .signing:
                    // TODO: Implement signing action
                    isInProgress = true
                case .myeid:
                    // TODO: Implement My eID personal data loading action
                    isInProgress = true
                }
            },
            content: {
                IdCardActionView(
                    icon: "ic_m3_smart_card_reader_48pt_wght400",
                    message: $idCardActionMessage
                )
            }
        )
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
