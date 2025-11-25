/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import SwiftUI
import FactoryKit

struct OutlinedRadioButtonCard<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

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
        .accessibilityElement(children: .contain)
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
