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
