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
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
