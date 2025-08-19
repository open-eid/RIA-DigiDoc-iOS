import FactoryKit
import SwiftUI

struct DiagnosticsHeaderButtons: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    let onCheckUpdateClick: () -> Void
    let onSaveDiagnosticsClick: () -> Void

    var body: some View {
        VStack(spacing: Dimensions.Padding.XSPadding) {
            PrimaryOutlinedButton(
                text: languageSettings.localized(
                    "Main diagnostics configuration check for update button"),
                assetImageName: nil,
                action: onCheckUpdateClick,
            )
            PrimaryOutlinedButton(
                text: languageSettings.localized(
                    "Main diagnostics configuration save diagnostics button"),
                assetImageName: "ic_m3_download_48pt_wght400",
                action: onSaveDiagnosticsClick,
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
    .environmentObject(
        Container.shared.languageSettings()
    )
}
