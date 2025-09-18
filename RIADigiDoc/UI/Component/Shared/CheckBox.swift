import SwiftUI
import FactoryKit

struct CheckBox: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Binding var isChecked: Bool
    let baseAccessibilityLabel: String

    func getAccessibilityLabelWithState(_ baseAccessibilityLabel: String) -> String {
        let checked = isChecked
        ? languageSettings.localized("Checkbox checked")
        : languageSettings.localized("Checkbox unchecked")

        return "\(baseAccessibilityLabel) \(checked)"
    }

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .resizable()
            .foregroundStyle(isChecked ? theme.primary : theme.onSurfaceVariant)
            .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
            .accessibilityLabel(getAccessibilityLabelWithState(baseAccessibilityLabel))
    }
}

// MARK: - Preview
#Preview {
    CheckBox(
        isChecked: .constant(true),
        baseAccessibilityLabel: "button title"
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())

    CheckBox(
        isChecked: .constant(false),
        baseAccessibilityLabel: "button title"
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
