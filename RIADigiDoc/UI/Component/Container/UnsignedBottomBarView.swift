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

import FactoryKit
import SwiftUI

struct UnsignedBottomBarView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    let showLeftButton: Bool
    let leftButtonIconName: String
    let leftButtonLabel: String
    let leftButtonAccessibilityLabel: String
    let leftButtonAction: () -> Void

    let rightButtonEnabled: Bool
    let rightButtonIconName: String
    let rightButtonLabel: String
    let rightButtonAccessibilityLabel: String
    let rightButtonAction: () -> Void

    var body: some View {
        HStack {
            if showLeftButton {
                Button(action: leftButtonAction, label: {
                    HStack(spacing: Dimensions.Padding.XSPadding, content: {
                        Image(leftButtonIconName)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(theme.onSurface)
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .accessibilityHidden(true)

                        Text(languageSettings.localized(leftButtonLabel))
                            .foregroundStyle(theme.primary)
                            .font(typography.titleMedium)
                            .accessibilityLabel(leftButtonAccessibilityLabel)
                    })
                    .foregroundStyle(theme.surfaceContainer)
                })
            }

            Spacer()

            Button(action: rightButtonAction, label: {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image(rightButtonIconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onSurface)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)

                    Text(languageSettings.localized(rightButtonLabel))
                        .foregroundStyle(theme.primary)
                        .font(typography.titleMedium)
                        .accessibilityLabel(rightButtonAccessibilityLabel)
                }
                .padding(.horizontal, Dimensions.Padding.MPadding)
                .padding(.vertical, Dimensions.Padding.XSPadding)
                .background(
                    Capsule()
                        .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
                )
            })
            .disabled(!rightButtonEnabled)
            .foregroundStyle(theme.surfaceContainer)
        }
        .padding(.vertical, Dimensions.Padding.SPadding)
        .padding(.horizontal, Dimensions.Padding.MPadding)
        .background(theme.surfaceContainer)
    }
}

#Preview {
    UnsignedBottomBarView(
        showLeftButton: true,
        leftButtonIconName: "ic_m3_add_48pt_wght400",
        leftButtonLabel: "Add more files",
        leftButtonAccessibilityLabel: "Add more files",
        leftButtonAction: {},

        rightButtonEnabled: true,
        rightButtonIconName: "ic_m3_stylus_note_48pt_wght400",
        rightButtonLabel: "Sign container",
        rightButtonAccessibilityLabel: "Sign container",
        rightButtonAction: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
