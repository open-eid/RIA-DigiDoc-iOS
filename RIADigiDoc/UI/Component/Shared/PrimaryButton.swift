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

struct PrimaryButton: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let isButtonEnabled: Bool
    let action: () -> Void

    init(
        text: String,
        isButtonEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isButtonEnabled = isButtonEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(verbatim: text)
                .font(typography.labelLarge)
                .foregroundStyle(isButtonEnabled ? theme.onPrimary : theme.surfaceContainerHighest)
                .padding(Dimensions.Padding.MSPadding)
                .frame(maxWidth: .infinity)
                .background(isButtonEnabled ? theme.primary : Color.gray)
                .cornerRadius(Dimensions.Corner.MCornerRadius)
        }
        .disabled(!isButtonEnabled)
    }
}

// MARK: - Preview
#Preview {
    Group {
        PrimaryButton(
            text: "Button",
            isButtonEnabled: true,
            action: {}
        )

        PrimaryButton(
            text: "Button",
            isButtonEnabled: false,
            action: {}
        )
    }
    .padding(Dimensions.Padding.SPadding)
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
