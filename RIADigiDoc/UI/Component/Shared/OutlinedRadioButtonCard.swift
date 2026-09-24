// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct OutlinedRadioButtonCard<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    let title: String
    let isSelected: Bool
    let onSelect: () -> Void
    let contentSpacing: CGFloat
    let accessibilityInputLabel: SettingsAccessibilityInputLabel?
    @ViewBuilder var content: () -> Content

    private var accessibilityInputLabels: [String] {
        if let accessibilityInputLabel {
            return [accessibilityInputLabel.rawValue, title]
        }
        return [title]
    }

    init(
        title: String,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        contentSpacing: CGFloat = Dimensions.Padding.LPadding,
        accessibilityInputLabel: SettingsAccessibilityInputLabel? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.contentSpacing = contentSpacing
        self.accessibilityInputLabel = accessibilityInputLabel
        self.content = content
    }

    func getAccessibilityLabelWithState(_ baseAccessibilityLabel: String) -> String {
        let checked = isSelected
        ? languageSettings.localized("Radiobutton checked")
        : languageSettings.localized("Radiobutton unchecked")

        return "\(baseAccessibilityLabel) \(checked)"
    }

    var body: some View {
        VStack(
            spacing: contentSpacing,
            content: {
                Button(action: onSelect) {
                    HStack {
                        Text(title)
                            .font(typography.bodyLarge)
                            .foregroundStyle(theme.onSurface)
                            .padding(.trailing, Dimensions.Padding.XXSPadding)
                        Spacer()
                        RadioButton(
                            isChecked: isSelected,
                        )
                        .padding(.trailing, Dimensions.Padding.SPadding)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(getAccessibilityLabelWithState(title.lowercased()))
                .accessibilityInputLabels(self.accessibilityInputLabels)

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
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
