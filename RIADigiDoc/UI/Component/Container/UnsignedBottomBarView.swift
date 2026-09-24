// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
    var showBackground: Bool = true

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
                            .minimumScaleFactor(0.5)
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
                        .minimumScaleFactor(0.5)
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
        .background(showBackground ? theme.surfaceContainer : Color.clear)
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
