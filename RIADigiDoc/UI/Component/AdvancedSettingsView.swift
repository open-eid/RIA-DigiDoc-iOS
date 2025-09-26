import SwiftUI
import FactoryKit

struct AdvancedSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Environment(\.dismiss) private var dismiss

    @State private var checkedAskRoleAndAddress: Bool = false

    @State private var navigateToSigningServicesSettings = false
    @State private var navigateToValidationSettings = false

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
            title: languageSettings.localized("Main settings menu advanced"),
            onLeftClick: {
                dismiss()
            },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            },
            content: {
                ScrollView {
                    VStack(spacing: Dimensions.Padding.ZeroPadding) {

                        AdvancedSettingsSectionColumn(
                            title: languageSettings.localized("Main settings general title"),
                            isScrollable: false
                        ) {
                            AdvancedSettingsCheckboxRow(
                                label: languageSettings.localized("Main settings ask role and address title"),
                                isChecked: $checkedAskRoleAndAddress
                            )
                        }

                        Divider().padding(.vertical, Dimensions.Padding.SPadding)

                        AdvancedSettingsSectionColumn(
                            title: languageSettings.localized("Main settings system settings title"),
                            isScrollable: false
                        ) {
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings signing services title"),
                                onClick: {
                                    navigateToSigningServicesSettings = true
                                }
                            )
                            NavigationLink(
                                destination: SigningServicesSettingsView(),
                                isActive: $navigateToSigningServicesSettings
                            ) { }
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings validation services title"),
                                onClick: {
                                    navigateToValidationSettings = true
                                }
                            )
                            NavigationLink(
                                destination: ValidationSettingsView(),
                                isActive: $navigateToValidationSettings
                            ) { }
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings crypto services title"),
                                onClick: {}
                            )
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings proxy title"),
                                onClick: {}
                            )
                        }

                        Button(
                            action: {},
                            label: {
                                Text(languageSettings.localized("Main settings use default settings button title"))
                                    .font(typography.labelLarge)
                                    .foregroundStyle(theme.primary)
                            }
                        )
                        .padding(.vertical, Dimensions.Padding.LPadding)

                        Spacer()
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                }
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
    AdvancedSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
