// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct DataFileBottomSheetActions {
    static func actions(
        showOpenFileButton: Bool = true,
        showSaveFileButton: Bool = true,
        showRemoveFileButton: Bool = false,
        onOpenFileButtonClick: @escaping () -> Void,
        onSaveFileButtonClick: @escaping () -> Void,
        onRemoveFileButtonClick: @escaping () -> Void
    ) -> [BottomSheetButton] {

        return [
            BottomSheetButton(
                showButton: showOpenFileButton,
                icon: "ic_m3_edit_48pt_wght400",
                title: "Open file",
                accessibilityLabel: "Open file",
                onClick: onOpenFileButtonClick
            ),
            BottomSheetButton(
                showButton: showSaveFileButton,
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
                onClick: onRemoveFileButtonClick
            )
        ]
    }
}
