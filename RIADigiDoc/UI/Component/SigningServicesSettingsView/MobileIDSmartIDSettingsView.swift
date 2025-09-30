import CommonsLib
import SwiftUI
import FactoryKit

struct MobileIDSmartIDSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: MobileIDSmartIDSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.mobileIDSmartIDSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings relying party title")
        ) {
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default access title"),
                isSelected: viewModel.selectedOption == .defaultSetting,
                onSelect: {
                    viewModel.selectedOption = .defaultSetting
                }
            )
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default manual access title"),
                isSelected: viewModel.selectedOption == .manualSetting,
                onSelect: {
                    viewModel.selectedOption = .manualSetting
                },
                content: {
                    FloatingLabelTextField(
                        title: languageSettings.localized("Main settings relying party title"),
                        text: $viewModel.relyingPartyUUID,
                        isSecure: true,
                    )
                }
            )
            Spacer()
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MobileIDSmartIDSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
