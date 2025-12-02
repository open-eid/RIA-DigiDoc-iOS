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

struct AdvancedSettingsManualCardContent: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    // MARK: Text field parameters
    var textFieldTitle: String
    @Binding var textFieldText: String

    // MARK: Certificate info parameters
    var certificateInfoHeader: String
    var showCertificateInfo: Bool
    var certificateIssuedTo: String
    var certificateValidTo: String

    // MARK: Button row parameters
    var onShowCertificatePressed: () -> Void
    var onAddCertificatePressed: () -> Void

    var body: some View {
        VStack(
            spacing: Dimensions.Padding.LPadding,
            content: {
                FloatingLabelTextField(
                    title: textFieldTitle,
                    text: $textFieldText,
                )
                AdvancedSettingsCertificateSection(
                    certificateInfoHeader: certificateInfoHeader,
                    showCertificateInfo: showCertificateInfo,
                    certificateIssuedTo: certificateIssuedTo,
                    certificateValidTo: certificateValidTo,
                    onShowCertificatePressed: onShowCertificatePressed,
                    onAddCertificatePressed: onAddCertificatePressed)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    AdvancedSettingsManualCardContent(
        textFieldTitle: "Text field title",
        textFieldText: .constant("Text field content"),
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
