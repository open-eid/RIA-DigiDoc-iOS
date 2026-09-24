// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct SingleLicenseButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.openURL) private var openURL

    let package: DependencyLicense

    var body: some View {
        Button(
            action: {
                if let url = package.url {
                    openURL(url)
                }

            },
            label: {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        Text(package.name)
                            .font(typography.titleMedium)
                            .foregroundStyle(theme.onSurface)
                        Text(package.license)
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurfaceVariant)
                    }
                    Spacer()
                    Image("ic_m3_open_in_new_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onSurfaceVariant)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityLabel(
                            languageSettings.localized("Open Button") +
                            " \(package.url?.absoluteString ?? "")"
                        )
                }
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .background(theme.surface)
            }
        )
        .buttonStyle(.plain)
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - Preview
#Preview {
    SingleLicenseButton(
        package: DependencyLicense(
            name: "Alamofire",
            license: "MIT licence",
            url: URL(string: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE")
        ),
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
