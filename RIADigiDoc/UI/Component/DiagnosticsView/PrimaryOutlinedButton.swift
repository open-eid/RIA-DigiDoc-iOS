// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct PrimaryOutlinedButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    private let text: String
    private let assetImageName: String?
    private let isButtonEnabled: Bool
    private let action: () -> Void

    @Binding private var currentFocus: AccessibilityField?
    @State private var focusedField: AccessibilityField?
    @AccessibilityFocusState private var isFocused: Bool
    @AccessibilityFocusState private var accessibilityField: AccessibilityField?

    init(
        text: String,
        assetImageName: String?,
        isButtonEnabled: Bool = true,
        action: @escaping () -> Void,
        focusedField: AccessibilityField?,
        currentFocus: Binding<AccessibilityField?>,
    ) {
        self.text = text
        self.assetImageName = assetImageName
        self.isButtonEnabled = isButtonEnabled
        self.action = action
        self.focusedField = focusedField
        self._currentFocus = currentFocus
    }

    var body: some View {
        let button = Button(
            action: action,
            label: {
                HStack {
                    if let image = assetImageName {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(theme.primary)
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .accessibilityHidden(true)
                    }
                    Text(verbatim: text)
                        .foregroundStyle(isButtonEnabled ? theme.primary : theme.surfaceContainerHighest)
                        .font(typography.labelLarge)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(Dimensions.Padding.XSPadding)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isButtonEnabled ? theme.surface : Color.gray)
                )
                .overlay(
                    Capsule()
                        .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
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
    VStack(spacing: Dimensions.Padding.XSPadding) {
        PrimaryOutlinedButton(
            text: "button without icon",
            assetImageName: nil,
            action: {},
            focusedField: nil,
            currentFocus: .constant(nil)
        )
        PrimaryOutlinedButton(
            text: "button with icon",
            assetImageName: "ic_m3_download_48pt_wght400",
            action: {},
            focusedField: nil,
            currentFocus: .constant(nil)
        )
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
