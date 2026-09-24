// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct CheckBox: View {
    @AppTheme private var theme

    @Binding var isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .resizable()
            .foregroundStyle(isChecked ? theme.primary : theme.onSurfaceVariant)
            .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
            .accessibilityHidden(true)
    }
}

// MARK: - Preview
#Preview {
    CheckBox(
        isChecked: .constant(true),
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())

    CheckBox(
        isChecked: .constant(false),
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
