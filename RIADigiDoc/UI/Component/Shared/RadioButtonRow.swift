import FactoryKit
import SwiftUI

struct RadioButtonRow<T: Equatable>: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTypography private var typography

    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    let accessibilityLabel: String

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .multilineTextAlignment(.leading)

                Spacer()
                RadioButton(
                    isChecked: isSelected,
                    accessibilityLabel: accessibilityLabel
                )
            }
            .padding(.horizontal, Dimensions.Padding.SPadding)
            .padding(.vertical, Dimensions.Padding.SPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
