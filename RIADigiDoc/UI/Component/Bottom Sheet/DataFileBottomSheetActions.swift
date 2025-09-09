struct DataFileBottomSheetActions {
    static func actions(
        showRemoveFileButton: Bool,
        onOpenFileButtonClick: @escaping () -> Void,
        onSaveFileButtonClick: @escaping () -> Void
    ) -> [BottomSheetButton] {

        return [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: "Open file",
                accessibilityLabel: "Open file",
                onClick: onOpenFileButtonClick
            ),
            BottomSheetButton(
                icon: "ic_m3_download_48pt_wght400",
                title: "Save file",
                accessibilityLabel: "Save file",
                onClick: onSaveFileButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveFileButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: "Remove file",
                accessibilityLabel: "Remove file",
                onClick: {
                    // TODO: Implement remove‑file action
                }
            )
        ]
    }
}
