struct ContainerNameBottomSheetActions {
    static func actions(
        languageSettings: LanguageSettings,
        isEditContainerButtonShown: Bool,
        isEncryptButtonShown: Bool,
        onRenameContainerButtonClick: @escaping () -> Void,
        onSaveContainerButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                showButton: isEditContainerButtonShown,
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Change container name"),
                accessibilityLabel: languageSettings.localized("Change container name").lowercased(),
                onClick: onRenameContainerButtonClick
            ),
            BottomSheetButton(
                icon: "ic_m3_download_48pt_wght400",
                title: languageSettings.localized("Save container"),
                accessibilityLabel: languageSettings.localized("Save container").lowercased(),
                onClick: onSaveContainerButtonClick
            ),
            BottomSheetButton(
                showButton: isEncryptButtonShown,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: languageSettings.localized("Encrypt"),
                accessibilityLabel: languageSettings.localized("Encrypt").lowercased(),
                showExtraIcon: true,
                onClick: {
                    // TODO: Implement encrypt action
                }
            )
        ]
    }
}
