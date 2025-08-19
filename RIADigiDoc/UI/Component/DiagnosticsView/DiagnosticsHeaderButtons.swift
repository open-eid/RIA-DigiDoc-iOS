import SwiftUI
import FactoryKit

struct DiagnosticsHeaderButtons: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        VStack(spacing: Dimensions.Padding.XSPadding) {
            PrimaryOutlinedButton(
                text: languageSettings.localized("Main diagnostics configuration check for update button"),
                assetImageName: nil,
                action: {} // TODO: implement update button action
            )
            PrimaryOutlinedButton(
                text: languageSettings.localized("Main diagnostics configuration save diagnostics button"),
                assetImageName: "ic_m3_download_48pt_wght400",
                action: {} // TODO: implement save button action
            )
        }
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsHeaderButtons()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
