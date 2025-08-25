struct SignatureBottomSheetActions {
    static func actions(
        languageSettings: LanguageSettings,
        showRemoveSignatureButton: Bool,
        onDetailsButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Signature details"),
                accessibilityLabel: languageSettings.localized("Signature details").lowercased(),
                onClick: onDetailsButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveSignatureButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: languageSettings.localized("Remove signature"),
                accessibilityLabel: languageSettings.localized("Remove signature").lowercased(),
                onClick: {
                    // TODO: Implement remove signature action
                }
            )
        ]
    }
}
