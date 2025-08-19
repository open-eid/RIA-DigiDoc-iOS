import SwiftUI
import FactoryKit

struct OneTimeLogGenerationToggleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var enableOneTimeLogGeneration: Bool

    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        HStack {
            Text(languageSettings.localized("Main diagnostics logging switch"))
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
            Spacer()
            Toggle(
                isOn: $enableOneTimeLogGeneration,
                label: {}
            )
            .toggleStyle(SwitchToggleStyle(tint: theme.outline))
            .labelsHidden()
        }
        .padding(.vertical, Dimensions.Padding.SPadding)
    }
}

// MARK: - Preview
#Preview {
    OneTimeLogGenerationToggleSection(enableOneTimeLogGeneration: .constant(false))
        .environmentObject(Container.shared.languageSettings())
}
