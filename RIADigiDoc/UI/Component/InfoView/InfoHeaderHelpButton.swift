// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct InfoHeaderHelpButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.openURL) var openURL
    @Environment(LanguageSettings.self) private var languageSettings

    private var helpLabel: String {
        languageSettings.localized("Main about help center")
    }

    private var urlString: String {
        languageSettings.localized("Main home menu help url")
    }

    private var accessibilityLabel: String {
        "\(languageSettings.localized("Open Button")) \(urlString)"
    }

    var body: some View {
        Button(
            action: {
                if let url = URL(string: urlString) {
                    openURL(url)
                }
            },
            label: {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image("ic_m3_open_in_new_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onPrimary)
                        .accessibilityHidden(true)
                    Text(verbatim: helpLabel)
                        .font(typography.labelMedium)
                        .foregroundStyle(theme.onPrimary)

                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.XSPadding)
                .background(theme.primary)
                .cornerRadius(Dimensions.Corner.MCornerRadius)
            }
        )
        .buttonStyle(.plain)
        .accessibilityInputLabels(["Helpdesk", helpLabel])
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview
#Preview {
    InfoHeaderHelpButton()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
