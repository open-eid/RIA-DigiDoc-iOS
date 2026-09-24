// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct ModalContainer<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @AccessibilityFocusState private var isFocused: Bool

    var icon: String?
    var title: String
    var isConfirmButtonVisible: Bool = true
    var confirmButtonTitle: String = "OK"
    var cancelButtonTitle: String = "Cancel"
    var confirmButtonAccessibility: String?
    var cancelButtonAccessibility: String?
    var onConfirm: () -> Void
    var onCancel: () -> Void
    @ViewBuilder var content: Content

    private var header: some View {
        Text(verbatim: title)
            .foregroundStyle(theme.onSurface)
            .font(typography.headlineSmall)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, Dimensions.Padding.MSPadding)
            .padding(.trailing, Dimensions.Padding.LPadding)
            .padding(.bottom, Dimensions.Padding.MSPadding)
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

    private var containerContent: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            header
            content
                .padding(.horizontal, Dimensions.Padding.MSPadding)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            HStack(alignment: .center) {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityHidden(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            ViewThatFits(in: .vertical) {
                containerContent

                ScrollView(.vertical) {
                    containerContent
                }
            }

            HStack(spacing: Dimensions.Padding.MPadding) {
                Button(languageSettings.localized(cancelButtonTitle)) { onCancel() }
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)
                    .minimumScaleFactor(0.5)
                    .accessibilityLabel(
                        cancelButtonAccessibility ??
                        languageSettings.localized(cancelButtonTitle).lowercased()
                    )
                if isConfirmButtonVisible {
                    Button(languageSettings.localized(confirmButtonTitle)) { onConfirm() }
                        .font(typography.labelLarge)
                        .foregroundStyle(theme.primary)
                        .minimumScaleFactor(0.5)
                        .accessibilityLabel(
                            confirmButtonAccessibility ??
                            languageSettings.localized(confirmButtonTitle).lowercased()
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, Dimensions.Padding.MSPadding)
            .padding(.horizontal, Dimensions.Padding.SPadding)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                .fill(theme.surfaceContainerHighest)
        )
        .padding(.horizontal, Dimensions.Padding.XLPadding)
        .accessibilityAddTraits([.isModal])
    }
}
