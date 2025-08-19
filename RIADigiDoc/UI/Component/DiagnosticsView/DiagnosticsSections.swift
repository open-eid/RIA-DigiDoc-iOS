import SwiftUI
import CommonsLib
import FactoryKit

struct DiagnosticsSections: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics application version title"),
            contentText: BundleUtil.getBundleShortVersionString() + "." + BundleUtil.getBundleVersion()
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics operating system title"),
            contentText: "", // TODO: implement diagnostics section
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics libraries title"),
            contentText: "", // TODO: implement diagnostics section
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics urls title"),
            contentText: "", // TODO: implement diagnostics section
            showDivider: false,
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics cdoc2 title"),
            contentText: "", // TODO: implement diagnostics section
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics tsl cache title"),
            contentText: "", // TODO: implement diagnostics section
        )

        DiagnosticsSingleSection(
            title: languageSettings.localized("Main diagnostics central configuration title"),
            contentText: "", // TODO: implement diagnostics section
        )
    }
}

// MARK: - Single section
private struct DiagnosticsSingleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let contentText: String
    var showDivider: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            Text(verbatim: title)
                .foregroundStyle(theme.onSurface)
                .font(typography.titleMedium)
            Text(verbatim: contentText)
                .foregroundStyle(theme.onSurfaceVariant)
                .font(typography.bodyMedium)
            if showDivider {
                Divider()
                    .padding(.top, Dimensions.Padding.XSPadding)
            }
        }
        .padding(.top, Dimensions.Padding.XSPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsSections()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
