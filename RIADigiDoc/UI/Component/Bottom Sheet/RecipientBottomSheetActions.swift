// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct RecipientBottomSheetActions {
    static func actions(
        decryptAccessibilityLabel: String? = nil,
        showRemoveRecipientButton: Bool,
        onDecryptButtonClick: @escaping () -> Void = {},
        onDetailsButtonClick: @escaping () -> Void,
        onRemoveRecipientButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                showButton: decryptAccessibilityLabel != nil,
                icon: "ic_m3_encrypted_off_48pt_wght400",
                title: "Decrypt",
                accessibilityLabel: decryptAccessibilityLabel ?? "",
                onClick: onDecryptButtonClick
            ),
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: "Recipient details",
                accessibilityLabel: "Recipient details",
                onClick: onDetailsButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveRecipientButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: "Remove recipient",
                accessibilityLabel: "Remove recipient",
                onClick: onRemoveRecipientButtonClick
            )
        ]
    }
}
