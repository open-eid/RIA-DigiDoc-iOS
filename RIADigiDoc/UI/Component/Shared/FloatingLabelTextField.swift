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

struct FloatingLabelTextField: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.sizeCategory) private var sizeCategory
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @AccessibilityFocusState private var isAccessibilityFocused: Bool

    @State private var selection: TextSelection? = nil

    @State private var floatingLabelHeight: CGFloat = 0

    // MARK: - Parameters
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    let isSecure: Bool
    let isDropdown: Bool
    let isDisabled: Bool
    let onDropdownTap: (() -> Void)?
    let isError: Bool
    let errorText: String
    let submitLabel: SubmitLabel
    let keyboardType: UIKeyboardType
    let showDashButton: Bool
    let identifier: String
    let sortPriority: Double
    let spellOutCharacters: Bool
    let onDone: (() -> Void)

    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        isDropdown: Bool = false,
        isDisabled: Bool = false,
        onDropdownTap: (() -> Void)? = {},
        isError: Bool = false,
        errorText: String = "",
        submitLabel: SubmitLabel = .done,
        keyboardType: UIKeyboardType = .default,
        showDashButton: Bool = false,
        identifier: String = "",
        sortPriority: Double = 0,
        spellOutCharacters: Bool = false,
        onDone: @escaping (() -> Void) = {}
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.isDropdown = isDropdown
        self.isDisabled = isDisabled
        self.onDropdownTap = onDropdownTap
        self.isError = isError
        self.errorText = errorText
        self.submitLabel = submitLabel
        self.keyboardType = keyboardType
        self.showDashButton = showDashButton
        self.identifier = identifier
        self.sortPriority = sortPriority
        self.spellOutCharacters = spellOutCharacters
        self.onDone = onDone
    }

    // MARK: - State
    @State private var isPasswordVisible: Bool = false
    @State private var isFocused: Bool = false
    @FocusState private var fieldIsFocused: Bool

    // MARK: - Computed properties

    private var labelHeight: CGFloat {
        FontTypography.bodySmallSize * Dimensions.TextField.lineHeightMultiplier
    }

    private var textFieldTopPadding: CGFloat {
        guard shouldFloatLabel else { return 0 }
        let baseValue = floatingLabelHeight * Dimensions.TextField.paddingMultiplier
        return sizeCategory.isAccessibilityCategory ?
        floatingLabelHeight * Dimensions.TextField.accessibilityPaddingMultiplier :
        baseValue
    }

    private var shouldFloatLabel: Bool {
        !text.isEmpty || isFocused
    }

    private var isInteractionEnabled: Bool {
        !isDisabled && !isDropdown
    }

    private var titleColor: Color {
        if isError {
            return theme.error
        }
        if isFocused {
            return theme.primary
        }
        if isDisabled {
            return theme.onSurface.opacity(Dimensions.Shadow.SOpacity)
        }
        return theme.onSurfaceVariant
    }

    private var textColor: Color {
        if isDisabled {
            return theme.onSurface.opacity(Dimensions.Shadow.SOpacity)
        }
        return theme.onSurfaceVariant
    }

    private var borderColor: Color {
        if isError {
            return theme.error
        }
        if isDisabled {
            return theme.onSurface.opacity(Dimensions.Shadow.SOpacity)
        }
        if isFocused && isInteractionEnabled {
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

    private var textFieldAccessibility: String {
        let visibleText: String? =
        (isSecure && !isPasswordVisible) ? nil :
        spellOutCharacters ? text.map(String.init)
            .joined(separator: " ") : text

        return [
            title,
            visibleText,
            errorText
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    // MARK: - Body

    var body: some View {
        VStack(
            alignment: .leading
        ) {
            mainContainer
            if isError && !errorText.isEmpty {
                Text(verbatim: errorText)
                    .font(typography.bodySmall)
                    .foregroundStyle(theme.error)
                    .padding(.vertical, Dimensions.Padding.XXSPadding)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
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
                .accessibilityHidden(true)
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
                .padding(.top,
                    shouldFloatLabel ? max(
                        floatingLabelHeight / 2 - Dimensions.Padding.XXSPadding,
                        Dimensions.Padding.XXSPadding
                    ) : 0
                )
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .background(borderBackground)
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(Text(verbatim: textFieldAccessibility))
        .accessibilityValue(Text(verbatim: ""))
    }

    // MARK: - Input

    @ViewBuilder
    private var inputContainer: some View {
        if voiceOverEnabled {
            containerContent
                .accessibilityElement(children: .contain)
        } else {
            containerContent
        }
    }

    private var containerContent: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            inputField
            Spacer()
            trailingIcon
        }
        .padding(.top,
            shouldFloatLabel ? max(
                floatingLabelHeight / 2 - Dimensions.Padding.XXSPadding,
                Dimensions.Padding.XXSPadding
            ) : 0
        )
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
                SecureField(
                    placeholder,
                    text: $text,
                    prompt: Text(verbatim: placeholder)
                        .foregroundStyle(theme.onSurfaceVariant)
                )
                .textFieldModifiers(
                    isDisabled: isDisabled,
                    keyboardType: keyboardType,
                    submitLabel: submitLabel,
                    spellOut: spellOutCharacters && isPasswordVisible,
                    isAccessibilityFocused: $isAccessibilityFocused,
                    onAppear: {},
                    onSubmit: {
                        isFocused = false
                        isAccessibilityFocused = true
                        onDone()
                    }
                )
                .privacySensitive()
                .toolbar { keyboardToolbar }
                .onChange(of: errorText, { _, newValue in
                    AccessibilityUtil.announceMessage(newValue)
                })
                .accessibilitySortPriority(sortPriority)
                .accessibilityLabel(Text(verbatim: title))
            } else {
                TextField(
                    placeholder,
                    text: $text,
                    prompt: Text(verbatim: placeholder)
                        .foregroundStyle(theme.onSurfaceVariant)
                )
                .textFieldModifiers(
                    isDisabled: isDisabled,
                    keyboardType: keyboardType,
                    submitLabel: submitLabel,
                    spellOut: spellOutCharacters && !isSecure && isPasswordVisible,
                    isAccessibilityFocused: $isAccessibilityFocused,
                    onAppear: {
                        selection = TextSelection(insertionPoint: text.endIndex)
                    },
                    onSubmit: {
                        fieldIsFocused = false
                        isAccessibilityFocused = true
                        onDone()
                    }
                )
                .toolbar { keyboardToolbar }
                .accessibilitySortPriority(sortPriority)
                .accessibilityLabel(Text(verbatim: title))
            }
        }
        .font(typography.bodyLarge)
        .foregroundStyle(textColor)
        .focused($fieldIsFocused)
        .onChange(of: fieldIsFocused) { _, newValue in
            if isInteractionEnabled {
                withAnimation(.easeInOut(duration: Dimensions.Duration.focusAnimation)) {
                    isFocused = newValue
                }
            }
        }
        .onChange(of: errorText, { _, newValue in
            AccessibilityUtil.announceMessage(newValue)
        })
        .frame(height: Dimensions.Icon.IconSizeXXS)
    }

    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            if fieldIsFocused {
                HStack {
                    if showDashButton {
                        Button(
                            action: { text.append("-") },
                            label: { Text(verbatim: "-") }
                        )
                    }

                    if keyboardType.needsDoneButton {
                        Button(
                            action: {
                                fieldIsFocused = false
                                isAccessibilityFocused = true
                                onDone()
                            },
                            label: { Text(verbatim: languageSettings.localized("Done")) }
                        )
                    }
                }
            }
        }
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
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXXS, height: Dimensions.Icon.IconSizeXXXS)
                    .foregroundStyle(isError ? theme.error : theme.onSurfaceVariant)
            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(languageSettings.localized("Clear text"))
        .accessibilityInputLabels([languageSettings.localized("Clear text")])
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
                    .foregroundStyle(isError ? theme.error : theme.onSurfaceVariant)

            }
        )
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(
            isPasswordVisible
            ? languageSettings.localized("Hide password")
            : languageSettings.localized("Show password")
        )
        .accessibilityInputLabels(
            isPasswordVisible
            ? [languageSettings.localized("Hide password")]
            : [languageSettings.localized("Show password")]
        )
    }

    // MARK: - Floating label

    @ViewBuilder
    private var floatingLabel: some View {
        HStack {
            Text(verbatim: shouldFloatLabel ? title : "")
                .font(shouldFloatLabel ? typography.bodySmall : typography.bodyLarge)
                .foregroundStyle(titleColor)
                .background(
                    Rectangle()
                        .fill(theme.surface)
                        .padding(.horizontal, -Dimensions.Padding.XXSPadding)
                        .opacity(shouldFloatLabel ? 1 : 0)
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            floatingLabelHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size.height) { _, newHeight in
                            floatingLabelHeight = newHeight
                        }
                    }
                )
                .offset(
                    y: shouldFloatLabel ?
                    -(Dimensions.Padding.MSPadding + textFieldTopPadding + labelHeight / 2) :
                        Dimensions.Padding.MSPadding
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

private extension View {
    func textFieldModifiers(
        isDisabled: Bool,
        keyboardType: UIKeyboardType,
        submitLabel: SubmitLabel,
        spellOut: Bool,
        isAccessibilityFocused: AccessibilityFocusState<Bool>.Binding,
        onAppear: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) -> some View {
        self
            .multilineTextAlignment(.leading)
            .disabled(isDisabled)
            .keyboardType(keyboardType)
            .submitLabel(submitLabel)
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .speechSpellsOutCharacters(spellOut)
            .accessibilityFocused(isAccessibilityFocused)
            .onAppear(perform: onAppear)
            .onSubmit(onSubmit)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        FloatingLabelTextField(
            title: "field label",
            placeholder: "field placeholder",
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
            isError: true,
            errorText: "input is invalid"
        )
    }
    .padding()
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
