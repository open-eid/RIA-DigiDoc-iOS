/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
