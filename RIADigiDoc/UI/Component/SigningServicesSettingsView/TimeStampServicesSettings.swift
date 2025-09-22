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
                    manualCardContent
                }
            )
        }

        Spacer()
    }

    @ViewBuilder
    private var manualCardContent: some View {
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings tsa url title"),
            text: $manualAccess,
        )
        VStack(
            alignment: .leading,
            content: {
                Text(languageSettings.localized("Main settings timestamp cert title"))
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                Text(languageSettings.localized("Main settings timestamp cert not added"))
                    .font(typography.bodyMedium)
                    .foregroundStyle(theme.onSurfaceVariant)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        Button(
            action: {},
            label: {
                Text(languageSettings.localized("Main settings timestamp cert add certificate button"))
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, Dimensions.Padding.MSPadding)
            }
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Preview

#Preview {
    TimeStampServicesSettings()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
