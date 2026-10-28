// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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

    @FocusState private var isKeyboardFocused: Bool

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

    private var isFocusHighlighted: Bool {
        isKeyboardFocused && isButtonEnabled
    }

    private var accentColor: Color {
        backgroundColor ?? theme.primary
    }

    private var fillColor: Color {
        if isFocusHighlighted {
            return .clear
        }
        return isButtonEnabled ? (backgroundColor ?? theme.primary) : Color.gray
    }

    private var textColor: Color {
        if isFocusHighlighted {
            return accentColor
        }
        return isButtonEnabled ? (foregroundColor ?? theme.onPrimary) : theme.surfaceContainerHighest
    }

    private func activateFromKeyboard() -> KeyPress.Result {
        guard isButtonEnabled else { return .ignored }

        action()
        return .handled
    }

    var body: some View {
        let button = Button(
            action: action,
            label: {
                Text(verbatim: text)
                    .foregroundStyle(textColor)
                    .font(typography.labelLarge)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Dimensions.Padding.XSPadding)
                    .padding(.vertical, Dimensions.Padding.MSPadding)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(fillColor))
                    .overlay(
                        Capsule()
                            .strokeBorder(accentColor, lineWidth: Dimensions.Height.SBorder)
                            .opacity(isFocusHighlighted ? 1 : 0)
                    )
            })
            .disabled(!isButtonEnabled)
            .focusable(isButtonEnabled)
            .focused($isKeyboardFocused)
            .onKeyPress(.return) { activateFromKeyboard() }
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
