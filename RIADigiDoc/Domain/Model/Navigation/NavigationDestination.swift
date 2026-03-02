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

import Foundation
import CryptoObjCWrapper
import LibdigidocLibSwift
import IdCardLib

public enum NavigationDestination: Hashable {
    case contentView

    case recentDocumentsView(
        folderURL: URL?,
        extensions: [String]
    )

    case encryptRecipientView

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
        isWithEncryption: Bool
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
