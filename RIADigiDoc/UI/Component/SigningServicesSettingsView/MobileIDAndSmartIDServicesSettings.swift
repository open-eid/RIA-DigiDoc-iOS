import SwiftUI
import FactoryKit

struct MobileIDAndSmartIDServicesSettings: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var selectedOption: ServicesSettingsOption = .defaultSetting

    @State private var manualAccess: String = "00000000-0000-0000-0000-000000000000"

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings relying party title")
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
                    FloatingLabelTextField(
                        title: languageSettings.localized("Main settings relying party title"),
                        text: $manualAccess,
                        isSecure: true,
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
