struct ContainerNameBottomSheetActions {
    static func actions(
        isEditContainerButtonShown: Bool,
        isEncryptButtonShown: Bool,
        onRenameContainerButtonClick: @escaping () -> Void,
        onSaveContainerButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                showButton: isEditContainerButtonShown,
                icon: "ic_m3_edit_48pt_wght400",
                title: "Change container name",
                accessibilityLabel: "Change container name",
                onClick: onRenameContainerButtonClick
            ),
            BottomSheetButton(
                icon: "ic_m3_download_48pt_wght400",
                title: "Save container",
                accessibilityLabel: "Save container",
                onClick: onSaveContainerButtonClick
            ),
            BottomSheetButton(
                showButton: isEncryptButtonShown,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: "Encrypt",
                accessibilityLabel: "Encrypt",
                showExtraIcon: true,
                onClick: {
                    // TODO: Implement encrypt action
                }
            )
        ]
    }
}
