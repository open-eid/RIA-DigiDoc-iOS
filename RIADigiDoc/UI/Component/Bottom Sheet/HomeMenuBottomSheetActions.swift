struct HomeMenuBottomSheetActions {
    static func actions(
        languageSettings: LanguageSettings,
        onInfoClick: @escaping () -> Void,
        onAccessibilityClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_info_48pt_wght400",
                title: languageSettings.localized("Main home menu about"),
                accessibilityLabel: languageSettings.localized("Main home menu about").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onInfoClick,
            ),
            BottomSheetButton(
                icon: "ic_m3_accessibility_new_48pt_wght400",
                title: languageSettings.localized("Main home menu accessibility"),
                accessibilityLabel: languageSettings.localized("Main home menu accessibility").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onAccessibilityClick
            ),
            BottomSheetButton(
                icon: "ic_m3_show_chart_48pt_wght400",
                title: languageSettings.localized("Main home menu diagnostics"),
                accessibilityLabel: languageSettings.localized("Main home menu diagnostics").lowercased(),
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: {
                    // TODO: Implement diagnostics action
                }
            )
        ]
    }
}
