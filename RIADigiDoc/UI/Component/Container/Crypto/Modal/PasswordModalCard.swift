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

struct PasswordModalCard<Content: View>: View {
    @AppTheme private var theme

    @State private var keyboardHeight: CGFloat = 0

    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()
                .accessibilityHidden(true)
                .allowsHitTesting(true)

            content()
                .padding(Dimensions.Padding.MPadding)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                        .fill(theme.surface)
                )
                .padding(.horizontal, Dimensions.Padding.MPadding)
                .padding(.vertical, Dimensions.Padding.XLPadding)
                .offset(y: -keyboardHeight / 2)
                .animation(
                    .easeOut(duration: Dimensions.Duration.focusAnimation),
                    value: keyboardHeight
                )
                .accessibilityAddTraits([.isModal])
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        ) { notification in
            guard let frame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect else { return }
            keyboardHeight = frame.height
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        ) { _ in
            keyboardHeight = 0
        }
    }
}

struct PasswordModalTitleView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var isFocused: Bool

    let text: String

    var body: some View {
        Text(verbatim: text)
            .foregroundStyle(theme.onSurface)
            .font(typography.headlineSmall)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.5)
            .accessibilityHeading(.h1)
            .accessibilityAddTraits([.isHeader])
            .accessibilityFocused($isFocused)
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    isFocused = true
                }
            }
    }
}

struct PasswordModalButtonRow: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    let cancelLabel: String
    let confirmLabel: String
    var isConfirmEnabled: Bool = true
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: Dimensions.Padding.MPadding) {
            Button(cancelLabel) { onCancel() }
                .font(typography.labelLarge)
                .foregroundStyle(theme.primary)
                .minimumScaleFactor(0.5)
            Button(confirmLabel) { onConfirm() }
                .font(typography.labelLarge)
                .foregroundStyle(isConfirmEnabled ? theme.primary : theme.onSurfaceVariant)
                .minimumScaleFactor(0.5)
                .disabled(!isConfirmEnabled)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.vertical, Dimensions.Padding.MSPadding)
    }
}
