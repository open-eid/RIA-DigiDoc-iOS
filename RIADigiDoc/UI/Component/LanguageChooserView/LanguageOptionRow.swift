import FactoryKit
import SwiftUI

struct LanguageOptionRow: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTypography private var typography

    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    private var accessibilityLabel: String {
        if isSelected {
            return "\(title) \(languageSettings.localized("Menu language selected"))"
        } else {
            return "\(languageSettings.localized("Menu language")) \(title)"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .resizable()
                    .foregroundStyle(isSelected ? theme.primary : theme.onSurfaceVariant)
                    .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
                    .accessibilityLabel(accessibilityLabel)
            }
            .padding(.horizontal, Dimensions.Padding.SPadding)
            .padding(.vertical, Dimensions.Padding.SPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        LanguageOptionRow(
            title: "Eesti keel", isSelected: true, onTap: {}
        )
        Divider()
        LanguageOptionRow(
            title: "In English", isSelected: false, onTap: {}
        )
    }
    .environmentObject(Container.shared.languageSettings())
}
