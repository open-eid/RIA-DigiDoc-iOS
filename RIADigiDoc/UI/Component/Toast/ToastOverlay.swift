// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct ToastOverlay: View {
    private var toast = ToastController.shared

    @AppTheme private var theme

    private var style: (icon: String, background: Color, foreground: Color) {
        switch toast.type {
        case .success:
            return (
                icon: "ic_m3_check_48pt_wght400",
                background: theme.successContainer,
                foreground: theme.onSuccessContainer
            )
        case .error:
            return (
                icon: "ic_m3_error_48pt_wght400",
                background: theme.errorContainer,
                foreground: theme.onErrorContainer
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            if toast.isVisible, let message = toast.message {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image(style.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: Dimensions.Icon.IconSizeXXS,
                            height: Dimensions.Icon.IconSizeXXS
                        )
                        .foregroundStyle(style.foreground)
                        .accessibilityHidden(true)

                    Text(verbatim: message)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.5)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .background(style.background.opacity(0.9))
                .foregroundStyle(style.foreground)
                .clipShape(RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius))
                .shadow(radius: Dimensions.Corner.XXSCornerRadius)
                .padding(.horizontal, Dimensions.Padding.MSPadding)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom) .combined(with: .opacity),
                        removal: .move(edge: .bottom) .combined(with: .opacity)
                    )
                )
                .animation(.easeInOut(duration: 0.3), value: toast.isVisible)
                .padding(.bottom, Dimensions.Padding.XXLPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Dimensions.Padding.MSPadding)
        .allowsHitTesting(false)
        .zIndex(999)
    }
}
