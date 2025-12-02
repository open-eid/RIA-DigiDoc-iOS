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
        VStack {
            Spacer()

            if toast.isVisible, let message = toast.message {
                Text(message)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .padding(.vertical, Dimensions.Padding.MSPadding)
                    .background(theme.onBackground.opacity(0.9))
                    .foregroundStyle(theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius))
                    .shadow(radius: Dimensions.Corner.XXSCornerRadius)
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom)
                                .combined(with: .opacity),
                            removal: .move(edge: .bottom)
                                .combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: toast.isVisible)
                    .padding(.bottom, Dimensions.Padding.LPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .zIndex(999)
    }
}
