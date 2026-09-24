// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoObjCWrapper
import LibdigidocLibSwift
import nfclib

public enum NavigationDestination: Hashable {
    case contentView

    case recentDocumentsView(
        folderURL: URL?,
        extensions: [String]
    )

    case encryptRecipientView(cdocOption: EncryptionCdocOption)

    case signingView
    case signatureDetailView(
        signature: SignatureWrapper,
        isTimestamp: Bool,
        containerMimetype: String,
        dataFilesCount: Int
    )
    case certificateDetailView(certificate: Data)
    case containerNotificationsView(
        notifications: [ContainerNotificationType]
    )
    case decryptRootView
    case signingRootView
    case signingMethodSelectionView(
        actionType: ActionType,
        methods: [ActionMethod]
    )

    case encryptView(
        isWithEncryption: Bool,
        cdocOption: EncryptionCdocOption,
        selectedTab: EncryptViewTab
    )

    case recipientDetailView(
        recipient: Addressee,
    )

    case languageChooserView
    case themeChooserView
    case advancedSettingsView

    case infoView
    case accessibilityView
    case diagnosticsView

    case signingServicesSettingsView
    case validationSettingsView
    case encryptionSettingsView
    case proxySettingsView

    case myEidRootView
    case myEidView(
        idCardData: IdCardData,
        actionMethod: ActionMethod
    )

    case myEidPinView(
        pinAction: MyEidPinCodeAction,
        codeType: CodeType,
        personalCode: String,
        actionMethod: ActionMethod
    )

    case webEidView(
        webEidURL: URL
    )
}
