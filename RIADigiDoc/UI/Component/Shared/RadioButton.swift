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

struct RadioButton: View {
    @AppTheme private var theme

    var isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? "largecircle.fill.circle" : "circle")
            .resizable()
            .foregroundStyle(isChecked ? theme.primary : theme.onSurfaceVariant)
            .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
            .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    RadioButton(
        isChecked: true,
    )
    .environment(Container.shared.themeSettings())

    RadioButton(
        isChecked: false,
    )
    .environment(Container.shared.themeSettings())
}
