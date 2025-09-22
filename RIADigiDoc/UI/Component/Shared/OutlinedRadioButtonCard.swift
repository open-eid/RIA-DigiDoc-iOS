import SwiftUI
import FactoryKit

struct OutlinedRadioButtonCard<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    let title: String
    let isSelected: Bool
    let onSelect: () -> Void
    @ViewBuilder var content: () -> Content

    init(
        title: String,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.content = content
    }

    func getAccessibilityLabelWithState(_ baseAccessibilityLabel: String) -> String {
        let checked = isSelected
        ? languageSettings.localized("Radiobutton checked")
        : languageSettings.localized("Radiobutton unchecked")

        return "\(baseAccessibilityLabel) \(checked)"
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(
                spacing: Dimensions.Padding.LPadding,
                content: {
                    HStack {
                        Text(title)
                            .font(typography.bodyLarge)
                            .foregroundStyle(theme.onSurface)
                            .padding(.trailing, Dimensions.Padding.XXSPadding)
                        Spacer()
                        RadioButton(
                            isChecked: isSelected,
                            accessibilityLabel:
                                getAccessibilityLabelWithState(title.lowercased())
                        )
                        .padding(.trailing, Dimensions.Padding.SPadding)
                    }

                    if isSelected {
                        content()
                    }
                }
            )
            .padding(.vertical, Dimensions.Padding.LPadding)
            .padding(.horizontal, Dimensions.Padding.SPadding)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius)
                    .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
            )
        }
        .buttonStyle(.plain)
        .cornerRadius(Dimensions.Corner.XSCornerRadius)
        .padding(.vertical, Dimensions.Padding.XSPadding)
    }
}

// MARK: - Preview

#Preview {
    OutlinedRadioButtonCard(
        title: "button title",
        isSelected: true,
        onSelect: {},
        content: {
            Text("content text")
        }
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
