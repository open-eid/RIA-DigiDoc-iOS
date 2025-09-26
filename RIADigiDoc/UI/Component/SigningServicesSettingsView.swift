import SwiftUI
import FactoryKit

struct SigningServicesSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: Int = 0

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
            title: languageSettings.localized("Main settings signing services title"),
            onLeftClick: { dismiss() },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            },
            content: {
                VStack(spacing: Dimensions.Padding.ZeroPadding) {
                    TabView(
                        selectedTab: $selectedTab,
                        titles: [
                            languageSettings.localized("Main settings timestamp services title"),
                            languageSettings.localized("Main settings mobile id and smart id title")
                        ],
                        content: {
                            if selectedTab == 0 {
                                TimeStampSettings()
                                    .padding(.horizontal, Dimensions.Padding.SPadding)
                            } else {
                                MobileIDSmartIDSettings()
                                    .padding(.horizontal, Dimensions.Padding.SPadding)
                            }
                        }
                    )
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
    SigningServicesSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
