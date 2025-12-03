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
