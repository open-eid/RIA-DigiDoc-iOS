import SwiftUI
import FactoryKit

struct TimeStampServicesSettings: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var selectedOption: ServicesSettingsOption = .defaultSetting

    @State private var manualAccess: String = "https://eid-dd.ria.ee/ts"

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings tsa url title")
        ) {
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default access title"),
                isSelected: selectedOption == .defaultSetting,
                onSelect: {
                    selectedOption = .defaultSetting
                }
            )
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default manual access title"),
                isSelected: selectedOption == .manualSetting,
                onSelect: {
                    selectedOption = .manualSetting
                },
                content: {
                    AdvancedSettingsManualCardContent(
                        textFieldTitle: languageSettings.localized("Main settings tsa url title"),
                        textFieldText: $manualAccess,
                        certificateInfoHeader: languageSettings.localized("Main settings timestamp cert title"),
                        showCertificateInfo: true,
                        certificateIssuedTo: "",
                        certificateValidTo: "",
                        onShowCertificatePressed: {},
                        onAddCertificatePressed: {}
                    )
                }
            )
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    TimeStampServicesSettings()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
