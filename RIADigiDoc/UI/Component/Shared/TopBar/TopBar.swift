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

struct TopBarContainer<Content: View>: View {
    @AppTheme private var theme
    var title: String?

    var leftIcon: String = "ic_m3_arrow_back_ios_48pt_wght400"
    var leftIconAccessibility: String = "Back"
    var onLeftClick: () -> Void = {}

    var rightPrimaryIcon: String = "ic_m3_help_48pt_wght400"
    var rightPrimaryIconAccessibility: String = "Help"
    var onRightPrimaryClick: (() -> Void)? = {}

    var rightSecondaryIcon: String = "ic_m3_settings_48pt_wght400"
    var rightSecondaryIconAccessibility: String = "Settings"
    var onRightSecondaryClick: () -> Void = {}

    var extraButtonIcon: String = "ic_m3_notifications_48pt_wght400"
    var extraButtonIconAccessibility: String = "Container notifications"
    var showExtraButton: Bool = false
    var extraBadgeCount: Int = 0
    var onExtraButtonClick: () -> Void = {}

    var showRightIcons: Bool = true

    var bottomSheetActions: [BottomSheetButton]?

    var excludeDestinations: [SettingsMenuBottomSheetPages] = []

    let content: () -> Content

    @State private var navigateToLanguageChooser = false
    @State private var navigateToThemeChooser = false
    @State private var navigateToAdvancedSettings = false

    @State private var showSettingsSheet = false

    var body: some View {
        VStack(spacing: Dimensions.Padding.ZeroPadding) {
            TopBar(
                title: title,
                leftIcon: leftIcon,
                leftIconAccessibility: leftIconAccessibility,
                onLeftClick: onLeftClick,

                rightPrimaryIcon: rightPrimaryIcon,
                rightPrimaryIconAccessibility: rightPrimaryIconAccessibility,
                onRightPrimaryClick: onRightPrimaryClick,

                rightSecondaryIcon: rightSecondaryIcon,
                rightSecondaryIconAccessibility: rightSecondaryIconAccessibility,
                onRightSecondaryClick: {
                    showSettingsSheet = true
                },

                extraButtonIcon: extraButtonIcon,
                extraButtonIconAccessibility: extraButtonIconAccessibility,
                showExtraButton: showExtraButton,
                extraBadgeCount: extraBadgeCount,
                onExtraButtonClick: onExtraButtonClick,
                showRightIcons: showRightIcons
            )

            content()

            NavigationLink(destination: LanguageChooserView(), isActive: $navigateToLanguageChooser) {}
                .accessibilityHidden(!showSettingsSheet)
            NavigationLink(destination: ThemeChooserView(), isActive: $navigateToThemeChooser) {}
                .accessibilityHidden(!showSettingsSheet)
            NavigationLink(destination: AdvancedSettingsView(), isActive: $navigateToAdvancedSettings) {}
                .accessibilityHidden(!showSettingsSheet)

        }
        .bottomSheet(isPresented: $showSettingsSheet, actions: buildBottomSheetActions())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(theme.surface)
    }

    private func buildBottomSheetActions() -> [BottomSheetButton] {
        if let customActions = bottomSheetActions {
            return customActions
        } else {
            return SettingsMenuBottomSheetActions.actions(
                showLanguageChooserButton: !excludeDestinations.contains(.language),
                showThemeChooserButton: !excludeDestinations.contains(.theme),
                showAdvancedSettingsButton: !excludeDestinations.contains(.advanced),
                onLanguageChooserClick: {
                    navigateToLanguageChooser = true
                },
                onThemeChooserClick: {
                    navigateToThemeChooser = true
                },
                onAdvancedSettingsClick: {
                    navigateToAdvancedSettings = true
                }
            )
        }
    }
}

struct TopBar: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var title: String?

    var leftIcon: String
    var leftIconAccessibility: String
    var onLeftClick: () -> Void = {}

    var rightPrimaryIcon: String
    var rightPrimaryIconAccessibility: String
    var onRightPrimaryClick: (() -> Void)?

    var rightSecondaryIcon: String
    var rightSecondaryIconAccessibility: String
    var onRightSecondaryClick: () -> Void = {}

    var extraButtonIcon: String
    var extraButtonIconAccessibility: String
    var showExtraButton: Bool = false
    var extraBadgeCount: Int = 0
    var onExtraButtonClick: () -> Void = {}

    var showRightIcons: Bool = true

    var body: some View {
        HStack {
            Button(action: onLeftClick) {
                Image(leftIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onBackground)
            }
            .accessibilityLabel(leftIconAccessibility)

            if let title = title {
                Text(title)
                    .foregroundStyle(theme.onSurface)
                    .font(typography.titleLarge)
                    .padding(.leading, Dimensions.Padding.XSPadding)
                    .accessibilityAddTraits(.isHeader)
            }

            Spacer()

            if showRightIcons {
                HStack(spacing: Dimensions.Padding.SPadding) {
                    if showExtraButton {
                        Button(action: onExtraButtonClick) {
                            ZStack(alignment: .topTrailing) {
                                Image(extraButtonIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onBackground)
                                if extraBadgeCount > 0 {
                                    Text(verbatim: "\(extraBadgeCount)")
                                        .frame(
                                            width: Dimensions.Icon.IconSizeMicro,
                                            height: Dimensions.Icon.IconSizeMicro
                                        )
                                        .font(typography.bodySmall)
                                        .foregroundStyle(Color.white)
                                        .padding(Dimensions.Padding.XXSPadding)
                                        .minimumScaleFactor(0.5)
                                        .background(Circle().fill(theme.onError))
                                        .offset(x: Dimensions.Padding.XSPadding, y: -Dimensions.Padding.XSPadding)
                                }
                            }
                        }
                        .accessibilityLabel(extraButtonIconAccessibility)
                    }

                    if let onRightPrimaryClick = onRightPrimaryClick {
                        Button(action: onRightPrimaryClick) {
                            Image(rightPrimaryIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                .foregroundStyle(theme.onBackground)
                        }
                        .accessibilityLabel(rightPrimaryIconAccessibility)
                    }

                    Button(action: onRightSecondaryClick) {
                        Image(rightSecondaryIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                    }
                    .accessibilityLabel(rightSecondaryIconAccessibility)
                }
            }
        }
        .padding(Dimensions.Padding.SPadding)
        .background(theme.surface)
    }
}
