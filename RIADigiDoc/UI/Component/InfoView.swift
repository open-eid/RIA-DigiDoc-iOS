import SwiftUI
import FactoryKit

struct InfoView: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main home menu about"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.XXSPadding,
                        content: {
                            InfoHeader()
                            LicensesComponent()
                        }
                    )
                }
            }
        ).background(theme.surface)
    }
}

// MARK: - Preview
#Preview {
    InfoView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
