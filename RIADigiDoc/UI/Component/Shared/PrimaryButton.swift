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

struct PrimaryButton: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @AppTheme private var theme
    @AppTypography private var typography

    private let text: String
    private let isButtonEnabled: Bool
    private let action: () -> Void
    private let backgroundColor: Color?
    private let foregroundColor: Color?

    @Binding private var currentFocus: AccessibilityField?
    @State private var focusedField: AccessibilityField?
    @AccessibilityFocusState private var isFocused: Bool
    @AccessibilityFocusState private var accessibilityField: AccessibilityField?

    init(
        text: String,
        isButtonEnabled: Bool,
        action: @escaping () -> Void,
        focusedField: AccessibilityField?,
        currentFocus: Binding<AccessibilityField?>,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
    ) {
        self.text = text
        self.isButtonEnabled = isButtonEnabled
        self.action = action
        self.focusedField = focusedField
        self._currentFocus = currentFocus
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        let button = Button(
            action: action,
            label: {
                Text(verbatim: text)
                    .foregroundStyle(isButtonEnabled
                                     ? (foregroundColor ?? theme.onPrimary)
                                     : theme.surfaceContainerHighest)
                    .font(typography.labelLarge)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Dimensions.Padding.XSPadding)
                    .padding(.vertical, Dimensions.Padding.MSPadding)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(isButtonEnabled ? (backgroundColor ?? theme.primary) : Color.gray)
                    )
            })
            .disabled(!isButtonEnabled)
            .accessibilityFocused($isFocused)
            .onAppear {
                Task {
                    await MainActor.run {
                        let shouldFocus = (focusedField != nil && currentFocus == focusedField)

                        isFocused = shouldFocus

                        if shouldFocus {
                            accessibilityField = focusedField
                        }
                    }
                }
            }

        if let field = self.accessibilityField {
            button.accessibilityFocusRestore(
                focusedField: $accessibilityField,
                field: field,
                when: true
            )
        } else {
            button
        }
    }
}

// MARK: - Preview
#Preview {
    Group {
        PrimaryButton(
            text: "Button",
            isButtonEnabled: true,
            action: {},
            focusedField: nil,
            currentFocus: .constant(nil)
        )

        PrimaryButton(
            text: "Button",
            isButtonEnabled: false,
            action: {},
            focusedField: nil,
            currentFocus: .constant(nil)
        )
    }
    .padding(Dimensions.Padding.SPadding)
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
