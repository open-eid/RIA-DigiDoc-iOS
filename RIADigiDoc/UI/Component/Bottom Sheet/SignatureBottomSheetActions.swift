struct SignatureBottomSheetActions {
    static func actions(
        showRemoveSignatureButton: Bool,
        onDetailsButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: "Signature details",
                accessibilityLabel: "Signature details",
                onClick: onDetailsButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveSignatureButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: "Remove signature",
                accessibilityLabel: "Remove signature",
                onClick: {
                    // TODO: Implement remove signature action
                }
            )
        ]
    }
}
