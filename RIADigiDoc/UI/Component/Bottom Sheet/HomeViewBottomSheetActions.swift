// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct HomeViewBottomSheetActions {
    static func actions(
        onOpenFilesClick: @escaping () -> Void,
        onRecentDocumentsClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_attach_file_48pt_wght400",
                title: "Add file",
                accessibilityLabel: "Add file",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onOpenFilesClick,
            ),
            BottomSheetButton(
                icon: "ic_m3_folder_48pt_wght400",
                title: "Recent documents",
                accessibilityLabel: "Recent documents",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onRecentDocumentsClick
            )
        ]
    }
}
