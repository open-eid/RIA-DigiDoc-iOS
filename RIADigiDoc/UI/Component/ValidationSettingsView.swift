import SwiftUI
import FactoryKit

struct ValidationSettings: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    // MARK: - Navigation
    @State private var navigateToCertificateView = false

    // MARK: - Bottom sheet navigation
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

    @StateObject private var viewModel: ValidationSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.validationSettingsViewModel())
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
                                if !viewModel.isLoading {
                                    AdvancedSettingsManualCardContent(
                                        textFieldTitle: languageSettings.localized("Main settings siva service url"),
                                        textFieldText: $viewModel.validationServiceURL,
                                        certificateInfoHeader:
                                            languageSettings.localized("Main settings siva certificate title"),
                                        showCertificateInfo: viewModel.sivaCertData != nil,
                                        certificateIssuedTo: viewModel.getSiVaCertIssuer(),
                                        certificateValidTo: viewModel.getSiVaCertNotValidAfter(
                                            expiredLabel: languageSettings.localized("Main settings cert expired")
                                        ),
                                        onShowCertificatePressed: {
                                            navigateToCertificateView = true
                                        },
                                        onAddCertificatePressed: {
                                            viewModel.isImportingCert = true
                                        }
                                    )
                                }

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
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImportingCert,
            allowedContentTypes: [.x509Certificate],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    await viewModel.importSiVaCert(from: url)
                }
                viewModel.isImportingCert = false
            case .failure:
                viewModel.isImportingCert = false
            }
        }

        // MARK: - Navigation links
        if let sivaCertData = viewModel.sivaCertData {
            NavigationLink(
                destination: CertificateDetailView(
                    certificate: sivaCertData
                ),
                isActive: $navigateToCertificateView,
            ) { }
        }

        // MARK: - Bottom sheet navigation links
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
    ValidationSettings()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
