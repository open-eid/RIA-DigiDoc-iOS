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

struct ContainerNameBottomSheetActions {
    // swiftlint:disable:next function_parameter_count
    static func actions(
        isEditContainerButtonShown: Bool,
        isSaveButtonShown: Bool = true,
        isSignButtonShown: Bool,
        isEncryptButtonShown: Bool,
        onRenameContainerButtonClick: @escaping () -> Void,
        onSaveContainerButtonClick: @escaping () -> Void,
        onSignContainerButtonClick: @escaping () -> Void,
        onEncryptContainerButtonClick: @escaping () -> Void
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
            )
        ]
    }
}
