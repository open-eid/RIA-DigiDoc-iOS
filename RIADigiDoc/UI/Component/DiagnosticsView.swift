import SwiftUI
import FactoryKit

struct DiagnosticsView: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Environment(\.dismiss) private var dismiss

    @State private var enableOneTimeLogGeneration = false // TODO: implement one time log generation logic

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main diagnostics title"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.XXSPadding,
                        content: {
                            DiagnosticsHeaderButtons()

                            OneTimeLogGenerationToggleSection(enableOneTimeLogGeneration: $enableOneTimeLogGeneration)

                            DiagnosticsSections()
                        }
                    )
                    .padding(Dimensions.Padding.SPadding)
                }
            }
        ).background(theme.surface)
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
