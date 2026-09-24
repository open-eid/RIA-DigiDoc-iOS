// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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

    var identifier: String

    var body: some View {
        VStack(
            spacing: Dimensions.Padding.LPadding,
            content: {
                FloatingLabelTextField(
                    title: textFieldTitle,
                    placeholder: textFieldTitle,
                    text: $textFieldText,
                    identifier: identifier
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
        onAddCertificatePressed: {},
        identifier: "certificateHeader"
    )
    .padding()
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
