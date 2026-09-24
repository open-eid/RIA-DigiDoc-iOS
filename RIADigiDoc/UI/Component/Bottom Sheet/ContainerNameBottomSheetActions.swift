// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct ContainerNameBottomSheetActions {
    // swiftlint:disable:next function_parameter_count
    static func actions(
        isEditContainerButtonShown: Bool,
        isSaveButtonShown: Bool = true,
        isSignButtonShown: Bool,
        isEncryptButtonShown: Bool,
        isExtendSignaturesButtonShown: Bool,
        onRenameContainerButtonClick: @escaping () -> Void,
        onSaveContainerButtonClick: @escaping () -> Void,
        onSignContainerButtonClick: @escaping () -> Void,
        onEncryptContainerButtonClick: @escaping () -> Void,
        onExtendSignaturesClick: @escaping () -> Void
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
                showButton: isSaveButtonShown,
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
                onClick: onEncryptContainerButtonClick
            ),
            BottomSheetButton(
                showButton: isSignButtonShown,
                icon: "ic_m3_stylus_note_48pt_wght400",
                title: "Sign",
                accessibilityLabel: "Sign document",
                showExtraIcon: true,
                onClick: onSignContainerButtonClick
            ),
            BottomSheetButton(
                showButton: isExtendSignaturesButtonShown,
                icon: "ic_m3_more_time_48pt_wght400",
                title: "Extend signatures",
                accessibilityLabel: "Extend signatures",
                showExtraIcon: false,
                onClick: onExtendSignaturesClick
            )
        ]
    }
}
