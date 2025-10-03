import SwiftUI
import FactoryKit

struct ValidationServicesSettings: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedOption: ServicesSettingsOption = .defaultSetting
    // TODO: Remove in viewmodel task
    @State private var manualAccess: String = "https://siva.eesti.ee/V3/validate"
    @State private var certificateAdded: Bool = false

    @State private var showSettingsBottomSheetFromButton = false
    @State private var navigateToLanguageChooser = false
    @State private var navigateToThemeChooser = false

    private var settingsBottomSheetActions: [BottomSheetButton] {
        SettingsMenuBottomSheetActions.actions(
            currentPage: .advanced,
            onLanguageChooserClick: {
                navigateToLanguageChooser = true
            },
            onThemeChooserClick: {
                navigateToThemeChooser = true
            },
        )
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings validation services title"),
            onLeftClick: { dismiss() },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            },
            content: {
                VStack(spacing: Dimensions.Padding.ZeroPadding) {
                    AdvancedSettingsSectionColumn(
                        title: languageSettings.localized("Main settings siva service title")
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
                                    textFieldTitle: languageSettings.localized("Main settings siva service url"),
                                    textFieldText: $manualAccess,
                                    certificateInfoHeader: languageSettings.localized("Main settings siva certificate title"),
                                    showCertificateInfo: false,
                                    certificateIssuedTo: "",
                                    certificateValidTo: "",
                                    onShowCertificatePressed: {},
                                    onAddCertificatePressed: {}
                                )
                            }
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
            }
        )
        .background(theme.surface)
        .bottomSheet(isPresented: $showSettingsBottomSheetFromButton, actions: settingsBottomSheetActions)

        NavigationLink(
            destination: LanguageChooserView(),
            isActive: $navigateToLanguageChooser
        ) { }
        NavigationLink(
            destination: ThemeChooserView(),
            isActive: $navigateToThemeChooser
        ) { }
    }
}

// MARK: - Preview

#Preview {
    ValidationServicesSettings()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
