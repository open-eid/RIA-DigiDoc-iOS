// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct ToggleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var isOn: Bool
    let label: String
    let verticalPadding: CGFloat

    init(
        isOn: Binding<Bool>,
        label: String,
        verticalPadding: CGFloat = Dimensions.Padding.SPadding
    ) {
        self._isOn = isOn
        self.label = label
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        HStack {
            Text(verbatim: label)
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
                .accessibilityHidden(true)
            Spacer()
            Toggle(
                isOn: $isOn,
                label: {}
            )
            .toggleStyle(SwitchToggleStyle(tint: theme.primary))
            .labelsHidden()
            .accessibilityLabel(label)
            .accessibilityInputLabels(["Toggle", label])
        }
        .padding(.vertical, verticalPadding)
    }
}

// MARK: - Preview
#Preview {
    ToggleSection(
        isOn: .constant(false),
        label: "section label"
    )
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
