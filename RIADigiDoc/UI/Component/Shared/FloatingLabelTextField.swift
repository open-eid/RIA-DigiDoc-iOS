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

    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var placeholder: String = ""

    @State private var isPasswordVisible: Bool = false
    @State private var isFocused: Bool = false
    @FocusState private var fieldIsFocused: Bool

    private var shouldFloatLabel: Bool {
        !text.isEmpty || isFocused
    }

    var body: some View {
        ZStack {
            mainTextField
            floatingLabel
        }
    }

    @ViewBuilder
    private var mainTextField: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .multilineTextAlignment(.leading)
                } else {
                    TextField(placeholder, text: $text)
                        .multilineTextAlignment(.leading)
                }
            }
            .font(typography.bodyLarge)
            .foregroundStyle(theme.onSurface)
            .focused($fieldIsFocused)
            .onChange(of: fieldIsFocused) { newValue in
                withAnimation(.easeInOut(duration: Dimensions.Duration.focusAnimation)) {
                    isFocused = newValue
                }
            }
            .frame(height: Dimensions.Icon.IconSizeXXS)

            Spacer()

            if isSecure {
                toggleVisibilityIconButton
            } else if !text.isEmpty {
                clearIconButton
            }
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .padding(.vertical, Dimensions.Padding.MSPadding)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.XXSCornerRadius)
                .stroke(
                    isFocused ? theme.primary : theme.outline,
                    lineWidth: isFocused ? Dimensions.Height.SBorder : Dimensions.Height.XSBorder
                )
        )
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
    }

    @ViewBuilder
    private var floatingLabel: some View {
        HStack {
            Text(title)
                .font(shouldFloatLabel ? typography.bodySmall : typography.bodyLarge)
                .foregroundStyle(
                    shouldFloatLabel
                    ? (isFocused ? theme.primary : theme.onSurfaceVariant)
                    : theme.onSurfaceVariant
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
    }
}

// MARK: - Preview

#Preview {
    FloatingLabelTextField(
        title: "field label",
        text: .constant("text inside field")
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())

    FloatingLabelTextField(
        title: "field label",
        text: .constant("")
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())

    FloatingLabelTextField(
        title: "field label",
        text: .constant(""),
        isSecure: true
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
