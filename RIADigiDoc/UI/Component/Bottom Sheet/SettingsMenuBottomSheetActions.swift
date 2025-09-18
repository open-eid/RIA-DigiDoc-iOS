struct SettingsMenuBottomSheetActions {
    static func actions(
        currentPage: SettingsMenuBottomSheetPages? = nil,
        onLanguageChooserClick: @escaping () -> Void = {},
        onThemeChooserClick: @escaping () -> Void = {},
        onAdvancedSettingsClick: @escaping () -> Void = {}
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                showButton: currentPage != .language,
                icon: "ic_m3_chat_bubble_48pt_wght400",
                title: "Main settings menu language",
                accessibilityLabel: "Main settings menu language",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onLanguageChooserClick
            ),
            BottomSheetButton(
                showButton: currentPage != .theme,
                icon: "ic_m3_invert_colors_48pt_wght400",
                title: "Main settings menu appearance",
                accessibilityLabel: "Main settings menu appearance",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onThemeChooserClick
            ),
            BottomSheetButton(
                showButton: currentPage != .advanced,
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
