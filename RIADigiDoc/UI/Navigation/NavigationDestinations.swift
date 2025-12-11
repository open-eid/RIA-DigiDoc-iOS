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

        case .encryptRecipientView:
            EncryptRecipientView()

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

        case .signingRootView:
            SigningRootView()

        case .signingMethodSelectionView:
            SigningMethodSelectionView()

        case .encryptView(
            let isWithEncryption
        ):
            EncryptView(
                isWithEncryption: isWithEncryption,
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

        case .homeView:
            HomeView(externalFiles: .constant([]))
        }
    }
}

extension View {
    func appNavigation(pathManager: NavigationPathManager) -> some View {
        modifier(NavigationDestinations(pathManager: pathManager))
    }
}
// swiftlint:enable cyclomatic_complexity
