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

                    Text(verbatim: message)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.5)
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
