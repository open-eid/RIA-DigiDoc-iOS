// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AdvancedSettingsCheckboxRow: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings

    var label: String
    @Binding var isChecked: Bool

    func getAccessibilityLabelWithState(_ baseAccessibilityLabel: String) -> String {
        let checked = isChecked
        ? languageSettings.localized("Checkbox checked")
        : languageSettings.localized("Checkbox unchecked")

        return "\(baseAccessibilityLabel) \(checked)"
    }

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
                    )
                }
                .contentShape(Rectangle())
                .padding(.vertical, Dimensions.Padding.SPadding)
                .accessibilityLabel(getAccessibilityLabelWithState(label.lowercased()))
                .accessibilityInputLabels(["Toggle", label])
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
    .environment(Container.shared.themeSettings())
    .environment(Container.shared.languageSettings())

    AdvancedSettingsCheckboxRow(
        label: "Row title",
        isChecked: .constant(false)
    )
    .environment(Container.shared.themeSettings())
    .environment(Container.shared.languageSettings())
}
