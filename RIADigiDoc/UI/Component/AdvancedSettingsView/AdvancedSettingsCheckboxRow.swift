/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
