// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct ContainerNotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    private let isSettingsMenuBottomSheetVisible = false
    let notifications: [ContainerNotificationType]

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Container notifications"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()

                        ForEach(notifications.indices, id: \.self) { index in
                            HStack(alignment: .center) {
                                Image("ic_m3_notifications_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .padding(Dimensions.Padding.XSPadding)
                                    .accessibilityHidden(true)

                                let notificationMessage = message(for: notifications[index])
                                Text(verbatim: notificationMessage)
                                    .font(typography.bodyMedium)
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .accessibilityLabel(
                                        Text(
                                            verbatim: "\(languageSettings.localized("Container notification")) " +
                                            "\(index + 1). \(notificationMessage)"
                                        )
                                    )
                            }
                            .padding(.horizontal, Dimensions.Padding.XXSPadding)

                            Divider()
                        }
                    }
                    .padding(.vertical, Dimensions.Padding.SPadding)
                }
            }
        )
    }

    private func message(for notification: ContainerNotificationType) -> String {
        switch notification {
        case .xadesFile:
            return languageSettings.localized("Xades message")
        case .cadesFile:
            return languageSettings.localized("Cades message")
        case .unknownSignatures(let count):
            return languageSettings.localized("Unknown signature", [count])
        case .invalidSignatures(let count):
            return languageSettings.localized("Invalid signature", [count])
        case .emptyFile:
            return languageSettings.localized("Empty file in container")
        case .unsupportedContainer:
            return languageSettings.localized("Unsupported container")
        }
    }
}

#Preview {
    ContainerNotificationsView(
        notifications: [
            .emptyFile,
            .unknownSignatures(count: 1)
        ]
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
