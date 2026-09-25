// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct RadioButtonRow<T: Equatable>: View {
    @AppTheme private var theme
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTypography private var typography

    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    let accessibilityLabel: String
    let accessibilityInputLabel: String?

    private var accessibilityInputLabels: [String] {
        if let accessibilityInputLabel {
            return [accessibilityInputLabel, accessibilityLabel]
        }
        return [accessibilityLabel]
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Dimensions.Padding.SPadding) {
                Text(verbatim: title)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                RadioButton(
                    isChecked: isSelected,
                )
            }
            .padding(.vertical, Dimensions.Padding.SPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityInputLabels(accessibilityInputLabels)
    }
}
