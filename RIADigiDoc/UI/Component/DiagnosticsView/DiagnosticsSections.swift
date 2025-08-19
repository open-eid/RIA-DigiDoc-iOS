import FactoryKit
import SwiftUI

struct DiagnosticsSections: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @EnvironmentObject private var viewModel: DiagnosticsViewModel

    var body: some View {
        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics application version title"),
            content: viewModel.versionSectionContent
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics operating system title"),
            content: viewModel.osSectionContent,
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics libraries title"),
            content: viewModel.libdigidocVersion
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics urls title"),
            contentLines: viewModel.urlSectionContent,
            showDivider: false,
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics cdoc2 title"),
            contentLines: viewModel.cdoc2SectionContent,
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics tsl cache title"),
            contentLines: viewModel.tslSectionContent,
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics central configuration title"),
            contentLines: viewModel.centralConfigurationSectionContent
        )
        .task {
            viewModel.fetchContent(languageSettings: languageSettings)
        }
    }

}

// MARK: - Preview
#Preview {
    DiagnosticsSections()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
