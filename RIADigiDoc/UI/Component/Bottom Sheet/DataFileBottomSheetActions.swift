struct DataFileBottomSheetActions {
    static func actions(
        languageSettings: LanguageSettings,
        showRemoveFileButton: Bool,
        onOpenFileButtonClick: @escaping () -> Void,
        onSaveFileButtonClick: @escaping () -> Void
    ) -> [BottomSheetButton] {

        return [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Open file"),
                accessibilityLabel: languageSettings.localized("Open file").lowercased(),
                onClick: onOpenFileButtonClick
            ),
            BottomSheetButton(
                icon: "ic_m3_download_48pt_wght400",
                title: languageSettings.localized("Save file"),
                accessibilityLabel: languageSettings.localized("Save file").lowercased(),
                onClick: onSaveFileButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveFileButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: languageSettings.localized("Remove file"),
                accessibilityLabel: languageSettings.localized("Remove file").lowercased(),
                onClick: {
                    // TODO: Implement remove‑file action
                }
            )
        ]
    }
}
