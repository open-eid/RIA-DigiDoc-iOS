// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
