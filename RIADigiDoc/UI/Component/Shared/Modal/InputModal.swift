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

struct InputModal: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme

    var icon: String?
    var title: String
    var placeholder: String
    @Binding var text: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            onConfirm: onConfirm,
            onCancel: onCancel
        ) {
            TextField(placeholder, text: $text)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .padding(.leading, Dimensions.Padding.MSPadding)
                .padding(.trailing, Dimensions.Padding.LPadding)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.XXSCornerRadius)
                        .stroke(theme.primary, lineWidth: Dimensions.Height.XSBorder)
                )
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button {
                                text = ""
                            } label: {
                                Image("ic_m3_close_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onSurface)
                                    .padding(.trailing, Dimensions.Padding.XSPadding)
                                    .accessibilityLabel(languageSettings.localized("Close"))
                            }
                        }
                    }
                )
        }
    }
}
