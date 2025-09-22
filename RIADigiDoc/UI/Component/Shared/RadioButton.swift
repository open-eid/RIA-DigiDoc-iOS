import SwiftUI
import FactoryKit

struct RadioButton: View {
    @AppTheme private var theme

    var isChecked: Bool
    let accessibilityLabel: String

    var body: some View {
        Image(systemName: isChecked ? "largecircle.fill.circle" : "circle")
            .resizable()
            .foregroundStyle(isChecked ? theme.primary : theme.onSurfaceVariant)
            .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
            .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview

#Preview {
    RadioButton(
        isChecked: true,
        accessibilityLabel: "button title"
    )
    .environmentObject(Container.shared.themeSettings())

    RadioButton(
        isChecked: false,
        accessibilityLabel: "button title"
    )
    .environmentObject(Container.shared.themeSettings())
}
