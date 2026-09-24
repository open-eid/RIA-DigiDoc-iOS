// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct DiagnosticsHeaderButtons: View {
    @Environment(LanguageSettings.self) private var languageSettings

    let onCheckUpdateClick: () -> Void
    let onSaveDiagnosticsClick: () -> Void

    var body: some View {
        VStack(spacing: Dimensions.Padding.XSPadding) {
            PrimaryOutlinedButton(
                text: languageSettings.localized(
                    "Main diagnostics configuration check for update button"),
                assetImageName: nil,
                action: onCheckUpdateClick,
                focusedField: nil,
                currentFocus: .constant(nil)
            )
            PrimaryOutlinedButton(
                text: languageSettings.localized(
                    "Main diagnostics configuration save diagnostics button"),
                assetImageName: "ic_m3_download_48pt_wght400",
                action: onSaveDiagnosticsClick,
                focusedField: nil,
                currentFocus: .constant(nil)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsHeaderButtons(
        onCheckUpdateClick: {},
        onSaveDiagnosticsClick: {},
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
