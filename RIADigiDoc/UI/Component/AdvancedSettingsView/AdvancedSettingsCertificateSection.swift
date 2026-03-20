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

struct AdvancedSettingsCertificateSection: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    // MARK: Certificate info parameters
    var certificateInfoHeader: String
    var showCertificateInfo: Bool
    var certificateIssuedTo: String
    var certificateValidTo: String

    // MARK: Button row parameters
    var onShowCertificatePressed: () -> Void
    var onAddCertificatePressed: () -> Void

    var body: some View {
        certificateInfo
        buttonRow
    }

    @ViewBuilder
    private var certificateInfo: some View {
        VStack(
            alignment: .leading,
            content: {
                Text(certificateInfoHeader)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .padding(.bottom, Dimensions.Padding.XXSPadding)
                if showCertificateInfo {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        let issuedTitle = languageSettings.localized("Main settings cert issued to title")
                        let validToTitle = languageSettings.localized("Main settings cert valid to title")
                        Text(verbatim: "\(issuedTitle) \(certificateIssuedTo)")
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurfaceVariant)
                        Text(verbatim: "\(validToTitle) \(certificateValidTo)")
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurfaceVariant)
                    }
                } else {
                    Text(languageSettings.localized("Main settings timestamp cert not added"))
                        .font(typography.bodyMedium)
                        .foregroundStyle(theme.onSurfaceVariant)
                }
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var buttonRow: some View {
        HStack(
            content: {
                Spacer()

                if showCertificateInfo {
                    Button(
                        action: onShowCertificatePressed,
                        label: {
                            Text(languageSettings.localized("Main settings timestamp cert show certificate button"))
                                .font(typography.labelLarge)
                                .foregroundStyle(theme.primary)
                                .padding(.horizontal, Dimensions.Padding.MSPadding)
                        }
                    )
                    .buttonStyle(.plain)
                }

                Button(
                    action: onAddCertificatePressed,
                    label: {
                        Text(languageSettings.localized("Main settings timestamp cert add certificate button"))
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .padding(.horizontal, Dimensions.Padding.MSPadding)
                    }
                )
                .buttonStyle(.plain)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    AdvancedSettingsCertificateSection(
        certificateInfoHeader: "Certificate header",
        showCertificateInfo: true,
        certificateIssuedTo: "",
        certificateValidTo: "",
        onShowCertificatePressed: {},
        onAddCertificatePressed: {}
    )
    .padding()
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
