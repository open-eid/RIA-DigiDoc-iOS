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

struct WebEidSignOrCertificateInfo: View {

    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let origin: String
    let isCertificateFlow: Bool
    let signingPersonInfo: String?

    private var titleText: String {
        isCertificateFlow
        ? "certRequestFrom"
        : "signRequestFrom"
    }

    private var detailsTitleText: String {
        isCertificateFlow
        ? "detailsForwarded"
        : "details"
    }

    private var signingPerson: String? {
        guard !isCertificateFlow,
              let info = signingPersonInfo?.trimmingCharacters(in: .whitespacesAndNewlines),
              !info.isEmpty else {
            return nil
        }
        return info
    }

    private var consentText: String {
        isCertificateFlow
        ? "certificateConsentText"
        : "signatureConsentText"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            VStack(alignment: .leading, spacing: 0) {
                Text(languageSettings.localized(titleText))
                    .font(typography.labelSmall)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: Dimensions.Padding.XXXSPadding)

                Text(verbatim: WebEidUriUtil.displayOrigin(origin))
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)

            Spacer().frame(height: Dimensions.Padding.SPadding)

            VStack(alignment: .leading, spacing: 0) {
                Text(languageSettings.localized(detailsTitleText))
                    .font(typography.labelSmall)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: Dimensions.Padding.XXXSPadding)

                Group {
                    if let signingPerson {
                        Text(verbatim: signingPerson)
                    } else {
                        Text(languageSettings.localized("namePersonalIdentificationCode"))
                    }
                }
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)

            Spacer().frame(height: Dimensions.Padding.SPadding)

            Text(languageSettings.localized(consentText))
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
