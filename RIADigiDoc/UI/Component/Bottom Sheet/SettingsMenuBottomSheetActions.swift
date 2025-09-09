struct SettingsMenuBottomSheetActions {
    static func actions(
        languageSettings: LanguageSettings,
        onLanguageChooserClick: @escaping () -> Void
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_chat_bubble_48pt_wght400",
                title: languageSettings.localized("Main settings menu language"),
                accessibilityLabel: languageSettings.localized("Main settings menu language").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onLanguageChooserClick,
            ),
            BottomSheetButton(
                icon: "ic_m3_invert_colors_48pt_wght400",
                title: languageSettings.localized("Main settings menu appearance"),
                accessibilityLabel: languageSettings.localized("Main settings menu appearance").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: {} // TODO: implement appearance on click
            ),
            BottomSheetButton(
                icon: "ic_m3_tune_48pt_wght400",
                title: languageSettings.localized("Main settings menu advanced"),
                accessibilityLabel: languageSettings.localized("Main settings menu advanced").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: {} // TODO: implement advanced on click
            )
        ]
    }
}
