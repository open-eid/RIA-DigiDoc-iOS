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

struct FloatingLabelTextField: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    // MARK: - Parameters
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    let isSecure: Bool
    let isDropdown: Bool
    let isDisabled: Bool
    let onDropdownTap: (() -> Void)?
    let isInvalid: Bool
    let invalidText: String
    let submitLabel: SubmitLabel
    let keyboardType: UIKeyboardType
    let showDashButton: Bool

    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        isDropdown: Bool = false,
        isDisabled: Bool = false,
        onDropdownTap: (() -> Void)? = {},
        isInvalid: Bool = false,
        invalidText: String = "",
        submitLabel: SubmitLabel = .done,
        keyboardType: UIKeyboardType = .default,
        showDashButton: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.isDropdown = isDropdown
        self.isDisabled = isDisabled
        self.onDropdownTap = onDropdownTap
        self.isInvalid = isInvalid
        self.invalidText = invalidText
        self.submitLabel = submitLabel
        self.keyboardType = keyboardType
        self.showDashButton = showDashButton
    }

    // MARK: - State
    @State private var isPasswordVisible: Bool = false
    @State private var isFocused: Bool = false
    @FocusState private var fieldIsFocused: Bool

    // MARK: - Computed properties

    private var shouldFloatLabel: Bool {
        !text.isEmpty || isFocused
    }

    private var isInteractionEnabled: Bool {
        !isDisabled && !isDropdown
    }

    private var textColor: Color {
        if isDisabled {
            return theme.onSurface.opacity(Dimensions.Shadow.SOpacity)
        }
        return theme.onSurfaceVariant
    }

    private var borderColor: Color {
        if isDisabled {
            return theme.onSurface.opacity(Dimensions.Shadow.SOpacity)
        } else if isFocused && isInteractionEnabled {
            return theme.primary
        }
        return theme.outline
    }

    private var borderWidth: CGFloat {
        if isFocused && isInteractionEnabled {
            return Dimensions.Height.SBorder
        } else {
            return Dimensions.Height.XSBorder
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(
            alignment: .leading
        ) {
            mainContainer
            if isInvalid {
                Text(invalidText)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.error)
            }
        }
    }

    @ViewBuilder
    private var mainContainer: some View {
        ZStack {
            if isDropdown {
                dropdownButton
            } else {
                inputContainer
            }
            floatingLabel
        }
    }

    // MARK: - Dropdown button

    @ViewBuilder
    private var dropdownButton: some View {
        Button(
            action: {
                if !isDisabled {
                    onDropdownTap?()
                }
            },
            label: {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Text(verbatim: text)
                        .font(typography.bodyLarge)
                        .foregroundStyle(textColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: Dimensions.Icon.IconSizeXXS)

                    Spacer()

                    dropdownArrowIcon
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .background(borderBackground)
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(text)
    }

    // MARK: - Input

    @ViewBuilder
    private var inputContainer: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            inputField
            Spacer()
            trailingIcon
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .padding(.vertical, Dimensions.Padding.MSPadding)
        .background(borderBackground)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var borderBackground: some View {
        RoundedRectangle(cornerRadius: Dimensions.Corner.XXSCornerRadius)
            .stroke(borderColor, lineWidth: borderWidth)
    }

    @ViewBuilder
    private var inputField: some View {
        Group {
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .multilineTextAlignment(.leading)
                    .disabled(isDisabled)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        isFocused = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            if fieldIsFocused {
                                HStack {
                                    if showDashButton {
                                        Button(
                                            action: { text.append("-") },
                                            label: { Text(verbatim: "-") }
                                        )
                                    }

                                    Button(
                                        action: { fieldIsFocused = false },
                                        label: { Text(verbatim: languageSettings.localized("Done")) }
                                    )
                                }
                            }
                        }
                    }
            } else {
                TextField(placeholder, text: $text)
                    .multilineTextAlignment(.leading)
                    .disabled(isDisabled)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        fieldIsFocused = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            if fieldIsFocused {
                                HStack {
                                    if showDashButton {
                                        Button(
                                            action: { text.append("-") },
                                            label: { Text(verbatim: "-") }
                                        )
                                    }

                                    Button(
                                        action: { fieldIsFocused = false },
                                        label: { Text(verbatim: languageSettings.localized("Done")) }
                                    )
                                }
                            }
                        }
                    }
            }
        }
        .font(typography.bodyLarge)
        .foregroundStyle(textColor)
        .focused($fieldIsFocused)
        .onChange(of: fieldIsFocused) { newValue in
            if isInteractionEnabled {
                withAnimation(.easeInOut(duration: Dimensions.Duration.focusAnimation)) {
                    isFocused = newValue
                }
            }
        }
        .frame(height: Dimensions.Icon.IconSizeXXS)
    }

    // MARK: - Icons

    @ViewBuilder
    private var trailingIcon: some View {
        if isSecure && !isDisabled {
            toggleVisibilityIconButton
        } else if !text.isEmpty && !isDisabled {
            clearIconButton
        }
    }

    @ViewBuilder
    private var dropdownArrowIcon: some View {
        Image("ic_m3_arrow_right_48pt_wght400")
            .resizable()
            .scaledToFit()
            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
            .foregroundStyle(textColor)
            .rotationEffect(.degrees(90))
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var clearIconButton: some View {
        Button(
            action: { text = "" },
            label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .accessibilityLabel(languageSettings.localized("Clear text"))
            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var toggleVisibilityIconButton: some View {
        Button(
            action: { isPasswordVisible.toggle() },
            label: {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .accessibilityLabel(
                        isPasswordVisible
                        ? languageSettings.localized("Hide password")
                        : languageSettings.localized("Show password")
                    )
            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Floating label

    @ViewBuilder
    private var floatingLabel: some View {
        HStack {
            Text(title)
                .font(shouldFloatLabel ? typography.bodySmall : typography.bodyLarge)
                .foregroundStyle(
                    isFocused
                    ? theme.primary
                    : (isDisabled ? theme.onSurface.opacity(Dimensions.Shadow.SOpacity) : theme.onSurfaceVariant)
                )
                .background(
                    Rectangle()
                        .fill(theme.surface)
                        .padding(.horizontal, -Dimensions.Padding.XXSPadding)
                        .opacity(shouldFloatLabel ? 1 : 0)
                )
                .offset(
                    y: shouldFloatLabel ? -Dimensions.Padding.MPadding : Dimensions.Padding.ZeroPadding
                )
                .animation(
                    .easeInOut(
                        duration: Dimensions.Duration.focusAnimation
                    ),
                    value: shouldFloatLabel
                )

            Spacer()
        }
        .padding(.leading, Dimensions.Padding.SPadding)
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        FloatingLabelTextField(
            title: "field label",
            text: .constant("text inside field")
        )

        FloatingLabelTextField(
            title: "dropdown field",
            text: .constant("Selected value"),
            isDropdown: true,
            onDropdownTap: { print("Dropdown tapped") }
        )

        FloatingLabelTextField(
            title: "disabled field",
            text: .constant("disabled text"),
            isDisabled: true
        )

        FloatingLabelTextField(
            title: "secure field",
            text: .constant("password"),
            isSecure: true
        )

        FloatingLabelTextField(
            title: "invalid field",
            text: .constant("invalid input"),
            isInvalid: true,
            invalidText: "input is invalid"
        )
    }
    .padding()
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
