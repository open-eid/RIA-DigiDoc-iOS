/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
