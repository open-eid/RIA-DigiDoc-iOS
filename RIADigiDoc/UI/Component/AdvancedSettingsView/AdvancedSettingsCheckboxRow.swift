import SwiftUI
import FactoryKit

struct AdvancedSettingsCheckboxRow: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var label: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(
            action: {
                self.isChecked.toggle()
            },
            label: {
                HStack {
                    Text(label)
                        .font(typography.bodyLarge)
                        .foregroundStyle(theme.onSurface)
                    Spacer()
                    CheckBox(
                        isChecked: $isChecked,
                        baseAccessibilityLabel: label.lowercased()
                    )
                }
                .contentShape(Rectangle())
                .padding(.vertical, Dimensions.Padding.SPadding)
            }
        )
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsCheckboxRow(
        label: "Row title",
        isChecked: .constant(true)
    )
    .environmentObject(Container.shared.themeSettings())
    .environmentObject(Container.shared.languageSettings())

    AdvancedSettingsCheckboxRow(
        label: "Row title",
        isChecked: .constant(false)
    )
    .environmentObject(Container.shared.themeSettings())
    .environmentObject(Container.shared.languageSettings())

}
