import SwiftUI
import FactoryKit

struct TimeStampSettings: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    // MARK: - Navigation
    @State private var navigateToCertificateView = false

    @StateObject private var viewModel: TimeStampSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.timeStampSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings tsa url title")
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
                            textFieldTitle: languageSettings.localized("Main settings tsa url title"),
                            textFieldText: $viewModel.tsaUrl,
                            certificateInfoHeader:
                                languageSettings.localized("Main settings timestamp cert title"),
                            showCertificateInfo: viewModel.tsaCertData != nil,
                            certificateIssuedTo: viewModel.getTSACertIssuer(),
                            certificateValidTo: viewModel.getTSACertNotValidAfter(
                                expiredLabel: languageSettings.localized("Main settings cert expired")
                            ),
                            onShowCertificatePressed: {
                                navigateToCertificateView = true
                            },
                            onAddCertificatePressed: {
                                viewModel.isImportingTSACert = true
                            }
                        )
                    }
                }
            )

            Spacer()
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImportingTSACert,
            allowedContentTypes: [.x509Certificate],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    await viewModel.importTSACert(from: url)
                }
                viewModel.isImportingTSACert = false
            case .failure:
                viewModel.isImportingTSACert = false
            }
        }

        // MARK: - Navigation links
        if let tsaCertData = viewModel.tsaCertData {
            NavigationLink(
                destination: CertificateDetailView(
                    certificate: tsaCertData
                ),
                isActive: $navigateToCertificateView,
            ) { }
        }
    }
}

// MARK: - Preview

#Preview {
    TimeStampSettings()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
