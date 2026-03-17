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

struct ToastOverlay: View {
    private var toast = ToastController.shared

    @AppTheme private var theme

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            if toast.isVisible, let message = toast.message {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image("ic_m3_info_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: Dimensions.Icon.IconSizeXXS,
                            height: Dimensions.Icon.IconSizeXXS
                        )
                        .foregroundStyle(getForegroundColor(toast.type))

                    Text(verbatim: message)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .background(getBackgroundColor(toast.type).opacity(0.9))
                .foregroundStyle(getForegroundColor(toast.type))
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

    private func getBackgroundColor(_ type: ToastType) -> Color {
        switch type {
        case .success:
            return theme.successContainer
        case .error:
            return theme.errorContainer
        }
    }

    private func getForegroundColor(_ type: ToastType) -> Color {
        switch type {
        case .success:
            return theme.onSuccessContainer
        case .error:
            return theme.onErrorContainer
        }
    }
}
