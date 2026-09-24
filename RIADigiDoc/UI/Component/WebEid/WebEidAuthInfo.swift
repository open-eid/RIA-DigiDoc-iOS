// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct WebEidAuthInfo: View {

    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let origin: String

    private var titleText: String {
        "authRequestFrom"
    }

    private var detailsTitleText: String {
        "detailsForwarded"
    }

    private var personLine: String {
        return "namePersonalIdentificationCode"
    }

    private var consentText: String {
        "authConsentText"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
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

            VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                Text(languageSettings.localized(detailsTitleText))
                    .font(typography.labelSmall)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: Dimensions.Padding.XXXSPadding)

                Text(languageSettings.localized(personLine))
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
