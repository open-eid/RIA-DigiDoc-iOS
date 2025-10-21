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

struct SettingsMenuBottomSheetActions {
    static func actions(
        showLanguageChooserButton: Bool = true,
        showThemeChooserButton: Bool = true,
        showAdvancedSettingsButton: Bool = true,
        onLanguageChooserClick: @escaping () -> Void = {},
        onThemeChooserClick: @escaping () -> Void = {},
        onAdvancedSettingsClick: @escaping () -> Void = {}
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                showButton: showLanguageChooserButton,
                icon: "ic_m3_chat_bubble_48pt_wght400",
                title: "Main settings menu language",
                accessibilityLabel: "Main settings menu language",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onLanguageChooserClick
            ),
            BottomSheetButton(
                showButton: showThemeChooserButton,
                icon: "ic_m3_invert_colors_48pt_wght400",
                title: "Main settings menu appearance",
                accessibilityLabel: "Main settings menu appearance",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onThemeChooserClick
            ),
            BottomSheetButton(
                showButton: showAdvancedSettingsButton,
                icon: "ic_m3_tune_48pt_wght400",
                title: "Main settings menu advanced",
                accessibilityLabel: "Main settings menu advanced",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onAdvancedSettingsClick
            )
        ]
    }
}
