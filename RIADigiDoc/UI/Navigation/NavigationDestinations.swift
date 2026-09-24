// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

// swiftlint:disable cyclomatic_complexity
struct NavigationDestinations: ViewModifier {
    let pathManager: NavigationPathManager

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
                    .environment(pathManager)
            }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .contentView:
            ContentView()

        case .recentDocumentsView(let folderURL, let extensions):
            RecentDocumentsView(folderURL: folderURL, extensions: extensions)

        case .encryptRecipientView(let cdocOption):
            EncryptRecipientView(cdocOption: cdocOption)

        case .signingView:
            SigningView()
        case .signatureDetailView(
            let signature,
            let isTimestamp,
            let containerMimetype,
            let dataFilesCount
        ):
            SignatureDetailView(
                signature: signature,
                isTimestamp: isTimestamp,
                containerMimetype: containerMimetype,
                dataFilesCount: dataFilesCount
            )
        case .certificateDetailView(let certificate):
            CertificateDetailView(certificate: certificate)
        case .containerNotificationsView(let notifications):
            ContainerNotificationsView(notifications: notifications)

        case .decryptRootView:
            DecryptRootView()

        case .signingRootView:
            SigningRootView()

        case .signingMethodSelectionView(let actionType, let methods):
            ActionMethodSelectionView(actionType: actionType, methods: methods)

        case .encryptView(
            let isWithEncryption,
            let cdocOption,
            let selectedTab
        ):
            EncryptView(
                isWithEncryption: isWithEncryption,
                cdocOption: cdocOption,
                selectedTab: selectedTab
            )
        case .recipientDetailView(
            let recipient,
        ):
            RecipientDetailView(
                recipient: recipient,
            )

        case .languageChooserView:
            LanguageChooserView()
        case .themeChooserView:
            ThemeChooserView()
        case .advancedSettingsView:
            AdvancedSettingsView()

        case .infoView:
            InfoView()
        case .accessibilityView:
            AccessibilityView()
        case .diagnosticsView:
            DiagnosticsView()

        case .signingServicesSettingsView:
            SigningServicesSettingsView()
        case .validationSettingsView:
            ValidationSettingsView()
        case .encryptionSettingsView:
            EncryptionSettingsView()
        case .proxySettingsView:
            ProxySettingsView()

        case .myEidRootView:
            MyEidRootView()

        case .myEidView(let idCardData, let actionMethod):
            MyEidView(idCardData: idCardData, actionMethod: actionMethod)
        case .myEidPinView(let pinAction, let codeType, let personalCode, let actionMethod):
            MyEidPinChangeView(
                pinAction: pinAction,
                codeType: codeType,
                personalCode: personalCode,
                actionMethod: actionMethod
            )
        case .webEidView(let webEidURL):
            WebEidView(webEidUrl: webEidURL)
        }
    }
}

extension View {
    func appNavigation(pathManager: NavigationPathManager) -> some View {
        modifier(NavigationDestinations(pathManager: pathManager))
    }
}
// swiftlint:enable cyclomatic_complexity
