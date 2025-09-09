struct HomeMenuBottomSheetActions {
    static func actions(
        onInfoClick: @escaping () -> Void,
        onAccessibilityClick: @escaping () -> Void,
        onDiagnosticsClick: @escaping () -> Void
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_info_48pt_wght400",
                title: "Main home menu about",
                accessibilityLabel: "Main home menu about",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onInfoClick,
            ),
            BottomSheetButton(
                icon: "ic_m3_accessibility_new_48pt_wght400",
                title: "Main home menu accessibility",
                accessibilityLabel: "Main home menu accessibility",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onAccessibilityClick
            ),
            BottomSheetButton(
                icon: "ic_m3_show_chart_48pt_wght400",
                title: "Main home menu diagnostics",
                accessibilityLabel: "Main home menu diagnostics",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onDiagnosticsClick
            )
        ]
    }
}
